import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthInterceptor extends Interceptor {
  static const _tokenKey = 'auth_token';

  final SharedPreferences sharedPreferences;

  AuthInterceptor({required this.sharedPreferences});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final json = sharedPreferences.getString(_tokenKey);
    if (json != null) {
      try {
        final map = jsonDecode(json) as Map<String, dynamic>;
        final token = map['access_token'] as String?;
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      } catch (_) {}
    }
    handler.next(options);
  }
}
