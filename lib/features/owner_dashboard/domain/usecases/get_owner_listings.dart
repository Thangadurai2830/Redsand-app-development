import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/owner_listing_entity.dart';
import '../repositories/owner_dashboard_repository.dart';

class GetOwnerListings implements UseCase<List<OwnerListingEntity>, NoParams> {
  final OwnerDashboardRepository repository;

  GetOwnerListings(this.repository);

  @override
  Future<Either<Failure, List<OwnerListingEntity>>> call(NoParams params) {
    return repository.getListings();
  }
}

