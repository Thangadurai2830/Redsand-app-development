import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_feature.dart';
import '../repositories/feature_repository.dart';

class SaveFeatures implements UseCase<void, SaveFeaturesParams> {
  final FeatureRepository repository;

  SaveFeatures(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveFeaturesParams params) =>
      repository.saveFeatures(params.features);
}

class SaveFeaturesParams {
  final List<AppFeature> features;
  const SaveFeaturesParams({required this.features});
}
