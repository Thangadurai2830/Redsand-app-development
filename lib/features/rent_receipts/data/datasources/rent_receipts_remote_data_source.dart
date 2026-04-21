import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../models/rent_receipt_model.dart';

abstract class RentReceiptsRemoteDataSource {
  Future<List<RentReceiptModel>> fetchRentReceipts();
  Future<String> downloadRentReceipt(String id);
}

class RentReceiptsRemoteDataSourceImpl implements RentReceiptsRemoteDataSource {
  final Dio dio;

  RentReceiptsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<RentReceiptModel>> fetchRentReceipts() async {
    final response = await dio.get('/api/user/rent-receipts');
    return _extractCollection(response.data).map(RentReceiptModel.fromJson).toList();
  }

  @override
  Future<String> downloadRentReceipt(String id) async {
    final response = await dio.get(
      '/api/user/rent-receipts/$id/download',
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    final payload = response.data;
    final bytes = _asBytes(payload);
    if (bytes != null && bytes.isNotEmpty) {
      final downloadsDir = await Directory.systemTemp.createTemp('rent_receipts_');
      final fileName = _fileNameForResponse(response, id);
      final file = File('${downloadsDir.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    }

    if (payload is Map<String, dynamic>) {
      final candidate = payload['download_url'] ?? payload['url'] ?? payload['file_url'] ?? payload['path'];
      if (candidate is String && candidate.trim().isNotEmpty) {
        final downloadUrl = candidate.trim();
        if (downloadUrl.startsWith('http')) {
          final tempDir = await Directory.systemTemp.createTemp('rent_receipts_');
          final filePath = '${tempDir.path}/${_safeFileName('rent_receipt_$id')}.pdf';
          await dio.download(downloadUrl, filePath);
          return filePath;
        }
        return downloadUrl;
      }
    }

    throw const FormatException('Unable to download rent receipt');
  }

  List<Map<String, dynamic>> _extractCollection(Object? payload) {
    if (payload is List) {
      return payload.whereType<Map<String, dynamic>>().toList();
    }
    if (payload is Map<String, dynamic>) {
      final candidate = payload['data'] ??
          payload['receipts'] ??
          payload['items'] ??
          payload['rent_receipts'] ??
          payload['records'];
      if (candidate is List) {
        return candidate.whereType<Map<String, dynamic>>().toList();
      }
    }
    return const [];
  }

  Uint8List? _asBytes(Object? payload) {
    if (payload is Uint8List) return payload;
    if (payload is List<int>) return Uint8List.fromList(payload);
    return null;
  }

  String _fileNameForResponse(Response<dynamic> response, String id) {
    final disposition = response.headers.value('content-disposition');
    if (disposition != null) {
      final match = RegExp(r'filename="?([^";]+)"?').firstMatch(disposition);
      final candidate = match?.group(1);
      if (candidate != null && candidate.trim().isNotEmpty) {
        return _safeFileName(candidate.trim());
      }
    }
    return _safeFileName('rent_receipt_$id.pdf');
  }

  String _safeFileName(String name) {
    return name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }
}
