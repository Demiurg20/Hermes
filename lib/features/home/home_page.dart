import 'package:flutter/material.dart';
import '/core/api/api_service.dart';
import '/core/api/token_storage.dart';
import '../cars/car.dart';
import '/features/auth/presentation/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final api = ApiService();
  List<Car> cars = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCars();
  }

  Future<void> loadCars() async {
    try {
      final data = await api.getCars();
      cars = data.map<Car>((e) => Car.fromJson(e)).toList();
    } catch (_) {}

    setState(() => isLoading = false);
  }

  Future<void> logout() async {
    await TokenStorage.clearToken();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hermes Cars"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: cars.length,
              itemBuilder: (context, index) {
                final car = cars[index];
                return ListTile(
                  leading: Image.network(car.image, width: 60),
                  title: Text(car.name),
                  subtitle: Text("\$${car.price}"),
                );
              },
            ),
    );
  }
}