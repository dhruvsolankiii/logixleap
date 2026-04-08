import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../services/cache_service.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  Map<String, dynamic>? portfolioData;
  String? errorMessage;
  bool isOffline = false;

  @override
  void initState() {
    super.initState();
    loadPortfolio();
  }

  Future loadPortfolio() async {
    setState(() {
      errorMessage = null;
      portfolioData = null;
      isOffline = false;
    });

    try {
      String? userId = await StorageService.getUserId();
      var data = await ApiService.getPortfolio(userId!);

      if (data["error"] == true) {
        // Try loading from cache
        await _loadFromCache();
        return;
      }

      setState(() {
        portfolioData = data;
      });

      // Cache portfolio data
      await CacheService.saveCache("portfolio", data);
    } catch (e) {
      await _loadFromCache();
    }
  }

  Future<void> _loadFromCache() async {
    var cached = await CacheService.getCache("portfolio");

    if (cached != null) {
      setState(() {
        portfolioData = Map<String, dynamic>.from(cached);
        isOffline = true;
      });
    } else {
      setState(() {
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
        title: const Text("My Portfolio"),
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
                      onPressed: loadPortfolio,
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
          : portfolioData == null
              ? Skeletonizer(
                  enabled: true,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: buildSummaryCard(context: context, title: "Total Invested", value: "₹0")),
                            const SizedBox(width: 10),
                            Expanded(child: buildSummaryCard(context: context, title: "Total Profit", value: "₹0")),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: ListView.builder(
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              return Card(
                                color: theme.cardColor,
                                child: ListTile(
                                  title: Text("Loading Plan", style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
                                  subtitle: Text("Amount: ₹0", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text("+₹0", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                          minimumSize: const Size(60, 30),
                                        ),
                                        onPressed: () {},
                                        child: const Text("Withdraw", style: TextStyle(color: Colors.white, fontSize: 12)),
                                      ),
                                    ],
                                  ),
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
                            onTap: loadPortfolio,
                            child: const Icon(Icons.refresh, color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                    ),
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

                  const SizedBox(height: 20),

                  Expanded(
                    child: ListView.builder(
                      itemCount: portfolioData!["investments"].length,

                      itemBuilder: (context, index) {
                        var inv = portfolioData!["investments"][index];

                        return Card(
                          color: theme.cardColor,

                          child: ListTile(
                            title: Text(
                              inv["plan"],
                              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                            ),

                            subtitle: Text(
                              "Amount: ₹${inv["amount"]}",
                              style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                            ),

                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "+₹${inv["earnedProfit"] ?? 0}",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                    minimumSize: const Size(60, 30),
                                  ),
                                  onPressed: () => _withdrawInvestment(inv["_id"]),
                                  child: const Text("Withdraw", style: TextStyle(color: Colors.white, fontSize: 12)),
                                ),
                              ],
                            ),
                            
                            onTap: () => _showProfitDetails(inv),
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

  void _showProfitDetails(Map<String, dynamic> inv) {
    double progressRatio = (inv["progressRatio"] ?? 0).toDouble();
    int percentage = (progressRatio * 100).toInt();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text(inv["plan"], style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Initial Investment: ₹${inv["amount"]}", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
            const SizedBox(height: 10),
            Text("Target Profit: ₹${inv["profit"]} (${inv["roi"]}%)", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
            const SizedBox(height: 10),
            Text("Duration: ${inv["duration"]}", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
            const SizedBox(height: 20),
            
            // Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Time Elapsed", style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 12)),
                    Text("$percentage%", style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 5),
                LinearProgressIndicator(
                  value: progressRatio,
                  backgroundColor: Colors.black26,
                  color: Colors.greenAccent,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Text("Current Live Profit", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                  Text(
                    "+₹${inv["earnedProfit"] ?? 0}",
                    style: const TextStyle(color: Colors.greenAccent, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close", style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
          ),
        ],
      ),
    );
  }

  Future<void> _withdrawInvestment(String investmentId) async {
    final theme = Theme.of(context);
    
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text("Withdraw Investment", style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
        content: Text("Are you sure you want to withdraw right now? If you withdraw before the plan duration is complete, your earned profit will be pro-rated based on the time elapsed so far. The initial amount plus any earned partial profit will safely return to your balance.", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Withdraw", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm || !mounted) return;

    String? userId = await StorageService.getUserId();
    if (userId == null) return;

    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator())
    );

    try {
      var result = await ApiService.withdraw(investmentId, userId);
      
      if (!mounted) return;
      Navigator.pop(context); // Remove loading indicator

      if (result["message"] == "Withdrawal Successful") {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Withdrawal successful!"), backgroundColor: Colors.green),
        );
        loadPortfolio(); // Refresh the portfolio data
      } else {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result["message"] ?? "Failed to withdraw"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Remove loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to withdraw: Network Error"), backgroundColor: Colors.red),
      );
    }
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
