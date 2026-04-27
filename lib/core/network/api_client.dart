import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_interceptor.dart';

class ApiClient {
  static const _baseUrl = 'https://taunya-bonier-amelie.ngrok-free.dev';

  static Dio create({required SharedPreferences sharedPreferences}) {
    final dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    ));

    dio.interceptors.addAll([
      AuthInterceptor(sharedPreferences: sharedPreferences),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (_) {},
      ),
    ]);

    return dio;
  }
}
