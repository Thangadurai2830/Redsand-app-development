import 'package:dio/dio.dart';

import '../models/site_visit_request_model.dart';

abstract class ScheduleVisitRemoteDataSource {
  Future<String> scheduleVisit(SiteVisitRequestModel request);
}

class ScheduleVisitRemoteDataSourceImpl implements ScheduleVisitRemoteDataSource {
  final Dio dio;

  ScheduleVisitRemoteDataSourceImpl({required this.dio});

  @override
  Future<String> scheduleVisit(SiteVisitRequestModel request) async {
    final response = await dio.post(
      '/api/user/site-visits',
      data: request.toJson(),
    );

    final data = response.data;
    if (data is String && data.trim().isNotEmpty) {
      return data;
    }
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['detail'] ?? data['status'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
      final nested = data['data'];
      if (nested is Map<String, dynamic>) {
        final nestedMessage = nested['message'] ?? nested['detail'] ?? nested['status'];
        if (nestedMessage is String && nestedMessage.trim().isNotEmpty) {
          return nestedMessage;
        }
      }
    }

    return 'Owner notified';
  }
}
