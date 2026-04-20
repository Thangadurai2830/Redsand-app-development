import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/onboarding_slide.dart';

abstract class OnboardingRepository {
  /// Returns the three onboarding slides (from remote or cache).
  Future<Either<Failure, List<OnboardingSlide>>> getSlides();

  /// Persists the flag that the user has seen onboarding.
  Future<Either<Failure, void>> markOnboardingComplete();

  /// Returns true if the user has already completed onboarding.
  Future<Either<Failure, bool>> hasCompletedOnboarding();
}
