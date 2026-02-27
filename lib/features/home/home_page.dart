import 'package:flutter/material.dart';
import '/core/theme/app_colors.dart';
import '/core/api/token_storage.dart';
import '/features/auth/presentation/login_page.dart';
import '/features/profile/edit_profile_page.dart';
import '/features/cars/select_car_page.dart';
import '../cars/car.dart';

const bool useMockCars = true;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Car> cars = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCars();
  }

  Future<void> loadCars() async {
    await Future.delayed(const Duration(seconds: 1));

    cars = [
      Car(
        id: 1,
        name: "Tesla Model 3",
        image:
        "https://images.unsplash.com/photo-1560958089-b8a1929cea89",
        price: 15,
        rating: 4.9,
        type: "Electric",
      ),
      Car(
        id: 2,
        name: "BMW 5 Series",
        image:
        "https://images.unsplash.com/photo-1502877338535-766e1452684a",
        price: 22,
        rating: 4.8,
        type: "Hybrid",
      ),
      Car(
        id: 3,
        name: "Mercedes C-Class",
        image:
        "https://images.unsplash.com/photo-1549924231-f129b911e442",
        price: 20,
        rating: 4.7,
        type: "Petrol",
      ),
    ];

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
                        children: const [
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

                  /// ✏ EDIT PROFILE
                  IconButton(
                    icon: const Icon(Icons.edit,
                        color: AppColors.primary),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const EditProfilePage(),
                        ),
                      );
                    },
                  )
                ],
              ),

              const SizedBox(height: 20),

              /// 🔍 SEARCH
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.input,
                  borderRadius:
                  BorderRadius.circular(16),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.search,
                        color: AppColors.greyText),
                    hintText: "Search cars...",
                    hintStyle: TextStyle(
                        color: AppColors.greyText),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// 💳 BALANCE CARD
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.input,
                  borderRadius:
                  BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Your Balance",
                          style: TextStyle(
                              color:
                              AppColors.greyText),
                        ),
                        ElevatedButton(
                          style:
                          ElevatedButton.styleFrom(
                            backgroundColor:
                            AppColors.primary,
                          ),
                          onPressed: () {},
                          child: const Text(
                            "+ TOP UP",
                            style: TextStyle(
                                color: Colors.black),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "\$150.00",
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight:
                          FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// 📍 LOCATION
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.input,
                  borderRadius:
                  BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.location_on,
                        color: AppColors.primary),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Pickup location",
                          style: TextStyle(
                              color:
                              AppColors.greyText),
                        ),
                        Text(
                          "Moscow City Center",
                          style: TextStyle(
                              fontWeight:
                              FontWeight.bold),
                        ),
                      ],
                    )
                  ],
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
                        fontWeight:
                        FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              SelectCarPage(
                                  cars: cars),
                        ),
                      );
                    },
                    child: const Text(
                      "View all",
                      style: TextStyle(
                          color:
                          AppColors.primary),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 10),

              ...cars.map((car) => Container(
                margin: const EdgeInsets.only(
                    bottom: 15),
                padding:
                const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.input,
                  borderRadius:
                  BorderRadius.circular(
                      16),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius:
                      BorderRadius
                          .circular(12),
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
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          Text(
                            car.name,
                            style:
                            const TextStyle(
                                fontWeight:
                                FontWeight
                                    .bold),
                          ),
                          const SizedBox(
                              height: 4),
                          Text(
                            "${car.rating}  •  ${car.type}",
                            style: const TextStyle(
                                color:
                                AppColors
                                    .greyText),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "\$${car.price}/hour",
                      style: const TextStyle(
                        color:
                        AppColors.primary,
                        fontWeight:
                        FontWeight.bold,
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