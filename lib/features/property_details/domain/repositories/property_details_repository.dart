import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../home/domain/entities/listing_entity.dart';
import '../entities/property_details_entity.dart';

abstract class PropertyDetailsRepository {
  Future<Either<Failure, PropertyDetailsEntity>> getPropertyDetails(ListingEntity listing);
  Future<Either<Failure, void>> saveListing(String listingId);
  Future<Either<Failure, void>> revealContact(String listingId);
}
