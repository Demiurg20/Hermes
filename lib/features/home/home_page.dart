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
  int balance = 0;
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
          balance = user.balance.toInt();
          isUserLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isUserLoading = false);
    }
  }

  /// 📦 LOAD BOOKINGS
  /// 📦 LOAD BOOKINGS (Updated for two endpoints)
  Future<void> loadBookings() async {
    try {
      // Запускаем оба запроса одновременно для скорости
      final results = await Future.wait([
        AppDI.bookingRepo.getMyBookingsPending(),   // Машины для старта
        AppDI.bookingRepo.getMyBookingsConfirmed(), // Машины для возврата
      ]);

      final List<dynamic> pendingBookings = results[0];
      final List<dynamic> confirmedBookings = results[1];

      // Объединяем их в один общий список активных поездок
      final List<dynamic> combined = [...pendingBookings, ...confirmedBookings];

      if (mounted) {
        setState(() {
          activeBookings = combined;
        });
        debugPrint("Total active trips loaded: ${activeBookings.length}");
      }
    } catch (e) {
      debugPrint("Failed to load bookings from new endpoints: $e");
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

  Widget _buildBookingList() {
    return SizedBox(
      height: 165, // Немного увеличим высоту для комфорта
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: activeBookings.length,
        itemBuilder: (context, index) {
          final booking = activeBookings[index];
          // Если статус ACTIVE — машина уже у пользователя, нужно "Вернуть"
          // Если статус CONFIRMED или PENDING — машина ждет старта
// Получаем статус и переводим в верхний регистр для надежности
          final String status = (booking["status"] ?? "").toString().toUpperCase();

// ТЕПЕРЬ ЛОГИКА ТАКАЯ:
// Если статус CONFIRMED — значит машина уже в поездке и её можно вернуть.
          final bool isActive = status == "CONFIRMED";

// Если статус PENDING — значит это новая бронь, которую надо подтвердить (Start).
          final bool isPending = status == "PENDING";

          return Container(
            width: 300,
            margin: const EdgeInsets.only(right: 15),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.green.withOpacity(0.05) // Зеленоватый фон для активной поездки
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                  color: isActive
                      ? Colors.green.withOpacity(0.3)
                      : AppColors.primary.withOpacity(0.3)
              ),
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
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(status),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 14, color: Colors.white.withOpacity(0.5)),
                    const SizedBox(width: 6),
                    Text(
                      isActive ? "Trip in progress..." : "Waiting for pick-up",
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // УНИВЕРСАЛЬНАЯ КНОПКА
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isActive ? Colors.white : AppColors.primary,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                      onPressed: () async {
                        // 1. Получаем актуальный статус из объекта бронирования
                        final String currentStatus = (booking["status"] ?? "").toString().toUpperCase();

                        // Согласно логике бэкенда:
                        // PENDING — машину нужно подтвердить (Start Journey)
                        // CONFIRMED — машина в пути, её можно вернуть (Return Car)
                        final bool isPending = currentStatus == "PENDING";
                        final bool isConfirmed = currentStatus == "CONFIRMED";

                        debugPrint("--- NAVIGATION: Открываю камеру для брони #${booking['id']} (Статус: $currentStatus) ---");

                        // 2. Открываем экран фотографий
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReturnCarScreen(
                              bookingData: booking,
                              // Если статус PENDING, значит мы начинаем поездку (isStartingTrip = true)
                              isStartingTrip: isPending,
                            ),
                          ),
                        );

                        debugPrint("--- NAVIGATION: Вернулся с экрана. Успех: $result ---");

                        // 3. Если фото успешно отправлены и бэкенд ответил OK
                        if (result == true) {
                          // Небольшая пауза, чтобы база данных на сервере успела обновиться
                          await Future.delayed(const Duration(milliseconds: 800));

                          if (mounted) {
                            debugPrint("--- ACTION: Обновляю данные на главной странице ---");
                            // Вызываем обновление обоих списков (Pending + Confirmed)
                            await _onRefresh();

                            // Выводим красивое уведомление в зависимости от того, что мы сделали
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: Colors.white),
                                    const SizedBox(width: 12),
                                    Text(
                                      isPending
                                          ? "Journey started! Drive safely."
                                          : "Car returned successfully!",
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                backgroundColor: isPending ? Colors.blueAccent : Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          }
                        }
                      },
                    child: Text(
                      isActive ? "Finish & Return Car" : "Start Trip & Take Photos",
                      style: const TextStyle(fontWeight: FontWeight.w900),
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

  // Вспомогательный виджет для красивого статуса
  Widget _buildStatusBadge(String status) {
    bool isActive = status == "ACTIVE";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        isActive ? "IN USE" : "READY",
        style: TextStyle(
            color: isActive ? Colors.green : Colors.orange,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5
        ),
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
                : Text("\$${balance}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary)),
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