import 'package:dio/dio.dart';

import '../models/owner_analytics_model.dart';
import '../models/owner_buyer_interest_model.dart';
import '../models/owner_dashboard_json.dart';
import '../models/owner_listing_model.dart';

abstract class OwnerDashboardRemoteDataSource {
  Future<List<OwnerListingModel>> getListings();
  Future<List<OwnerBuyerInterestModel>> getInterests();
  Future<OwnerAnalyticsModel> getAnalytics();
  Future<void> boostListing(String listingId);
}

class OwnerDashboardRemoteDataSourceImpl implements OwnerDashboardRemoteDataSource {
  final Dio dio;

  OwnerDashboardRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<OwnerListingModel>> getListings() async {
    final response = await dio.get('/api/owner/listings');
    final payload = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : <String, dynamic>{'data': response.data};
    return unwrapList(payload).map(OwnerListingModel.fromJson).toList(growable: false);
  }

  @override
  Future<List<OwnerBuyerInterestModel>> getInterests() async {
    final response = await dio.get('/api/owner/interests');
    final payload = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : <String, dynamic>{'data': response.data};
    return unwrapList(payload).map(OwnerBuyerInterestModel.fromJson).toList(growable: false);
  }

  @override
  Future<OwnerAnalyticsModel> getAnalytics() async {
    final response = await dio.get('/api/owner/analytics');
    final payload = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : <String, dynamic>{'data': response.data};
    return OwnerAnalyticsModel.fromJson(payload);
  }

  @override
  Future<void> boostListing(String listingId) async {
    await dio.post('/api/owner/listings/$listingId/boost');
  }
}

