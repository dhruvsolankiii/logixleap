import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? portfolioData;
  String userName = "";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future loadData() async {
    String? userId = await StorageService.getUserId();
    String? name = await StorageService.getName();

    var data = await ApiService.getPortfolio(userId!);

    setState(() {
      portfolioData = data;
      userName = name ?? "User";
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      body: portfolioData == null
          ? Skeletonizer(
              enabled: true,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    children: [
                      Text("Welcome User", style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)]), borderRadius: BorderRadius.circular(16)),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Virtual Balance", style: TextStyle(color: Colors.white70, fontSize: 16)),
                            SizedBox(height: 10),
                            Text("₹0", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(child: buildSummaryCard(context: context, title: "Total Invested", value: "₹0")),
                          const SizedBox(width: 10),
                          Expanded(child: buildSummaryCard(context: context, title: "Total Profit", value: "₹0")),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Text("Recent Investments", style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      Card(
                        color: theme.cardColor,
                        child: ListTile(
                          title: Text("Loading Plan", style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
                          subtitle: Text("Amount ₹0", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                          trailing: const Text("+₹0", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),

                child: ListView(
                  children: [
                    Text(
                      "Welcome $userName",
                      style: TextStyle(
                        color: theme.textTheme.bodyLarge?.color,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // BALANCE CARD
                    Container(
                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Virtual Balance",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "₹${portfolioData!["virtualBalance"]}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    Row(
                      children: [
                        Expanded(
                          child: buildSummaryCard(
                            context: context,
                            title: "Total Invested",
                            value: "₹${portfolioData!["totalInvested"]}",
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: buildSummaryCard(
                            context: context,
                            title: "Total Profit",
                            value: "₹${portfolioData!["totalProfit"]}",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    Text(
                      "Recent Investments",
                      style: TextStyle(
                        color: theme.textTheme.bodyLarge?.color,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    ...portfolioData!["investments"].map<Widget>((inv) {
                      return Card(
                        color: theme.cardColor,

                        child: ListTile(
                          title: Text(
                            inv["plan"],
                            style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                          ),

                          subtitle: Text(
                            "Amount ₹${inv["amount"]}",
                            style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                          ),

                          trailing: Text(
                            "+₹${inv["profit"]}",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildSummaryCard({required BuildContext context, required String title, required String value}) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: theme.brightness == Brightness.dark ? [] : [
          const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ]
      ),

      child: Column(
        children: [
          Text(title, style: TextStyle(color: theme.textTheme.bodyMedium?.color)),

          const SizedBox(height: 10),

          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: theme.textTheme.bodyLarge?.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
