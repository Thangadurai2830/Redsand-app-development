import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/site_visit_request.dart';
import '../../domain/repositories/schedule_visit_repository.dart';
import '../datasources/schedule_visit_remote_data_source.dart';
import '../models/site_visit_request_model.dart';

class ScheduleVisitRepositoryImpl implements ScheduleVisitRepository {
  final ScheduleVisitRemoteDataSource remoteDataSource;

  ScheduleVisitRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, String>> scheduleVisit(SiteVisitRequest request) async {
    try {
      final message = await remoteDataSource.scheduleVisit(
        SiteVisitRequestModel.fromEntity(request),
      );
      return Right(message);
    } on DioException {
      return Left(NetworkFailure());
    } catch (_) {
      return Left(NetworkFailure());
    }
  }
}
