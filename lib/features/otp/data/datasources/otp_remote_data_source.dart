import 'package:dio/dio.dart';
import '../../../auth/data/models/auth_token_model.dart';

abstract class OtpRemoteDataSource {
  Future<AuthTokenModel> verifyOtp({required String email, required String otp});
  Future<bool> resendOtp(String email);
}

class OtpRemoteDataSourceImpl implements OtpRemoteDataSource {
  final Dio dio;

  OtpRemoteDataSourceImpl({required this.dio});

  @override
  Future<AuthTokenModel> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final response = await dio.post(
      '/api/auth/verify-otp',
      data: {'email': email, 'otp': otp},
    );
    return AuthTokenModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<bool> resendOtp(String email) async {
    final response = await dio.post(
      '/api/auth/resend-otp',
      data: {'email': email},
    );
    return response.statusCode == 200;
  }
}
