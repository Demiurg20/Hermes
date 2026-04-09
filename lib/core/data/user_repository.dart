import '../api/api_service.dart';
import 'package:hermes/features/home/user.dart';

class UserRepository {
  final ApiService api;

  UserRepository(this.api);

  Future<User> getUserInfo() async {
    try {
      final data = await api.getUserInfo(); // ✅ уже правильно

      return User.fromJson(data);
    } catch (e) {
      throw Exception('Failed to load user: $e');
    }
  }
}