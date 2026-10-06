import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../services/api_service.dart';
import '../../services/cache_service.dart';
import '../../services/storage_service.dart';
import '../../services/theme_service.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});
  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  Map<String, dynamic>? data;
  String? error;
  bool offline = false;
  @override
  void initState() {
    super.initState();
    loadPortfolio();
  }

  Future<void> loadPortfolio() async {
    if (mounted) {
      setState(() {
        data = null;
        error = null;
        offline = false;
      });
    }
    try {
      final id = await StorageService.getUserId();
      if (id == null) throw Exception();
      final result = await ApiService.getPortfolio(id);
      if (result['error'] == true) throw Exception();
      if (!mounted) return;
      setState(() => data = result);
      await CacheService.saveCache('portfolio', result);
    } catch (_) {
      final cached = await CacheService.getCache('portfolio');
      if (!mounted) return;
      if (cached != null) {
        setState(() {
          data = Map<String, dynamic>.from(cached);
          offline = true;
        });
      } else {
        setState(
          () =>
              error = 'Unable to connect to server. No cached data available.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final investments = (data?['investments'] as List? ?? []);
    return Scaffold(
      appBar: AppBar(title: const Text('My portfolio')),
      body: error != null
          ? _ErrorState(message: error!, retry: loadPortfolio)
          : Skeletonizer(
              enabled: data == null,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    if (offline) _OfflineBanner(retry: loadPortfolio),
                    Row(
                      children: [
                        Expanded(
                          child: _Metric(
                            title: 'Total invested',
                            value: '₹${data?['totalInvested'] ?? 0}',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _Metric(
                            title: 'Total profit',
                            value: '₹${data?['totalProfit'] ?? 0}',
                            green: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: data == null
                          ? ListView(
                              children: List.generate(
                                3,
                                (_) => const _Holding(
                                  plan: 'Loading plan',
                                  amount: '₹0',
                                  profit: '₹0',
                                ),
                              ),
                            )
                          : investments.isEmpty
                          ? const Center(
                              child: Text(
                                'Your portfolio is ready for its first investment.',
                              ),
                            )
                          : ListView.separated(
                              itemCount: investments.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (_, index) {
                                final inv = investments[index];
                                return _Holding(
                                  plan: '${inv['plan'] ?? 'Investment'}',
                                  amount: '₹${inv['amount'] ?? 0}',
                                  profit: '+₹${inv['earnedProfit'] ?? 0}',
                                  onTap: () => _showProfitDetails(
                                    Map<String, dynamic>.from(inv),
                                  ),
                                  onWithdraw: () =>
                                      _withdrawInvestment('${inv['_id']}'),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _showProfitDetails(Map<String, dynamic> inv) {
    final ratio = ((inv['progressRatio'] ?? 0) as num).toDouble().clamp(
      0.0,
      1.0,
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${inv['plan']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Initial investment: ₹${inv['amount']}'),
            const SizedBox(height: 8),
            Text('Target profit: ₹${inv['profit']} (${inv['roi']}%)'),
            const SizedBox(height: 8),
            Text('Duration: ${inv['duration']}'),
            const SizedBox(height: 18),
            LinearProgressIndicator(value: ratio),
            const SizedBox(height: 12),
            Text(
              'Current live profit: +₹${inv['earnedProfit'] ?? 0}',
              style: const TextStyle(
                color: AppThemes.forest,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _withdrawInvestment(String investmentId) async {
    final confirm =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Withdraw investment?'),
            content: const Text(
              'Your initial amount and any earned partial profit will return to your balance.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Withdraw'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirm || !mounted) return;
    final userId = await StorageService.getUserId();
    if (userId == null || !mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final result = await ApiService.withdraw(investmentId, userId);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Withdrawal complete'),
          backgroundColor: result['message'] == 'Withdrawal Successful'
              ? AppThemes.forest
              : AppThemes.red,
        ),
      );
      if (result['message'] == 'Withdrawal Successful') loadPortfolio();
    } catch (_) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to withdraw'),
          backgroundColor: AppThemes.red,
        ),
      );
    }
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.title, required this.value, this.green = false});
  final String title, value;
  final bool green;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: green ? AppThemes.forest : null,
            ),
          ),
        ],
      ),
    ),
  );
}

class _Holding extends StatelessWidget {
  const _Holding({
    required this.plan,
    required this.amount,
    required this.profit,
    this.onTap,
    this.onWithdraw,
  });
  final String plan, amount, profit;
  final VoidCallback? onTap, onWithdraw;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      leading: const CircleAvatar(
        backgroundColor: AppThemes.mint,
        child: Icon(Icons.pie_chart_outline, color: AppThemes.forest),
      ),
      title: Text(plan, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text('Invested $amount'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            profit,
            style: const TextStyle(
              color: AppThemes.forest,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (onWithdraw != null)
            GestureDetector(
              onTap: onWithdraw,
              child: const Text(
                'Withdraw',
                style: TextStyle(
                  color: AppThemes.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.retry});
  final VoidCallback retry;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: AppThemes.amber.withAlpha(35),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(Icons.cloud_off, size: 18, color: AppThemes.amber),
        const SizedBox(width: 8),
        const Expanded(child: Text('Showing cached data')),
        IconButton(onPressed: retry, icon: const Icon(Icons.refresh)),
      ],
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.retry});
  final String message;
  final VoidCallback retry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 48),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: retry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    ),
  );
}
