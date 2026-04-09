import 'package:flutter/material.dart';
import '/core/theme/app_colors.dart';
import '/core/api/token_storage.dart';
import '/core/app/app_di.dart';
import '/features/auth/presentation/login_page.dart';
import '/features/profile/profile_page.dart';
import '/features/cars/select_car_page.dart';
import 'balance_topup_page.dart';
import '../cars/car.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Car> cars = [];
  List<Car> filteredCars = [];

  bool isLoading = true;
  String? loadError;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadCars();
  }

  Future<void> loadCars() async {
    setState(() {
      isLoading = true;
      loadError = null;
    });

    try {
      final loaded = await AppDI.carRepo.getCars().timeout(
        const Duration(seconds: 10),
      );
      cars = loaded;
      filteredCars = loaded;
    } catch (e) {
      debugPrint('Failed to load cars: $e');
      cars = const [];
      filteredCars = const [];
      loadError = e.toString();
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void filterCars(String query) {
    final results = cars.where((car) {
      return car.name.toLowerCase().contains(query.toLowerCase()) ||
          car.type.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredCars = results;
    });
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
      backgroundColor: AppColors.background,
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      )
          : SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            children: [

              const SizedBox(height: 10),

              /// 👤 HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      CircleAvatar(radius: 22),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            "WELCOME BACK",
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.greyText),
                          ),
                          Text(
                            "Anarbekov A.",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit,
                        color: AppColors.primary),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const ProfilePage(),
                        ),
                      );
                    },
                  )
                ],
              ),

              const SizedBox(height: 20),

              /// 🔍 SEARCH
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.input,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: filterCars,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    icon: Icon(Icons.search,
                        color: AppColors.greyText),
                    hintText: "Search cars...",
                    hintStyle:
                    TextStyle(color: AppColors.greyText),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// 💳 BALANCE (tap to top up)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BalanceTopUpPage(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.input,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Your Balance",
                        style: TextStyle(
                          color: AppColors.greyText,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "\$150.00",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Popular Cars",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SelectCarPage(cars: cars),
                      ),
                    );
                  },
                  child: const Text(
                    "View all",
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),

              const SizedBox(height: 10),
              if (filteredCars.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        loadError == null
                            ? "No cars loaded"
                            : "Failed to load cars:\n$loadError",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => loadCars(),
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              else
                ...filteredCars.map((car) => Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.input,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              car.image,
                              width: 90,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  car.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${car.rating} • ${car.type}",
                                  style: const TextStyle(
                                    color: AppColors.greyText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "\$${car.price}/hour",
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}