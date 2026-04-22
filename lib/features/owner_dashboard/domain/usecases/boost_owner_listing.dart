import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/owner_dashboard_repository.dart';

class BoostOwnerListing implements UseCase<void, String> {
  final OwnerDashboardRepository repository;

  BoostOwnerListing(this.repository);

  @override
  Future<Either<Failure, void>> call(String listingId) {
    return repository.boostListing(listingId);
  }
}

