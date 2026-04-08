import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'login_screen.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  Icon(
                    Icons.person_add,
                    size: 60,
                    color: theme.colorScheme.primary,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Name
                  buildInputField(
                    context: context,
                    controller: nameController,
                    hint: "Full Name",
                    icon: Icons.person,
                  ),

                  const SizedBox(height: 20),

                  // Email
                  buildInputField(
                    context: context,
                    controller: emailController,
                    hint: "Email",
                    icon: Icons.email,
                  ),

                  const SizedBox(height: 20),

                  // Password
                  buildInputField(
                    context: context,
                    controller: passwordController,
                    hint: "Password",
                    icon: Icons.lock,
                    isPassword: true,
                  ),

                  const SizedBox(height: 30),

                  // Signup Button
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
                        String name = nameController.text.trim();
                        String email = emailController.text.trim();
                        String password = passwordController.text;

                        if (name.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please enter your full name"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // Email format validation
                        final emailRegex = RegExp(
                          r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                        );
                        if (email.isEmpty || !emailRegex.hasMatch(email)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Please enter a valid email address (e.g., user@gmail.com)",
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        if (password.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Password must be at least 6 characters",
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        var result = await ApiService.register(
                          name,
                          email,
                          password,
                        );

                        print(result);

                        if (result["message"] ==
                            "User Registered Successfully") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Account Created Successfully"),
                            ),
                          );

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                result["message"] ?? "Signup Failed",
                              ),
                            ),
                          );
                        }
                      },

                      child: const Text(
                        "Create Account",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Back to login
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: Text(
                      "Already have an account? Login",
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
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
        hintStyle: TextStyle(
          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
        ),

        prefixIcon: Icon(
          icon,
          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
        ),

        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.black.withOpacity(0.05),

        contentPadding: const EdgeInsets.symmetric(vertical: 16),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
