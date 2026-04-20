import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/onboarding_slide.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_data_source.dart';
import '../datasources/onboarding_remote_data_source.dart';
import '../models/onboarding_slide_model.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingRemoteDataSource remoteDataSource;
  final OnboardingLocalDataSource localDataSource;

  OnboardingRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<OnboardingSlide>>> getSlides() async {
    // 1. Try remote — cache on success.
    try {
      final slides = await remoteDataSource.getSlides();
      await localDataSource.cacheSlides(slides);
      return Right(slides);
    } on NetworkFailure {
      // fall through to cache
    }

    // 2. Fall back to cache.
    try {
      final cached = await localDataSource.getCachedSlides();
      return Right(cached);
    } on CacheFailure {
      // fall through to hardcoded defaults
    }

    // 3. Use hardcoded defaults so onboarding always works offline.
    return Right(OnboardingSlideModel.defaults);
  }

  @override
  Future<Either<Failure, void>> markOnboardingComplete() async {
    try {
      await localDataSource.setOnboardingComplete();
      return const Right(null);
    } catch (_) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> hasCompletedOnboarding() async {
    try {
      final done = await localDataSource.isOnboardingComplete();
      return Right(done);
    } catch (_) {
      return Left(CacheFailure());
    }
  }
}
