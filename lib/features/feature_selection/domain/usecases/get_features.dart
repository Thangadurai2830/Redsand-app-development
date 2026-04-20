import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_feature.dart';
import '../repositories/feature_repository.dart';

class GetFeatures implements UseCase<List<AppFeature>, NoParams> {
  final FeatureRepository repository;

  GetFeatures(this.repository);

  @override
  Future<Either<Failure, List<AppFeature>>> call(NoParams params) =>
      repository.getFeatures();
}
