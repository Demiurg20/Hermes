import 'package:flutter/material.dart';
import '../data/car_repository.dart';
import 'package:hermes/features/cars/car.dart';

class CarDetailsController extends ChangeNotifier {
  CarDetailsController({required this.repo});

  final CarRepository repo;

  Car? car;
  bool isLoading = false;
  String? error;

  Future<void> load(String carId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      car = await repo.getCarById(carId);
    } catch (e) {
      error = '$e';
      debugPrint(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}