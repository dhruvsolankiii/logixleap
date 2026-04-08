import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../services/cache_service.dart';
import 'package:skeletonizer/skeletonizer.dart';

class InvestmentScreen extends StatefulWidget {
  const InvestmentScreen({super.key});

  @override
  State<InvestmentScreen> createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> {
  List<dynamic> plans = [];
  bool isLoading = true;
  double virtualBalance = 0;
  bool isBalanceLoading = true;
  String? errorMessage;
  bool isOffline = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
      isBalanceLoading = true;
      errorMessage = null;
      isOffline = false;
    });

    try {
      var plansData = await ApiService.getPlans();
      setState(() {
        plans = plansData;
        isLoading = false;
      });

      // Cache plans data
      await CacheService.saveCache("plans", plansData);

      String? userId = await StorageService.getUserId();
      if (userId != null) {
        var portfolioData = await ApiService.getPortfolio(userId);
        if (portfolioData["error"] != true) {
          setState(() {
            virtualBalance = (portfolioData["virtualBalance"] ?? 0).toDouble();
            isBalanceLoading = false;
          });
          // Cache balance
          await CacheService.saveCache("balance", virtualBalance);
        } else {
          setState(() { isBalanceLoading = false; });
        }
      }
    } catch (e) {
      if (mounted) {
        // Try loading from cache
        await _loadFromCache();
      }
    }
  }

  Future<void> _loadFromCache() async {
    var cachedPlans = await CacheService.getCache("plans");
    var cachedBalance = await CacheService.getCache("balance");

    if (cachedPlans != null) {
      setState(() {
        plans = cachedPlans;
        virtualBalance = (cachedBalance ?? 0).toDouble();
        isLoading = false;
        isBalanceLoading = false;
        isOffline = true;
      });
    } else {
      setState(() {
        isLoading = false;
        isBalanceLoading = false;
        errorMessage = "Unable to connect to server. No cached data available.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Investment Plans"),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off, size: 64, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: loadData,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text("Retry", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : isLoading || isBalanceLoading
              ? Skeletonizer(
                  enabled: true,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF1E88E5), Color(0xFF1565C0)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Column(
                            children: [
                              Text("Available Balance", style: TextStyle(color: Colors.white70, fontSize: 16)),
                              SizedBox(height: 8),
                              Text("₹0", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: ListView.builder(
                            itemCount: 4,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: buildPlanCard(
                                  context: context,
                                  title: "Loading Plan Title",
                                  description: "Loading description of the plan goes here.",
                                  roi: 0,
                                  duration: "0 Months",
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Offline Banner
                  if (isOffline)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade800,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.cloud_off, color: Colors.white, size: 18),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              "Showing cached data - Server offline",
                              style: TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ),
                          GestureDetector(
                            onTap: loadData,
                            child: const Icon(Icons.refresh, color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                    ),
                  // Balance Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Available Balance",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "₹$virtualBalance",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Plans List
                  Expanded(
                    child: plans.isEmpty
                        ? Center(child: Text("No plans available", style: TextStyle(color: theme.textTheme.bodyMedium?.color)))
                        : ListView.builder(
                            itemCount: plans.length,
                            itemBuilder: (context, index) {
                              var plan = plans[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: buildPlanCard(
                                  context: context,
                                  title: plan['title'] ?? "",
                                  description: plan['description'] ?? "",
                                  roi: (plan['roi'] ?? 0).toDouble(),
                                  duration: plan['duration'] ?? "",
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildPlanCard({
    required BuildContext context,
    required String title,
    required String description,
    required double roi,
    required String duration,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? [] : [
          const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ]
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: theme.textTheme.bodyLarge?.color,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(description, style: TextStyle(color: theme.textTheme.bodyMedium?.color)),

          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    "$roi% Return",
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(duration, style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                ],
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                ),

                onPressed: () {
                  showInvestDialog(context, title, roi, duration);
                },

                child: const Text(
                  "Invest",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showInvestDialog(
    BuildContext context,
    String title,
    double roi,
    String duration,
  ) {
    TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,

      builder: (dialogContext) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: Text(
            "Invest in $title",
            style: TextStyle(color: theme.textTheme.bodyLarge?.color),
          ),

          content: TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: theme.textTheme.bodyLarge?.color),
            decoration: InputDecoration(
              labelText: "Enter Amount (₹)",
              labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: theme.textTheme.bodyMedium?.color ?? Colors.grey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.primary),
              ),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                "Cancel",
                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
              ),
              onPressed: () async {
                final String text = amountController.text.trim();

                if (text.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter an amount"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final double? parsed = double.tryParse(text);

                if (parsed == null || parsed <= 0) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter a valid positive amount"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                String? userId = await StorageService.getUserId();

                var result = await ApiService.invest(
                  userId!,
                  title,
                  parsed,
                  roi,
                  duration,
                );

                Navigator.pop(dialogContext);

                showDialog(
                  context: context,

                  builder: (resultContext) {
                    final theme = Theme.of(context);
                    return AlertDialog(
                      backgroundColor: theme.cardColor,
                      title: Text(
                        "Investment Result",
                        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            result["message"],
                            style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                          ),
                        if (result["virtualBalance"] != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Remaining Balance:",
                                  style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 14),
                                ),
                                Text(
                                  "₹${result["virtualBalance"]}",
                                  style: const TextStyle(
                                    color: Color(0xFF4CAF50),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    actions: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                        ),
                        onPressed: () {
                          Navigator.pop(resultContext);
                        },
                        child: const Text(
                          "OK",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  );
                },
              );
            },

              child: const Text(
                "Confirm",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
