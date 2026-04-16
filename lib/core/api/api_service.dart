import 'package:dio/dio.dart';
import 'token_storage.dart';

class ApiService {
  late Dio dio;

  ApiService() {
    dio = Dio(
      BaseOptions(
        baseUrl: "https://ungrudging-carson-nonvituperatively.ngrok-free.dev/api",
        headers: {"Content-Type": "application/json"},
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Получаем токен из хранилища
          final token = await TokenStorage.getToken();
          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }

          print("------ API REQUEST: ${options.method} ${options.path} ------");
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print("------ API RESPONSE [${response.statusCode}] ------");
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          print("------ API ERROR [${e.response?.statusCode}] ------");

          // Логика автоматического обновления токена (Refresh Token)
          if (e.response?.statusCode == 401) {
            final refreshToken = await TokenStorage.getRefreshToken();
            if (refreshToken != null) {
              try {
                final refreshRes = await Dio().post(
                  "${dio.options.baseUrl}/auth/refresh-token",
                  data: {"refreshToken": refreshToken},
                );

                final newToken = refreshRes.data["token"];
                final newRefresh = refreshRes.data["refreshToken"];

                await TokenStorage.saveTokens(newToken, newRefresh);

                // Повторяем запрос с новым токеном
                e.requestOptions.headers["Authorization"] = "Bearer $newToken";
                final clonedRequest = await dio.request(
                  e.requestOptions.path,
                  options: Options(
                    method: e.requestOptions.method,
                    headers: e.requestOptions.headers,
                  ),
                  data: e.requestOptions.data,
                  queryParameters: e.requestOptions.queryParameters,
                );
                return handler.resolve(clonedRequest);
              } catch (_) {
                await TokenStorage.clearToken();
              }
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  /// 🔐 AUTH
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await dio.post("/auth/login", data: {
      "email": email,
      "password": password,
    });
    // Возвращаем Map, чтобы TokenStorage мог сохранить и токен, и рефреш-токен
    return response.data;
  }

  Future<void> register(String email, String password) async {
    await dio.post("/auth/register", data: {
      "email": email,
      "password": password,
      "role": "CLIENT",
    });
  }

  /// 👤 PROFILE
  Future<Map<String, dynamic>> getUserInfo() async {
    final response = await dio.get("/user/info/profile");
    if (response.data is Map && response.data["data"] != null) {
      return Map<String, dynamic>.from(response.data["data"]);
    }
    return Map<String, dynamic>.from(response.data);
  }

  /// 🚗 CARS
  Future<List<dynamic>> getCars() async {
    final response = await dio.get("/cars");
    final data = response.data;
    if (data is Map && data["data"] is List) return data["data"];
    if (data is List) return data;
    return [];
  }

  Future<dynamic> getLocationsBackend() async {
    final response = await dio.get('/locations');
    return response.data;
  }

  /// 📦 BOOKINGS (CLIENT)
  Future<dynamic> createBookingBackend(Map<String, dynamic> body) async {
    final response = await dio.post("/bookings", data: body);
    return response.data;
  }

  /// 🔥 ПОДТВЕРЖДЕНИЕ (START TRIP) С ФОТО
  Future<dynamic> clientConfirmBackend(String id, List<int> img1, List<int> img2) async {
    final formData = FormData.fromMap({
      "image1": MultipartFile.fromBytes(img1, filename: "front.jpg"),
      "image2": MultipartFile.fromBytes(img2, filename: "rear.jpg"),
    });

    final response = await dio.post(
      "/bookings/$id/client-confirm",
      data: formData,
    );
    return response.data;
  }

  /// 🔥 ВОЗВРАТ (RETURN CAR) С ФОТО
  Future<dynamic> clientReturnBackend(String id, List<int> img1, List<int> img2) async {
    final formData = FormData.fromMap({
      "image1": MultipartFile.fromBytes(img1, filename: "front.jpg"),
      "image2": MultipartFile.fromBytes(img2, filename: "rear.jpg"),
    });

    final response = await dio.post(
      "/bookings/$id/client-return",
      data: formData,
    );
    return response.data;
  }

  Future<dynamic> getMyBookingsBackend() async {
    final response = await dio.get("/bookings/my-bookings");
    return response.data;
  }

  /// 🛠 OWNER METHODS
  Future<dynamic> ownerConfirmBackend(String id) async {
    final response = await dio.patch("/bookings/$id/confirm");
    return response.data;
  }

  Future<dynamic> ownerReturnBackend(String id) async {
    final response = await dio.patch("/bookings/$id/return");
    return response.data;
  }

  Future<dynamic> ownerCancelBackend(String id) async {
    final response = await dio.patch("/bookings/$id/cancel");
    return response.data;
  }

  Future<dynamic> getOwnerRequestsBackend() async {
    final response = await dio.get("/bookings/owner-requests");
    return response.data;
  }

  /// Получение конкретной машины по ID с сервера
  Future<Map<String, dynamic>> getCarByIdBackend(String id) async {
    final response = await dio.get("/cars/$id");

    // Проверяем структуру ответа (иногда данные лежат в поле "data")
    if (response.data is Map && response.data["data"] != null) {
      return Map<String, dynamic>.from(response.data["data"]);
    }
    return Map<String, dynamic>.from(response.data);
  }

  /// Пополнение баланса (Top Up)
  Future<void> topUpBalance(double amount) async {
    await dio.post("/user/balance/topup", data: {"amount": amount});
  }

  /// Обновление профиля (Balance Update)
  Future<void> updateBalanceBackend(double newBalance) async {
    await dio.patch("/user/info/profile", data: {"balance": newBalance});
  }

  Future<void> addUserInfo(FormData formData) async {
    await dio.post("/user/info/add", data: formData);
  }
}