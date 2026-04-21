import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/saved_listing_entity.dart';
import '../repositories/saved_listings_repository.dart';

class GetSavedListings {
  final SavedListingsRepository repository;

  GetSavedListings(this.repository);

  Future<Either<Failure, List<SavedListingEntity>>> call() {
    return repository.getSavedListings();
  }
}
