import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/owner_analytics_entity.dart';
import '../entities/owner_buyer_interest_entity.dart';
import '../entities/owner_listing_entity.dart';

abstract class OwnerDashboardRepository {
  Future<Either<Failure, List<OwnerListingEntity>>> getListings();
  Future<Either<Failure, List<OwnerBuyerInterestEntity>>> getInterests();
  Future<Either<Failure, OwnerAnalyticsEntity>> getAnalytics();
  Future<Either<Failure, void>> boostListing(String listingId);
}

