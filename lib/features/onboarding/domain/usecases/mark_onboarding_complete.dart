import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/onboarding_repository.dart';

class MarkOnboardingComplete implements UseCase<void, NoParams> {
  final OnboardingRepository repository;

  MarkOnboardingComplete(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) =>
      repository.markOnboardingComplete();
}
