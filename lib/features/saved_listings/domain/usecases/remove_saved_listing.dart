import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/saved_listings_repository.dart';

class RemoveSavedListing {
  final SavedListingsRepository repository;

  RemoveSavedListing(this.repository);

  Future<Either<Failure, void>> call(String listingId) {
    return repository.removeSavedListing(listingId);
  }
}
