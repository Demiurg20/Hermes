import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextInputType? keyboardType; // 👈 1. Добавили поле для типа клавиатуры

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.keyboardType, // 👈 2. Добавили в конструктор
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      // 3. Используем переданный тип клавиатуры (по умолчанию текстовая)
      keyboardType: widget.keyboardType ?? TextInputType.text,
      obscureText: widget.isPassword ? obscure : false,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: const TextStyle(color: AppColors.greyText),
        filled: true,
        fillColor: AppColors.input, // Убедись, что этот цвет есть в AppColors
        prefixIcon: Icon(widget.icon, color: AppColors.greyText),
        suffixIcon: widget.isPassword
            ? IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: AppColors.greyText,
          ),
          onPressed: () {
            setState(() {
              obscure = !obscure;
            });
          },
        )
            : null,
        // Добавил скругление углов, чтобы смотрелось современнее
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }
}