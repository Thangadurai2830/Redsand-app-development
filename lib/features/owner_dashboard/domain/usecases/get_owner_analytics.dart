import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/owner_analytics_entity.dart';
import '../repositories/owner_dashboard_repository.dart';

class GetOwnerAnalytics implements UseCase<OwnerAnalyticsEntity, NoParams> {
  final OwnerDashboardRepository repository;

  GetOwnerAnalytics(this.repository);

  @override
  Future<Either<Failure, OwnerAnalyticsEntity>> call(NoParams params) {
    return repository.getAnalytics();
  }
}

