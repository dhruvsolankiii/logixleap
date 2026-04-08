import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List<dynamic> transactions = [];
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      String? userId = await StorageService.getUserId();
      if (userId == null) {
        setState(() {
          errorMessage = "User not found. Please log in again.";
          isLoading = false;
        });
        return;
      }

      var list = await ApiService.getTransactions(userId);
      setState(() {
        transactions = list;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load transactions. Check your connection.";
        isLoading = false;
      });
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'deposit':
      case 'admin_fund':
        return Icons.account_balance_wallet;
      case 'investment_purchase':
        return Icons.shopping_cart;
      case 'investment_withdrawal':
        return Icons.monetization_on;
      default:
        return Icons.swap_horiz;
    }
  }

  Color _getColorForType(String type, double amount) {
    if (amount > 0) return Colors.greenAccent;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Transaction History"),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: isLoading
          ? Skeletonizer(
              enabled: true,
              child: ListView.builder(
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Card(
                    color: theme.cardColor,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary,
                        child: const Icon(Icons.account_balance_wallet, color: Colors.white),
                      ),
                      title: Text(
                        "Loading Transaction",
                        style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Oct 24, 2023 - 04:30 PM",
                        style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 12),
                      ),
                      trailing: const Text(
                        "+₹0.0",
                        style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            )
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
              : transactions.isEmpty
                  ? Center(child: Text("No transactions yet.", style: TextStyle(color: theme.textTheme.bodyMedium?.color)))
                  : ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        var tx = transactions[index];
                        String type = tx["type"];
                        double amount = (tx["amount"] ?? 0).toDouble();
                        String desc = tx["description"] ?? "Transaction";
                        
                        DateTime date = DateTime.parse(tx["createdAt"]).toLocal();
                        String formattedDate = DateFormat('MMM dd, yyyy - hh:mm a').format(date);

                        return Card(
                          color: theme.cardColor,
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.primary,
                              child: Icon(_getIconForType(type), color: Colors.white),
                            ),
                            title: Text(
                              desc,
                              style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              formattedDate,
                              style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 12),
                            ),
                            trailing: Text(
                              amount > 0 ? "+₹$amount" : "₹$amount",
                              style: TextStyle(
                                color: _getColorForType(type, amount),
                                fontWeight: FontWeight.bold,
                                fontSize: 16
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
