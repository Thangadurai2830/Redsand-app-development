import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/failures.dart';
import '../models/auth_token_model.dart';

abstract class AuthLocalDataSource {
  Future<AuthTokenModel?> getToken();
  Future<void> saveToken(AuthTokenModel token);
  Future<void> deleteToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const _tokenKey = 'auth_token';

  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<AuthTokenModel?> getToken() async {
    final json = sharedPreferences.getString(_tokenKey);
    if (json == null) return null;
    try {
      return AuthTokenModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      throw CacheFailure();
    }
  }

  @override
  Future<void> saveToken(AuthTokenModel token) async {
    await sharedPreferences.setString(_tokenKey, jsonEncode(token.toJson()));
  }

  @override
  Future<void> deleteToken() async {
    await sharedPreferences.remove(_tokenKey);
  }
}
