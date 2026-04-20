import 'package:dio/dio.dart';
import '../models/register_request_model.dart';

abstract class RegisterRemoteDataSource {
  Future<String> register(RegisterRequestModel request);
}

class RegisterRemoteDataSourceImpl implements RegisterRemoteDataSource {
  final Dio dio;

  RegisterRemoteDataSourceImpl({required this.dio});

  @override
  Future<String> register(RegisterRequestModel request) async {
    final response = await dio.post(
      '/api/auth/register',
      data: request.toJson(),
    );
    return response.data['message'] as String? ?? 'OTP sent';
  }
}
