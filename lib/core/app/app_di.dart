import '../api/api_service.dart';
import 'package:hermes/core/data/car_repository.dart';
import 'package:hermes/core/data/booking_repository.dart';

class AppDI {
  // завтра тут будет ApiService(baseUrl, tokenStorage)
  static final api = ApiService();

  // переключатель (сейчас мок, завтра api)
  static const bool useMock = false;

  // static CarRepository get carRepo => useMock ? MockCarRepository() : ApiCarRepository(api);

  static CarRepository get carRepo =>
      useMock ? MockCarRepository() : ApiCarRepository(api);

  static final bookingRepo = BookingRepository(api);
}