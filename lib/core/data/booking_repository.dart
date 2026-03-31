import 'package:hermes/core/api/api_service.dart';

class BookingRepository {
  BookingRepository(this._api);
  final ApiService _api;

  // TODO: завтра: POST /bookings
  Future<String> createBooking({
    required String carId,
    required DateTime pickup,
    required DateTime dropoff,
    required String pickupLocation,
    required String dropoffLocation,
  }) async {
    throw UnimplementedError('createBooking not wired yet');
  }

  // TODO: завтра: POST /payments или /bookings/{id}/pay
  Future<bool> payBooking({
    required String bookingId,
    required String cardNumber,
    required String cardholder,
    required String expiry,
    required String cvc,
  }) async {
    throw UnimplementedError('payBooking not wired yet');
  }
}