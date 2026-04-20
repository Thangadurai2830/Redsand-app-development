import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/app_feature.dart';
import '../../domain/repositories/feature_repository.dart';
import '../datasources/feature_local_data_source.dart';

class FeatureRepositoryImpl implements FeatureRepository {
  final FeatureLocalDataSource dataSource;

  FeatureRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<AppFeature>>> getFeatures() async {
    try {
      final features = await dataSource.getFeatures();
      return Right(features);
    } catch (_) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, AppFeature>> toggleFeature(String featureId, bool isEnabled) async {
    try {
      final feature = await dataSource.toggleFeature(featureId, isEnabled);
      return Right(feature);
    } catch (_) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveFeatures(List<AppFeature> features) async {
    try {
      await dataSource.saveFeatures(features);
      return const Right(null);
    } catch (_) {
      return Left(CacheFailure());
    }
  }
}
