import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/app_feature.dart';

abstract class FeatureRepository {
  Future<Either<Failure, List<AppFeature>>> getFeatures();
  Future<Either<Failure, AppFeature>> toggleFeature(String featureId, bool isEnabled);
  Future<Either<Failure, void>> saveFeatures(List<AppFeature> features);
}
