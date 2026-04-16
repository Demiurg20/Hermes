import '../api/api_service.dart';
import 'package:hermes/core/data/car_repository.dart';
import 'package:hermes/core/data/booking_repository.dart';
import 'package:hermes/core/data/user_repository.dart';
// Убедись, что путь к LocationRepository верный
import 'package:hermes/core/data/location_repository.dart';

class AppDI {
  // 1. Единый экземпляр API сервиса для всего приложения
  static final ApiService api = ApiService();

  // Переключатель (мок / реальный API)
  static const bool useMock = false;

  // 2. Инициализируем репозитории как "ленивые" синглтоны
  // Это значит, что они создадутся один раз и будут жить в памяти

  /// 🚗 Cars Repository
  static final CarRepository carRepo = useMock
      ? MockCarRepository()
      : ApiCarRepository(api);

  /// 👤 User Repository
  static final UserRepository userRepo = UserRepository(api);

  /// 📦 Booking Repository
  static final BookingRepository bookingRepo = BookingRepository(api);

  /// 📍 Location Repository
  static final LocationRepository locationRepo = LocationRepository(api);

  // Дополнительно: метод для очистки данных при логауте (если понадобится)
  static void reset() {
    // Здесь можно сбросить состояние, если используешь GetIt или сложные кэши
  }
}