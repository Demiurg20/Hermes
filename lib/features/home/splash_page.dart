import 'package:flutter/material.dart';
import '/core/api/token_storage.dart';
import '/core/theme/app_colors.dart';
import '/features/auth/presentation/login_page.dart';
import 'home_page.dart';

/// 🔥 ВКЛ / ВЫКЛ MOCK режима
/// true  → всегда открывает Login (для демонстрации)
/// false → работает реальная проверка токена
const bool useMockLogin = false;

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  Future<void> checkAuth() async {

    // Небольшая задержка для красивого splash
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    /// 🧪 MOCK режим
    if (useMockLogin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }

    /// 🌐 Реальная проверка токена
    final token = await TokenStorage.getToken();

    if (token != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            CircleAvatar(
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

            SizedBox(height: 12),

            Text(
              "DAI AUTO",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 6),

            Text(
              "Premium Car Sharing",
              style: TextStyle(
                color: AppColors.greyText,
              ),
            ),

            SizedBox(height: 30),

            CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}