import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/owner_buyer_interest_entity.dart';
import '../repositories/owner_dashboard_repository.dart';

class GetOwnerInterests implements UseCase<List<OwnerBuyerInterestEntity>, NoParams> {
  final OwnerDashboardRepository repository;

  GetOwnerInterests(this.repository);

  @override
  Future<Either<Failure, List<OwnerBuyerInterestEntity>>> call(NoParams params) {
    return repository.getInterests();
  }
}

