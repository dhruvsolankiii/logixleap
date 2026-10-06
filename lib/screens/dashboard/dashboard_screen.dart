import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../services/theme_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? portfolioData;
  String userName = '';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final userId = await StorageService.getUserId();
    final name = await StorageService.getName();
    if (userId == null) return;
    final data = await ApiService.getPortfolio(userId);
    if (!mounted) return;
    setState(() {
      portfolioData = data['error'] == true ? <String, dynamic>{} : data;
      userName = name ?? 'User';
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = portfolioData;
    return Scaffold(
      body: SafeArea(
        child: Skeletonizer(
          enabled: data == null,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Good morning,',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                data == null ? 'User' : userName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 28),
              _BalanceCard(
                value: data == null ? '₹0' : '₹${data['virtualBalance'] ?? 0}',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      title: 'Total invested',
                      value: data == null
                          ? '₹0'
                          : '₹${data['totalInvested'] ?? 0}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      title: 'Total profit',
                      value: data == null
                          ? '₹0'
                          : '₹${data['totalProfit'] ?? 0}',
                      accent: AppThemes.forest,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Recent investments',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (data == null)
                ...List.generate(
                  2,
                  (_) => const _InvestmentTile(
                    plan: 'Loading plan',
                    amount: '₹0',
                    profit: '+₹0',
                  ),
                )
              else if ((data['investments'] as List? ?? []).isEmpty)
                _EmptyState(text: 'No investments yet')
              else
                ...((data['investments'] as List)
                    .take(4)
                    .map(
                      (inv) => _InvestmentTile(
                        plan: '${inv['plan'] ?? 'Investment'}',
                        amount: '₹${inv['amount'] ?? 0}',
                        profit: '+₹${inv['profit'] ?? 0}',
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.value});
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppThemes.forest,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Virtual balance',
          style: TextStyle(color: Colors.white.withValues(alpha: .75)),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Available to invest',
          style: TextStyle(color: Colors.white.withValues(alpha: .75)),
        ),
      ],
    ),
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value, this.accent});
  final String title, value;
  final Color? accent;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: accent),
          ),
        ],
      ),
    ),
  );
}

class _InvestmentTile extends StatelessWidget {
  const _InvestmentTile({
    required this.plan,
    required this.amount,
    required this.profit,
  });
  final String plan, amount, profit;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
      leading: const CircleAvatar(
        backgroundColor: AppThemes.mint,
        child: Icon(Icons.auto_graph, color: AppThemes.forest),
      ),
      title: Text(plan, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text('Amount $amount'),
      trailing: Text(
        profit,
        style: const TextStyle(
          color: AppThemes.forest,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Center(child: Text(text)),
    ),
  );
}
