import 'package:flutter/material.dart';
import '/core/api/api_service.dart';
import '/core/api/token_storage.dart';
import '/core/widgets/auth_button.dart';
import '/core/widgets/auth_textfield.dart';
import '/core/theme/app_colors.dart';
import '/features/home/home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final api = ApiService();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> login() async {
    setState(() => isLoading = true);

    try {
      final token = await api.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      await TokenStorage.saveToken(token);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login failed")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const CircleAvatar(
              radius: 35,
              backgroundColor: AppColors.primary,
              child: Text(
                "DA",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              "DAI AUTO",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const Text(
              "Premium Car Sharing",
              style: TextStyle(color: AppColors.greyText),
            ),

            const SizedBox(height: 40),

            AuthTextField(
              controller: emailController,
              hint: "your@email.com",
              icon: Icons.email_outlined,
            ),

            const SizedBox(height: 16),

            AuthTextField(
              controller: passwordController,
              hint: "Enter password",
              icon: Icons.lock_outline,
              isPassword: true,
            ),

            const SizedBox(height: 24),

            AuthButton(
              text: "Sign In",
              onPressed: login,
              isLoading: isLoading,
            ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                );
              },
              child: const Text(
                "Create Account",
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}