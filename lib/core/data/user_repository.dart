import '../api/api_service.dart';
import 'package:hermes/features/home/user.dart';

class UserRepository {
  final ApiService api;

  UserRepository(this.api);

  Future<User> getUserInfo() async {
    try {
      final data = await api.getUserInfo();
      return User.fromJson(data);
    } catch (e) {
      throw Exception('Failed to load user: $e');
    }
  }

  /// Метод для обновления баланса
  Future<void> updateBalance(double newBalance) async {
    try {
      // Вызываем именно тот метод, который мы добавили в ApiService
      await api.updateBalanceBackend(newBalance);
    } catch (e) {
      throw Exception('Failed to update balance: $e');
    }
  }
}