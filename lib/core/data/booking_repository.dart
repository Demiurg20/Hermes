import 'package:hermes/core/api/api_service.dart';
import 'package:hermes/core/models/booking_request.dart';

class BookingRepository {
  BookingRepository(this._api);
  final ApiService _api;

  /// Creates a booking using backend contract:
  /// carId, pickUpLocationId, dropOffLocationId, startDate, endDate (ISO 8601).
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

  Future<bool> clientReturn(String bookingId) async {
    final raw = await _api.clientReturnBackend(bookingId);
    return _extractSuccessBool(raw);
  }

  Future<bool> clientConfirm(String bookingId) async {
    final raw = await _api.clientConfirmBackend(bookingId);
    return _extractSuccessBool(raw);
  }

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

  Future<List<dynamic>> getOwnerRequests() async {
    final raw = await _api.getOwnerRequestsBackend();
    if (raw is Map && raw["data"] is List) return raw["data"];
    if (raw is List) return raw;
    return const [];
  }

  Future<List<dynamic>> getMyBookings() async {
    final raw = await _api.getMyBookingsBackend();
    if (raw is Map && raw["data"] is List) return raw["data"];
    if (raw is List) return raw;
    return const [];
  }

  bool _extractSuccessBool(dynamic raw) {
    // Backend может вернуть {success: true} или просто текст/объект.
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