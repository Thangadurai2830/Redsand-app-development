import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../models/auth_token_model.dart';

abstract class AuthRemoteDataSource {
  Future<bool> sendOtp(String email);
  Future<AuthTokenModel> loginWithGoogle(String idToken);
  Future<AuthTokenModel> login(String email, String password, {String? role});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<bool> sendOtp(String email) async {
    try {
      final response = await dio.post(
        '/api/auth/send-otp',
        data: {'email': email},
      );
      return response.statusCode == 200;
    } on DioException {
      throw NetworkFailure();
    }
  }

  @override
  Future<AuthTokenModel> loginWithGoogle(String idToken) async {
    try {
      final response = await dio.post(
        '/api/auth/google',
        data: {'id_token': idToken},
      );
      return AuthTokenModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      throw NetworkFailure();
    }
  }

  @override
  Future<AuthTokenModel> login(String email, String password, {String? role}) async {
    try {
      final response = await dio.post(
        '/api/auth/login',
        data: {
          'email': email,
          'password': password,
          if (role != null) 'role': role,
        },
      );
      return AuthTokenModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      throw NetworkFailure();
    }
  }
}
