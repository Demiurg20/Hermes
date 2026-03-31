import 'dart:ui';

import 'package:hermes/core/api/api_service.dart';
import 'package:hermes/features/cars/car.dart';

abstract class CarRepository {
  Future<List<Car>> getCars();
  Future<Car> getCarById(String id);
}

/// API-backed repository (wire real endpoints tomorrow)
class ApiCarRepository implements CarRepository {
  ApiCarRepository(this._api);

  final ApiService _api;

  @override
  Future<List<Car>> getCars() async {
    final raw = await _api.getCarsBackend();
    return raw
        .whereType<Map>()
        .map((e) => Car.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<Car> getCarById(String id) async {
    final m = await _api.getCarByIdBackend(id);
    return Car.fromJson(m);
  }
}

class MockCarRepository implements CarRepository {
  @override
  Future<List<Car>> getCars() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    return const [
      Car(
        id: 'car_1',
        brand: 'TESLA',
        model: 'Model 3',
        rating: 4.9,
        imageUrl:
        'https://cdn.jdpower.com/ArticleImages/JDP_2025%20Tesla%20Model%203%20Long%20Range%20Rear-Wheel%20Drive%20Stealth%20Gray%20Front%20Quarter%20View.JPG',
        seats: 5,
        fuel: 'Electric',
        type: 'Auto',
        year: 2024,
        features: ['Autopilot', 'Premium Audio', 'Heated Seats', 'Navigation'],
        pricePerHour: 15,
        pricePerDay: 89,
        accentColor: Color(0xFFD6A34A),
      ),
      Car(
        id: 'car_2',
        brand: 'BMW',
        model: '5 Series',
        rating: 4.8,
        imageUrl:
        'https://s.auto.drom.ru/i24286/c/photos/fullsize/bmw/5-series/bmw_5-series_1163958.jpg',
        seats: 5,
        fuel: 'Hybrid',
        type: 'Auto',
        year: 2023,
        features: ['Heated Seats', 'Navigation'],
        pricePerHour: 22,
        pricePerDay: 129,
        accentColor: Color(0xFFD6A34A),
      ),
      Car(
        id: 'car_3',
        brand: 'Ford',
        model: 'Explorer',
        rating: 5.0,
        imageUrl:
        'https://avatars.mds.yandex.net/get-verba/216201/2a0000016a2046a941f97a2fce152dfc3d26/auto_main',
        seats: 7,
        fuel: 'Petrol',
        type: 'Auto',
        year: 2020,
        features: ['Cruise Control', 'Bluetooth'],
        pricePerHour: 20,
        pricePerDay: 119,
        accentColor: Color(0xFFD6A34A),
      ),
    ];
  }

  @override
  Future<Car> getCarById(String id) async {
    final cars = await getCars();
    return cars.firstWhere(
          (c) => c.id == id,
      orElse: () => cars.first,
    );
  }
}