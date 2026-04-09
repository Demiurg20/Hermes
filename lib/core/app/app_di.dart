import '../api/api_service.dart';
import 'package:hermes/core/data/car_repository.dart';
import 'package:hermes/core/data/booking_repository.dart';
import 'package:hermes/core/data/location_repository.dart';
import 'package:hermes/core/data/user_repository.dart'; // 👈 ДОБАВЬ

class AppDI {
  // API
  static final api = ApiService();

  // переключатель (мок / реальный API)
  static const bool useMock = false;

  /// 🚗 Cars
  static CarRepository get carRepo =>
      useMock ? MockCarRepository() : ApiCarRepository(api);

  /// 👤 USER (НОВОЕ)
  static final UserRepository userRepo = UserRepository(api);

  /// 📦 Booking
  static final bookingRepo = BookingRepository(api);

  /// 📍 Location
  static final locationRepo = LocationRepository(api);
}