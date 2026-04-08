import 'package:flutter/material.dart';
//import '../utils/app_colors.dart';

import 'dashboard/dashboard_screen.dart';
import 'investment/investment_screen.dart';
import 'portfolio/portfolio_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const InvestmentScreen(),
    const PortfolioScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: _screens[_currentIndex],

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: isDark ? [] : [
            const BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          currentIndex: _currentIndex,

          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.textTheme.bodyMedium?.color,

          type: BottomNavigationBarType.fixed,

          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },

          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),

            BottomNavigationBarItem(
              icon: Icon(Icons.trending_up),
              label: "Invest",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: "Portfolio",
            ),

            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}
