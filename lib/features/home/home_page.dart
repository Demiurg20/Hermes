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

  /// 👤 USER
  String? userName;
  double balance = 0;
  bool isUserLoading = true;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadCars();
    loadUser(); // 🔥 добавили
  }

  /// 🚗 LOAD CARS
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

  /// 👤 LOAD USER (NAME + BALANCE)
  Future<void> loadUser() async {
    try {
      final user = await AppDI.userRepo.getUserInfo();

      setState(() {
        userName = user.name;        // ⚠️ проверь поле
        balance = user.balance;     // ⚠️ проверь поле
        isUserLoading = false;
      });
    } catch (e) {
      debugPrint("Failed to load user: $e");
      setState(() {
        userName = "User";
        balance = 0;
        isUserLoading = false;
      });
    }
  }

  /// 🔍 FILTER
  void filterCars(String query) {
    final results = cars.where((car) {
      return car.name.toLowerCase().contains(query.toLowerCase()) ||
          car.type.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredCars = results;
    });
  }

  /// 🚪 LOGOUT
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
                    children: [
                      const CircleAvatar(radius: 22),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "WELCOME BACK",
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.greyText),
                          ),
                          isUserLoading
                              ? const Text(
                            "Loading...",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                              : Text(
                            userName ?? "User",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.primary),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfilePage(),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Logout"),
                              content: const Text("Are you sure you want to logout?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Logout"),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await logout();
                          }
                        },
                      ),
                    ],
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

              /// 💳 BALANCE
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const BalanceTopUpPage(),
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
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Your Balance",
                        style: TextStyle(
                          color: AppColors.greyText,
                        ),
                      ),
                      const SizedBox(height: 10),
                      isUserLoading
                          ? const Text(
                        "Loading...",
                        style: TextStyle(fontSize: 24),
                      )
                          : Text(
                        "\$${balance.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /// 🚗 POPULAR CARS
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
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
                          builder: (_) =>
                              SelectCarPage(cars: cars),
                        ),
                      );
                    },
                    child: const Text(
                      "View all",
                      style: TextStyle(
                          color: AppColors.primary),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              if (filteredCars.isEmpty)
                const Text("No cars found")
              else
                ...filteredCars.map((car) => Container(
                  margin:
                  const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.input,
                    borderRadius:
                    BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Image.network(
                        car.image,
                        width: 90,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(car.name),
                      ),
                      Text(
                        "\$${car.price}/h",
                        style: const TextStyle(
                          color: AppColors.primary,
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