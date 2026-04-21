import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/saved_listing_entity.dart';

abstract class SavedListingsRepository {
  Future<Either<Failure, List<SavedListingEntity>>> getSavedListings();
  Future<Either<Failure, void>> removeSavedListing(String listingId);
}
