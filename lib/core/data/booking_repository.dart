import 'package:hermes/core/api/api_service.dart';
import 'package:hermes/core/models/booking_request.dart';

class BookingRepository {
  BookingRepository(this._api);
  final ApiService _api;

  /// Создание бронирования
  Future<String> createBooking(BookingRequest request) async {
    final raw = await _api.createBookingBackend(request.toJson());

    final normalized = raw is Map && raw["data"] != null ? raw["data"] : raw;
    if (normalized is Map) {
      final id = normalized["id"] ??
          normalized["bookingId"] ??
          normalized["_id"] ??
          normalized["booking_id"];
      final idStr = id?.toString();
      if (idStr == null || idStr.isEmpty) {
        throw StateError('Booking created, but id is missing in response: $normalized');
      }
      return idStr;
    }

    throw StateError('Unexpected createBooking response: $raw');
  }

  /// 🔥 ОБНОВЛЕНО: Начало поездки (Confirm) с двумя фото
  /// Переименовал в confirmBooking, чтобы в ReturnCarScreen не было ошибки
  Future<void> confirmBooking(String bookingId, List<int> img1, List<int> img2) async {
    // Вызываем метод API, который мы обновили ранее
    await _api.clientConfirmBackend(bookingId, img1, img2);
  }

  /// 🔥 ОБНОВЛЕНО: Возврат машины с двумя фото
  Future<void> clientReturn(String bookingId, List<int> img1, List<int> img2) async {
    await _api.clientReturnBackend(bookingId, img1, img2);
  }

  /// Методы для владельца (Owner)
  Future<bool> ownerReturn(String bookingId) async {
    final raw = await _api.ownerReturnBackend(bookingId);
    return _extractSuccessBool(raw);
  }

  Future<bool> ownerConfirm(String bookingId) async {
    final raw = await _api.ownerConfirmBackend(bookingId);
    return _extractSuccessBool(raw);
  }

  Future<bool> ownerCancel(String bookingId) async {
    final raw = await _api.ownerCancelBackend(bookingId);
    return _extractSuccessBool(raw);
  }

  /// Получение заявок для владельца
  Future<List<dynamic>> getOwnerRequests() async {
    final raw = await _api.getOwnerRequestsBackend();
    if (raw is Map && raw["data"] is List) return raw["data"];
    if (raw is List) return raw;
    return const [];
  }

  /// Получение своих бронирований (для клиента)
  Future<List<dynamic>> getMyBookings() async {
    final raw = await _api.getMyBookingsBackend();
    if (raw is Map && raw["data"] is List) return raw["data"];
    if (raw is List) return raw;
    return const [];
  }

  /// 🔥 ПОЛУЧЕНИЕ СПИСКА ОЖИДАЮЩИХ ПОДТВЕРЖДЕНИЯ (Start Trip)
  Future<List<dynamic>> getMyBookingsPending() async {
    final dynamic raw = await _api.getMyBookingsPending(); // Получаем dynamic

    // Проверяем: если это Map, значит можем искать ключ "data"
    if (raw is Map<String, dynamic> && raw["data"] is List) {
      return raw["data"];
    }

    // Если это сразу список (List)
    if (raw is List) {
      return raw;
    }

    return const [];
  }

  Future<List<dynamic>> getMyBookingsConfirmed() async {
    final dynamic raw = await _api.getMyBookingsConfirmed();

    // 🔥 ДОБАВЬ ЭТОТ ПРИНТ
    print("DEBUG CONFIRMED API: $raw");

    if (raw is Map<String, dynamic> && raw["data"] is List) {
      return raw["data"];
    }
    if (raw is List) {
      return raw;
    }
    return const [];
  }

  bool _extractSuccessBool(dynamic raw) {
    if (raw is Map) {
      final success = raw["success"] ?? raw["ok"] ?? raw["status"] ?? raw["message"];
      if (success is bool) return success;
      if (success is String) {
        final s = success.toLowerCase();
        if (s.contains('success') || s.contains('ok') || s.contains('confirmed') || s.contains('completed')) {
          return true;
        }
      }
    }
    return raw != null;
  }
}