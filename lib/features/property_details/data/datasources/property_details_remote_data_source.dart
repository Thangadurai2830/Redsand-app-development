import 'package:dio/dio.dart';

abstract class PropertyDetailsRemoteDataSource {
  Future<void> saveListing(String listingId);
  Future<void> revealContact(String listingId);
}

class PropertyDetailsRemoteDataSourceImpl implements PropertyDetailsRemoteDataSource {
  final Dio dio;

  PropertyDetailsRemoteDataSourceImpl({required this.dio});

  @override
  Future<void> saveListing(String listingId) async {
    await dio.post(
      '/api/user/saved-listings',
      data: {'listing_id': listingId},
    );
  }

  @override
  Future<void> revealContact(String listingId) async {
    await dio.post('/api/listings/$listingId/contact-reveal');
  }
}
