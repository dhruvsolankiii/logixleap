import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ManagePlansScreen extends StatefulWidget {
  const ManagePlansScreen({super.key});

  @override
  State<ManagePlansScreen> createState() => _ManagePlansScreenState();
}

class _ManagePlansScreenState extends State<ManagePlansScreen> {
  List<dynamic> plans = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPlans();
  }

  Future<void> loadPlans() async {
    setState(() { isLoading = true; });
    try {
      var data = await ApiService.getPlans();
      setState(() {
        plans = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() { isLoading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load plans"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> deletePlan(String planId) async {
    String? token = await StorageService.getToken();
    if (token == null) return;

    try {
      await ApiService.deletePlan(token, planId);
      loadPlans(); // Reload after delete
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Plan deleted"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete plan"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void showAddPlanDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final roiCtrl = TextEditingController();
    final durationCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: Text("Create New Plan", style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildField(titleCtrl, "Plan Title (e.g., Monthly Plan)"),
                const SizedBox(height: 10),
                _buildField(descCtrl, "Description"),
                const SizedBox(height: 10),
                _buildField(roiCtrl, "ROI % (e.g., 5)", isNumber: true),
                const SizedBox(height: 10),
                _buildField(durationCtrl, "Duration (e.g., 1 Month)"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E88E5)),
              onPressed: () async {
                if (titleCtrl.text.isEmpty || roiCtrl.text.isEmpty) return;

                String? token = await StorageService.getToken();
                if (token != null) {
                  await ApiService.createPlan(
                    token,
                    titleCtrl.text,
                    descCtrl.text,
                    double.tryParse(roiCtrl.text) ?? 0,
                    durationCtrl.text,
                  );
                  Navigator.pop(context);
                  loadPlans(); // Reload list
                }
              },
              child: Text("Create", style: TextStyle(color: theme.textTheme.bodyLarge?.color ?? Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void showEditPlanDialog(Map<String, dynamic> plan) {
    final titleCtrl = TextEditingController(text: plan['title'] ?? '');
    final descCtrl = TextEditingController(text: plan['description'] ?? '');
    final roiCtrl = TextEditingController(text: plan['roi']?.toString() ?? '');
    final durationCtrl = TextEditingController(text: plan['duration'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: Text("Edit Plan", style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildField(titleCtrl, "Plan Title"),
                const SizedBox(height: 10),
                _buildField(descCtrl, "Description"),
                const SizedBox(height: 10),
                _buildField(roiCtrl, "ROI %", isNumber: true),
                const SizedBox(height: 10),
                _buildField(durationCtrl, "Duration"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
              onPressed: () async {
                if (titleCtrl.text.isEmpty || roiCtrl.text.isEmpty) return;

                String? token = await StorageService.getToken();
                if (token != null) {
                  await ApiService.updatePlan(
                    token,
                    plan['_id'],
                    titleCtrl.text,
                    descCtrl.text,
                    double.tryParse(roiCtrl.text) ?? 0,
                    durationCtrl.text,
                  );
                  Navigator.pop(context);
                  loadPlans();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Plan updated successfully"), backgroundColor: Colors.green),
                    );
                  }
                }
              },
              child: Text("Update", style: TextStyle(color: theme.textTheme.bodyLarge?.color ?? Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, {bool isNumber = false}) {
    final theme = Theme.of(context);
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.textTheme.bodyMedium?.color ?? Colors.grey)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.primary)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Manage Plans"),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: showAddPlanDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: isLoading
          ? Skeletonizer(
              enabled: true,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return Card(
                    color: theme.cardColor,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      title: Text(
                        "Loading Plan Title",
                        style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Text("Loading description...", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                          const SizedBox(height: 5),
                          Text("ROI: 0% | Duration: 0 Months", 
                            style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orangeAccent),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          : plans.isEmpty
              ? Center(child: Text("No plans available. Add one!", style: TextStyle(color: theme.textTheme.bodyMedium?.color)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: plans.length,
                  itemBuilder: (context, index) {
                    var plan = plans[index];
                    return Card(
                      color: theme.cardColor,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        title: Text(
                          plan['title'] ?? "",
                          style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),
                            Text(plan['description'] ?? "", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                            const SizedBox(height: 5),
                            Text("ROI: ${plan['roi']}% | Duration: ${plan['duration']}", 
                              style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orangeAccent),
                              onPressed: () => showEditPlanDialog(plan),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => deletePlan(plan['_id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
