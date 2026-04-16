import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();

  // Ключи для хранения в зашифрованном виде
  static const _tokenKey = "jwt_token";
  static const _refreshTokenKey = "refresh_token";

  /// 💾 СОХРАНЕНИЕ: Записываем оба токена (Access и Refresh)
  static Future<void> saveTokens(String? token, String? refreshToken) async {
    if (token != null) {
      await _storage.write(key: _tokenKey, value: token);
    }
    if (refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  /// 🔑 ПОЛУЧЕНИЕ ACCESS: Для обычных запросов
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// 🔄 ПОЛУЧЕНИЕ REFRESH: Для обновления пары токенов в ApiService
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// 🚪 ОЧИСТКА: При логауте удаляем всё
  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}