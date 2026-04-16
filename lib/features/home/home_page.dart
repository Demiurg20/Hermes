import 'package:flutter/material.dart';
import 'package:hermes/features/cars/return_car_page.dart'; // Убедись, что путь верный
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
  List<dynamic> activeBookings = []; // Список активных бронирований

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
    _initialLoad();
  }

  /// Первичная загрузка всех данных
  Future<void> _initialLoad() async {
    setState(() => isLoading = true);
    await Future.wait([
      loadCars(),
      loadUser(),
      loadBookings(), // Загружаем брони
    ]);
    setState(() => isLoading = false);
  }

  /// ФУНКЦИЯ ДЛЯ ОБНОВЛЕНИЯ (Refresh)
  Future<void> _onRefresh() async {
    await _initialLoad();
  }

  /// 🚗 LOAD CARS
  Future<void> loadCars() async {
    try {
      final loaded = await AppDI.carRepo.getCars().timeout(const Duration(seconds: 10));
      cars = loaded;
      filteredCars = loaded;
    } catch (e) {
      debugPrint('Failed to load cars: $e');
      loadError = e.toString();
    }
  }

  /// 👤 LOAD USER
  Future<void> loadUser() async {
    try {
      final user = await AppDI.userRepo.getUserInfo();
      if (mounted) {
        setState(() {
          userName = user.name;
          balance = user.balance;
          isUserLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isUserLoading = false);
    }
  }

  /// 📦 LOAD BOOKINGS
  Future<void> loadBookings() async {
    try {
      final allBookings = await AppDI.bookingRepo.getMyBookings();
      // Фильтруем только те, которые можно начать или вернуть
      activeBookings = allBookings.where((b) {
        final status = b["status"];
        return status == "PENDING" || status == "CONFIRMED" || status == "ACTIVE";
      }).toList();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Failed to load bookings: $e");
    }
  }

  void filterCars(String query) {
    final results = cars.where((car) {
      return car.name.toLowerCase().contains(query.toLowerCase()) ||
          car.type.toLowerCase().contains(query.toLowerCase());
    }).toList();
    setState(() => filteredCars = results);
  }

  Future<void> logout() async {
    await TokenStorage.clearToken();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: isLoading && cars.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _onRefresh,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 10),
                _buildHeader(),
                const SizedBox(height: 20),
                _buildSearch(),
                const SizedBox(height: 20),
                _buildBalanceCard(),

                // 🔥 НОВАЯ СЕКЦИЯ: ACTIVE BOOKINGS
                if (activeBookings.isNotEmpty) ...[
                  const SizedBox(height: 25),
                  const Text("My Active Trips", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildBookingList(),
                ],

                const SizedBox(height: 25),
                _buildPopularHeader(),
                const SizedBox(height: 10),
                _buildCarList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Виджет списка забронированных машин
  Widget _buildBookingList() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: activeBookings.length,
        itemBuilder: (context, index) {
          final booking = activeBookings[index];
          final bool isActive = booking["status"] == "ACTIVE";

          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 15),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "${booking["carBrand"]} ${booking["carModel"]}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isActive ? "ACTIVE" : "READY",
                        style: TextStyle(color: isActive ? Colors.green : Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: AppColors.greyText),
                    const SizedBox(width: 6),
                    Text(booking["startDate"].toString().substring(0, 10), style: const TextStyle(color: AppColors.greyText, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),

                // КНОПКА START / RETURN
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      // Переходим на экран фото
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReturnCarScreen(
                            bookingData: booking,
                            isStartingTrip: !isActive, // Если не активна — значит начинаем
                          ),
                        ),
                      );

                      if (result == true) {
                        _onRefresh(); // Обновляем данные, если поездка началась
                      }
                    },
                    child: Text(
                      isActive ? "Return Car" : "Start Trip",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Вспомогательные методы билда (вынес для чистоты кода) ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          // 👈 Нажатие на всю левую часть (аватар + имя) ведет в профиль
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfilePage()),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.input,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "WELCOME BACK",
                    style: TextStyle(
                        fontSize: 10,
                        color: AppColors.greyText,
                        letterSpacing: 1.1),
                  ),
                  Row(
                    children: [
                      isUserLoading
                          ? const Text("Loading...",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold))
                          : Text(
                        userName ?? "User",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      // 👈 Маленькая иконка карандаша рядом с именем
                      const Icon(Icons.edit_note_rounded,
                          color: AppColors.primary, size: 18),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
          onPressed: () => logout(),
        )
      ],
    );
  }

  Widget _buildSearch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: AppColors.input, borderRadius: BorderRadius.circular(16)),
      child: TextField(
        controller: searchController,
        onChanged: filterCars,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          icon: Icon(Icons.search, color: AppColors.greyText),
          hintText: "Search cars...",
          hintStyle: TextStyle(color: AppColors.greyText),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BalanceTopUpPage())),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.input, AppColors.input.withOpacity(0.7)]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Your Balance", style: TextStyle(color: AppColors.greyText)),
            const SizedBox(height: 10),
            isUserLoading
                ? const Text("Loading...", style: TextStyle(fontSize: 24))
                : Text("\$${balance.toStringAsFixed(2)}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Popular Cars", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SelectCarPage(cars: cars))),
          child: const Text("View all", style: TextStyle(color: AppColors.primary)),
        ),
      ],
    );
  }

  Widget _buildCarList() {
    if (filteredCars.isEmpty) return const Center(child: Text("No cars found"));
    return Column(
      children: filteredCars
          .map((car) => Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.input, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(car.image, width: 80, height: 50, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.directions_car)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(car.name, style: const TextStyle(fontWeight: FontWeight.bold))),
            Text("\$${car.price}/h", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ],
        ),
      ))
          .toList(),
    );
  }
}