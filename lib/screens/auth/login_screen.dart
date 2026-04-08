import 'package:flutter/material.dart';
import '../main_screen.dart';
import 'signup_screen.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../admin/admin_dashboard_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  size: 60,
                  color: theme.colorScheme.primary,
                ),

                const SizedBox(height: 20),

                Text(
                  "Welcome Back",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),

                const SizedBox(height: 40),

                // EMAIL FIELD
                buildInputField(
                  context: context,
                  controller: emailController,
                  hint: "Email",
                  icon: Icons.email,
                ),

                const SizedBox(height: 20),

                // PASSWORD FIELD
                buildInputField(
                  context: context,
                  controller: passwordController,
                  hint: "Password",
                  icon: Icons.lock,
                  isPassword: true,
                ),

                const SizedBox(height: 30),

                // LOGIN BUTTON
                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    onPressed: () async {
                      String email = emailController.text.trim();
                      String password = passwordController.text;

                      // Email format validation
                      final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                      if (email.isEmpty || !emailRegex.hasMatch(email)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please enter a valid email address"),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please enter your password"),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      var result = await ApiService.login(email, password);

                      print(result);

                      if (result["token"] != null) {
                        String role = result["user"]["role"] ?? "user";
                        await StorageService.saveUserData(
                          result["token"],
                          result["user"]["_id"],
                          result["user"]["name"],
                          result["user"]["email"] ?? email,
                          role,
                        );

                        if (role == "admin") {
                          // We will create this screen next
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const MainScreen()),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result["message"] ?? "Login Failed"),
                          ),
                        );
                      }
                    },

                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // GO TO SIGNUP SCREEN
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    );
                  },

                  child: Text(
                    "Don't have an account? Sign up",
                    style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInputField({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: TextStyle(color: theme.textTheme.bodyLarge?.color),

      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),

        prefixIcon: Icon(icon, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),

        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),

        contentPadding: const EdgeInsets.symmetric(vertical: 16),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
