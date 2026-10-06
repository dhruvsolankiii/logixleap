import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import '../../services/theme_service.dart';
import '../auth/login_screen.dart';
import 'privacy_security_screen.dart';
import 'transaction_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = '', email = '';
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final loadedName = await StorageService.getName();
    final loadedEmail = await StorageService.getEmail();
    if (!mounted) return;
    setState(() {
      name = loadedName ?? 'User';
      email = loadedEmail ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppThemes.mint,
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: AppThemes.forest,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(email),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          _SectionLabel('Account'),
          _Option(
            icon: Icons.history,
            title: 'Transaction history',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TransactionHistoryScreen(),
              ),
            ),
          ),
          _Option(
            icon: Icons.security_outlined,
            title: 'Privacy & security',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacySecurityScreen()),
            ),
          ),
          const SizedBox(height: 20),
          _SectionLabel('Preferences'),
          Card(
            child: SwitchListTile(
              secondary: Icon(
                dark ? Icons.dark_mode : Icons.light_mode,
                color: AppThemes.forest,
              ),
              title: const Text('Dark mode'),
              subtitle: Text(
                dark ? 'Comfortable for low light' : 'Use the light appearance',
              ),
              value: dark,
              onChanged: (_) => ThemeService.toggleTheme(),
            ),
          ),
          const SizedBox(height: 28),
          OutlinedButton.icon(
            onPressed: () async {
              await StorageService.logout();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppThemes.red,
              side: const BorderSide(color: AppThemes.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10, left: 4),
    child: Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: AppThemes.muted,
        letterSpacing: 1,
      ),
    ),
  );
}

class _Option extends StatelessWidget {
  const _Option({required this.icon, required this.title, required this.onTap});
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
      leading: Icon(icon, color: AppThemes.forest),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}
