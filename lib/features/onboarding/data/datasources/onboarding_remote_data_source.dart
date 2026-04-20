import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../models/onboarding_slide_model.dart';

abstract class OnboardingRemoteDataSource {
  Future<List<OnboardingSlideModel>> getSlides();
}

class OnboardingRemoteDataSourceImpl implements OnboardingRemoteDataSource {
  final Dio dio;

  OnboardingRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<OnboardingSlideModel>> getSlides() async {
    try {
      final response = await dio.get('/onboarding/slides');
      final data = response.data as List<dynamic>;
      return data
          .map((e) => OnboardingSlideModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException {
      throw NetworkFailure();
    }
  }
}
