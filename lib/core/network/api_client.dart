import 'package:dio/dio.dart';

class ApiClient {
  static const _baseUrl = 'https://api.yourapp.com/v1'; // TODO: replace with real base URL

  static Dio create() {
    final dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (_) {},
    ));

    return dio;
  }
}
