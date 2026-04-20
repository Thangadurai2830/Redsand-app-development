import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_feature.dart';
import '../repositories/feature_repository.dart';

class ToggleFeature implements UseCase<AppFeature, ToggleFeatureParams> {
  final FeatureRepository repository;

  ToggleFeature(this.repository);

  @override
  Future<Either<Failure, AppFeature>> call(ToggleFeatureParams params) =>
      repository.toggleFeature(params.featureId, params.isEnabled);
}

class ToggleFeatureParams extends Equatable {
  final String featureId;
  final bool isEnabled;

  const ToggleFeatureParams({required this.featureId, required this.isEnabled});

  @override
  List<Object?> get props => [featureId, isEnabled];
}
