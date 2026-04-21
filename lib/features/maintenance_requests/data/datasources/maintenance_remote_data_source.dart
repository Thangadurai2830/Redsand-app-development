import 'dart:io';

import 'package:dio/dio.dart';

import '../models/maintenance_request_model.dart';
import '../models/maintenance_ticket_model.dart';

abstract class MaintenanceRemoteDataSource {
  Future<MaintenanceTicketModel> raiseMaintenanceRequest(MaintenanceRequestModel request);
  Future<List<MaintenanceTicketModel>> fetchMaintenanceHistory();
}

class MaintenanceRemoteDataSourceImpl implements MaintenanceRemoteDataSource {
  final Dio dio;

  MaintenanceRemoteDataSourceImpl({required this.dio});

  @override
  Future<MaintenanceTicketModel> raiseMaintenanceRequest(MaintenanceRequestModel request) async {
    final photoPath = request.photoPath?.trim();
    if (photoPath != null && photoPath.startsWith('http')) {
      final response = await dio.post(
        '/api/user/maintenance',
        data: {
          'issue_type': request.issueType,
          'description': request.description,
          'photo_url': photoPath,
        },
      );
      return _parseCreatedTicket(response.data, request);
    }
    if (photoPath != null && photoPath.isNotEmpty && File(photoPath).existsSync()) {
      final response = await dio.post(
        '/api/user/maintenance',
        data: FormData.fromMap({
          'issue_type': request.issueType,
          'description': request.description,
          'photo': await MultipartFile.fromFile(photoPath),
        }),
      );
      return _parseCreatedTicket(response.data, request);
    }

    final response = await dio.post(
      '/api/user/maintenance',
      data: request.toJson(),
    );
    return _parseCreatedTicket(response.data, request);
  }

  @override
  Future<List<MaintenanceTicketModel>> fetchMaintenanceHistory() async {
    final response = await dio.get('/api/user/maintenance');
    return _extractCollection(response.data)
        .map(MaintenanceTicketModel.fromJson)
        .toList();
  }

  MaintenanceTicketModel _parseCreatedTicket(
    Object? payload,
    MaintenanceRequestModel request,
  ) {
    if (payload is Map<String, dynamic>) {
      final nested = payload['data'];
      if (nested is Map<String, dynamic>) {
        return MaintenanceTicketModel.fromJson(nested);
      }

      final message = payload['message'];
      if (message is String && message.trim().isNotEmpty) {
        return MaintenanceTicketModel.fromRequest(request: request);
      }

      return MaintenanceTicketModel.fromJson(payload);
    }

    return MaintenanceTicketModel.fromRequest(request: request);
  }

  List<Map<String, dynamic>> _extractCollection(Object? payload) {
    if (payload is List) {
      return payload.whereType<Map<String, dynamic>>().toList();
    }
    if (payload is Map<String, dynamic>) {
      final candidate = payload['data'] ?? payload['tickets'] ?? payload['items'] ?? payload['maintenance_requests'];
      if (candidate is List) {
        return candidate.whereType<Map<String, dynamic>>().toList();
      }
    }
    return const [];
  }
}
