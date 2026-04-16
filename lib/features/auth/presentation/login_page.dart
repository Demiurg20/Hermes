import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:hermes/core/api/token_storage.dart';
import 'package:hermes/core/widgets/auth_button.dart';
import 'package:hermes/core/widgets/auth_textfield.dart';
import 'package:hermes/core/theme/app_colors.dart';
import 'package:hermes/features/home/home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "https://ungrudging-carson-nonvituperatively.ngrok-free.dev",
      headers: {
        "Content-Type": "application/json",
      },
    ),
  );

  bool isLoading = false;

  Future<void> login() async {

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter email and password")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {

      final response = await dio.post(
        "/api/auth/login",
        data: {
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        },
      );

      print("LOGIN RESPONSE: ${response.data}");
      final token = response.data["token"];

      await TokenStorage.saveTokens(response.data["token"], response.data["refreshToken"]);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login failed")),
      );

    } finally {

      if (mounted) {
        setState(() => isLoading = false);
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              "DAI AUTO",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
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