import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  List<dynamic> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    String? token = await StorageService.getToken();
    
    if (token != null) {
      try {
        var data = await ApiService.getAllUsers(token);
        setState(() {
          users = data;
          isLoading = false;
        });
      } catch (e) {
        setState(() { isLoading = false; });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to load users"), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> deleteUser(String userId, String userName) async {
    final theme = Theme.of(context);
    
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text("Delete User", style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
        content: Text("Are you sure you want to delete '$userName'? This action cannot be undone.", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    String? token = await StorageService.getToken();
    if (token == null) return;

    try {
      var result = await ApiService.deleteUser(token, userId);
      
      if (mounted) {
        if (result["message"] == "User deleted successfully") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User deleted successfully"), backgroundColor: Colors.green),
          );
          loadUsers(); // refresh the list
        } else {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result["message"] ?? "Failed to delete user"), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete user: Network Error"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showFundDialog(String userId, String userName) {
    TextEditingController amountController = TextEditingController();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text("Fund $userName", style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            labelText: "Amount (₹)",
            labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.textTheme.bodyMedium?.color ?? Colors.grey)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.primary)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              double? amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid amount")));
                return;
              }

              Navigator.pop(context); // close dialog
              String? token = await StorageService.getToken();
              if (token != null) {
                try {
                  var result = await ApiService.fundUser(token, userId, amount);
                  if (mounted) {
                    if (result["message"] == "Funds added successfully") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Added ₹$amount to $userName"), backgroundColor: Colors.green),
                      );
                      loadUsers();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result["message"] ?? "Failed to add funds"), backgroundColor: Colors.red),
                      );
                    }
                  }
                } catch (e) {
                   if (mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Network Error"), backgroundColor: Colors.red),
                    );
                   }
                }
              }
            },
            child: const Text("Add Funds", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Manage Users"),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: isLoading
          ? Skeletonizer(
              enabled: true,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Card(
                    color: theme.cardColor,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary,
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        "Loading Name",
                        style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "loading@email.com",
                        style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("Balance", style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 10)),
                              const Text(
                                "₹0",
                                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.monetization_on, color: Colors.greenAccent),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {},
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          : users.isEmpty
              ? const Center(child: Text("No users found", style: TextStyle(color: Colors.white70)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var user = users[index];
                    bool isAdmin = user['role'] == 'admin';

                    return Card(
                      color: theme.cardColor,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isAdmin ? Colors.purpleAccent : theme.colorScheme.primary,
                          child: Icon(
                            isAdmin ? Icons.admin_panel_settings : Icons.person,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          user['name'] ?? "Unknown",
                          style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          user['email'] ?? "",
                          style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("Balance", style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 10)),
                                Text(
                                  "₹${user['virtualBalance'] ?? 0}",
                                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            if (!isAdmin) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.monetization_on, color: Colors.greenAccent),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  _showFundDialog(user['_id'], user['name']);
                                },
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  deleteUser(user['_id'], user['name']);
                                },
                              ),
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
