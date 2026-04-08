import 'package:flutter/material.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool isBiometricEnabled = false;
  bool isTwoFactorEnabled = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Privacy & Security"),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader("Account Security", theme),
          const SizedBox(height: 10),
          _buildSettingsTile(
            theme: theme,
            icon: Icons.password,
            title: "Change Password",
            subtitle: "Update your login password securely",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Change Password functionality coming soon!")),
              );
            },
          ),
          
          _buildSwitchTile(
            theme: theme,
            icon: Icons.security,
            title: "Two-Factor Authentication",
            subtitle: "Add an extra layer of security",
            value: isTwoFactorEnabled,
            onChanged: (val) {
              setState(() {
                isTwoFactorEnabled = val;
              });
            },
          ),

          const SizedBox(height: 20),
          _buildSectionHeader("App Lock", theme),
          const SizedBox(height: 10),
          
          _buildSwitchTile(
            theme: theme,
            icon: Icons.fingerprint,
            title: "Biometric Login",
            subtitle: "Use fingerprint or face ID to unlock",
            value: isBiometricEnabled,
            onChanged: (val) {
              setState(() {
                isBiometricEnabled = val;
              });
            },
          ),
          
          const SizedBox(height: 20),
          _buildSectionHeader("Legal", theme),
          const SizedBox(height: 10),

          _buildSettingsTile(
            theme: theme,
            icon: Icons.policy,
            title: "Privacy Policy",
            subtitle: "Read our privacy guidelines",
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: theme.cardColor,
                  title: Text("Privacy Policy", style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
                  content: Text(
                    "Your data is safe with LogixLeap. We do not sell your personal information.",
                    style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Close", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Text(
      title,
      style: TextStyle(
        color: theme.colorScheme.primary,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSettingsTile({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))
        ]
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        title: Text(title, style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 13)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: theme.textTheme.bodyMedium?.color),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))
        ]
      ),
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        title: Text(title, style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 13)),
        value: value,
        activeThumbColor: theme.colorScheme.primary,
        onChanged: onChanged,
      ),
    );
  }
}
