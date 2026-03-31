import 'package:dio/dio.dart';
import 'token_storage.dart';

class ApiService {
  late Dio dio;

  ApiService() {
    dio = Dio(
      BaseOptions(
        baseUrl:
        "https://ungrudging-carson-nonvituperatively.ngrok-free.dev/api",
        headers: {"Content-Type": "application/json"},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {

          final token = await TokenStorage.getToken();

          print("------ API REQUEST ------");
          print("URL: ${options.uri}");
          print("METHOD: ${options.method}");
          print("TOKEN: $token");

          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }

          print("HEADERS: ${options.headers}");

          return handler.next(options);
        },

        onResponse: (response, handler) {

          print("------ API RESPONSE ------");
          print("STATUS: ${response.statusCode}");
          print("DATA: ${response.data}");

          return handler.next(response);
        },

        onError: (DioException e, handler) {

          print("------ API ERROR ------");
          print("STATUS: ${e.response?.statusCode}");
          print("DATA: ${e.response?.data}");

          return handler.next(e);
        },
      ),
    );
  }

  /// 🔐 AUTH

  Future<String> login(String email, String password) async {
    final response = await dio.post(
      "/auth/login",
      data: {
        "email": email,
        "password": password,
      },
    );

    return response.data["token"];
  }

  Future<void> register(String email, String password) async {
    await dio.post(
      "/auth/register",
      data: {
        "email": email,
        "password": password,
      },
    );
  }

  /// 👤 PROFILE

  Future<void> addUserInfo(FormData formData) async {
    await dio.post(
      "/user/info/add",
      data: formData,
      options: Options(
        headers: {
          "Content-Type": "multipart/form-data",
        },
      ),
    );
  }

  Future<Map<String, dynamic>> getUserInfo() async {
    final response = await dio.get("/user/info/");

    print("PROFILE RESPONSE: ${response.data}");

    /// если backend возвращает {data: {...}}
    if (response.data is Map && response.data["data"] != null) {
      return Map<String, dynamic>.from(response.data["data"]);
    }

    return Map<String, dynamic>.from(response.data);
  }

  /// 🚗 CARS

  /// список машин
  Future<List<dynamic>> getCarsBackend() async {
    final response = await dio.get("/cars");

    final data = response.data;

    /// если backend вернул {data: []}
    if (data is Map && data["data"] is List) {
      return List<dynamic>.from(data["data"]);
    }

    /// если backend вернул просто []
    if (data is List) {
      return data;
    }

    return [];
  }

  /// машина по id
  Future<Map<String, dynamic>> getCarByIdBackend(String id) async {
    final response = await dio.get("/cars/$id");

    final data = response.data;

    /// если backend вернул {data: {...}}
    if (data is Map && data["data"] != null) {
      return Map<String, dynamic>.from(data["data"]);
    }

    return Map<String, dynamic>.from(data);
  }

  /// старый метод (можешь удалить потом)
  Future<List<dynamic>> getCars() async {
    return await getCarsBackend();
  }
}