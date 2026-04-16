import 'package:flutter/material.dart';
import 'package:hermes/core/theme/app_theme.dart';
import 'package:hermes/features/auth/presentation/login_page.dart';
import 'package:hermes/features/auth/presentation/register_page.dart';
import 'package:hermes/features/cars/add_car_page.dart';
import 'package:hermes/features/home/splash_page.dart';
import 'package:hermes/features/profile/driver_license_page.dart';
// import 'package:hermes/features/home/home_page.dart';
// import 'package:hermes/features/profile/edit_profile_page.dart';
// import 'package:hermes/features/cars/select_car_page.dart';

void main() {
  runApp(const HermesApp());
}

class HermesApp extends StatelessWidget {
  const HermesApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 Mock данные для теста страницы

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,

      // 🔥 Для теста SelectCarPage
      //home: SelectCarPage(cars: cars),

      home: const LoginPage(),
    );
  }
}