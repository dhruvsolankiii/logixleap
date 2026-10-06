import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../services/api_service.dart';
import '../../services/cache_service.dart';
import '../../services/storage_service.dart';
import '../../services/theme_service.dart';

class InvestmentScreen extends StatefulWidget {
  const InvestmentScreen({super.key});
  @override
  State<InvestmentScreen> createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> {
  List<dynamic> plans = [];
  double virtualBalance = 0;
  bool loading = true, offline = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    if (mounted) {
      setState(() {
        loading = true;
        errorMessage = null;
        offline = false;
      });
    }
    try {
      final fetched = await ApiService.getPlans();
      final userId = await StorageService.getUserId();
      var balance = 0.0;
      if (userId != null) {
        final portfolio = await ApiService.getPortfolio(userId);
        balance = (portfolio['virtualBalance'] ?? 0).toDouble();
      }
      if (!mounted) return;
      setState(() {
        plans = fetched;
        virtualBalance = balance;
        loading = false;
      });
      await CacheService.saveCache('plans', fetched);
      await CacheService.saveCache('balance', balance);
    } catch (_) {
      await _loadFromCache();
    }
  }

  Future<void> _loadFromCache() async {
    final cachedPlans = await CacheService.getCache('plans');
    final cachedBalance = await CacheService.getCache('balance');
    if (!mounted) return;
    setState(() {
      loading = false;
      if (cachedPlans != null) {
        plans = cachedPlans;
        virtualBalance = (cachedBalance ?? 0).toDouble();
        offline = true;
      } else {
        errorMessage = 'Unable to connect to server. No cached data available.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Investment plans')),
      body: errorMessage != null
          ? _ErrorState(message: errorMessage!, onRetry: loadData)
          : Skeletonizer(
              enabled: loading,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    if (offline) _OfflineBanner(onRetry: loadData),
                    _BalanceCard(value: '₹$virtualBalance'),
                    const SizedBox(height: 24),
                    Expanded(
                      child: plans.isEmpty
                          ? const Center(child: Text('No plans available'))
                          : ListView.separated(
                              itemCount: loading ? 3 : plans.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (_, index) {
                                final plan = loading
                                    ? <String, dynamic>{}
                                    : plans[index];
                                return _PlanCard(
                                  title: plan['title'] ?? 'Loading plan',
                                  description:
                                      plan['description'] ??
                                      'Explore a balanced way to grow your savings.',
                                  roi: (plan['roi'] ?? 0).toDouble(),
                                  duration:
                                      plan['duration'] ?? 'Flexible duration',
                                  onInvest: () => showInvestDialog(
                                    context,
                                    plan['title'] ?? 'Investment',
                                    (plan['roi'] ?? 0).toDouble(),
                                    plan['duration'] ?? '',
                                  ),
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

  void showInvestDialog(
    BuildContext context,
    String title,
    double roi,
    String duration,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Invest in $title'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Amount (₹)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text.trim());
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Enter a valid positive amount'),
                  ),
                );
                return;
              }
              final userId = await StorageService.getUserId();
              if (userId == null) return;
              final result = await ApiService.invest(
                userId,
                title,
                amount,
                roi,
                duration,
              );
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              if (!context.mounted) return;
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Investment result'),
                  content: Text(result['message'] ?? 'Investment completed.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.value});
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppThemes.forest,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available balance',
          style: TextStyle(color: Colors.white.withAlpha(190)),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.description,
    required this.roi,
    required this.duration,
    required this.onInvest,
  });
  final String title, description, duration;
  final double roi;
  final VoidCallback onInvest;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(description),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$roi% return',
                      style: const TextStyle(
                        color: AppThemes.forest,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(duration),
                  ],
                ),
              ),
              ElevatedButton(onPressed: onInvest, child: const Text('Invest')),
            ],
          ),
        ],
      ),
    ),
  );
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.onRetry});
  final VoidCallback onRetry;
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
        IconButton(onPressed: onRetry, icon: const Icon(Icons.refresh)),
      ],
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
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
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    ),
  );
}
