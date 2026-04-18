import 'package:flutter/material.dart';
import 'package:hermes/core/app/app_di.dart'; // Путь к твоему DI
import '../../../core/theme/app_colors.dart';
import '../cars/car.dart';
import 'car_details_page.dart';
import 'add_car_page.dart';

class SelectCarPage extends StatefulWidget {
  final List<Car> initialCars; // Принимаем начальный список

  const SelectCarPage({super.key, required this.initialCars});

  @override
  State<SelectCarPage> createState() => _SelectCarPageState();
}

class _SelectCarPageState extends State<SelectCarPage> {
  late List<Car> cars;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Инициализируем список данными, которые пришли при открытии
    cars = widget.initialCars;
  }

  /// 🔄 ФУНКЦИЯ ОБНОВЛЕНИЯ (Pull-to-Refresh и после добавления)
  Future<void> _refreshCars() async {
    setState(() => _isLoading = true);

    try {
      // Здесь вызываешь свой метод загрузки машин. Пример:
      // final updatedCars = await AppDI.api.getAllCars();

      // Имитация загрузки (замени на реальный запрос к бэкенду)
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        // cars = updatedCars; // Обновляем список данными с сервера
        _isLoading = false;
      });

      debugPrint("Список машин обновлен");
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Ошибка при обновлении: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Select a Car"),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          // Кнопка обновления в шапке (опционально)
          IconButton(
            onPressed: _refreshCars,
            icon: const Icon(Icons.refresh, color: Colors.white),
          )
        ],
      ),

      /// 👈 REFRESH INDICATOR (позволяет тянуть список вниз)
      body: RefreshIndicator(
        onRefresh: _refreshCars,
        color: AppColors.primary,
        backgroundColor: AppColors.card,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          // Чтобы RefreshIndicator работал даже если список пустой,
          // добавляем AlwaysScrollableScrollPhysics
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: cars.length,
          itemBuilder: (context, index) {
            final car = cars[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      car.image,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 180,
                        color: Colors.white10,
                        child: const Icon(Icons.directions_car, color: Colors.white24, size: 50),
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      car.name,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "\$${car.price}/day",
                      style: const TextStyle(color: AppColors.primary),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CarDetailsScreen(carId: car.id),
                        ),
                      );
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 16, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          car.rating.toString(),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCarPage()),
          );

          // 🔥 Если машина успешно добавлена (результат true), обновляем список автоматически
          if (result == true) {
            _refreshCars();
          }
        },
        child: const Icon(Icons.add, color: Colors.black, size: 30),
      ),
    );
  }
}