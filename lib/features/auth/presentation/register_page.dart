import 'package:flutter/material.dart';
import '/core/api/api_service.dart';
import '/core/widgets/auth_button.dart';
import '/core/widgets/auth_textfield.dart';
import '/core/theme/app_colors.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final api = ApiService();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;

  Future<void> register() async {

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await api.register(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created successfully")),
      );

    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration failed")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          child: Column(
            children: [

              const SizedBox(height: 30),

              const Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Join DAI AUTO today",
                style: TextStyle(
                  color: AppColors.greyText,
                ),
              ),

              const SizedBox(height: 40),

              AuthTextField(
                controller: nameController,
                hint: "John Doe",
                icon: Icons.person_outline,
              ),

              const SizedBox(height: 16),

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

              const SizedBox(height: 16),

              AuthTextField(
                controller: confirmPasswordController,
                hint: "Confirm password",
                icon: Icons.lock_outline,
                isPassword: true,
              ),

              const SizedBox(height: 24),

              AuthButton(
                text: "Create Account",
                onPressed: register,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}