import 'package:dio/dio.dart';

import '../../domain/entities/kyc_submission_request.dart';
import '../../domain/entities/profile_update_request.dart';
import '../models/site_visit_record_model.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> fetchProfile();
  Future<UserProfileModel> updateProfile(ProfileUpdateRequest request);
  Future<String> submitKycDocuments(KycSubmissionRequest request);
  Future<List<SiteVisitRecordModel>> fetchSiteVisits();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserProfileModel> fetchProfile() async {
    final response = await dio.get('/api/user');
    return UserProfileModel.fromJson(_asMap(response.data));
  }

  @override
  Future<UserProfileModel> updateProfile(ProfileUpdateRequest request) async {
    final response = await dio.patch(
      '/api/user/profile',
      data: request.toJson(),
    );
    return UserProfileModel.fromJson(_asMap(response.data));
  }

  @override
  Future<String> submitKycDocuments(KycSubmissionRequest request) async {
    final response = await dio.post(
      '/api/user/kyc',
      data: request.toJson(),
    );
    final data = response.data;
    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['detail'] ?? data['status'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    }
    return 'KYC documents submitted successfully';
  }

  @override
  Future<List<SiteVisitRecordModel>> fetchSiteVisits() async {
    final response = await dio.get('/api/user/site-visits');
    final data = response.data;
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(SiteVisitRecordModel.fromJson)
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is List) {
        return nested
            .whereType<Map<String, dynamic>>()
            .map(SiteVisitRecordModel.fromJson)
            .toList();
      }
    }
    return <SiteVisitRecordModel>[];
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    return const <String, dynamic>{};
  }
}
