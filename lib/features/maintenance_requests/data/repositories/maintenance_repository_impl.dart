import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/maintenance_request.dart';
import '../../domain/entities/maintenance_ticket.dart';
import '../../domain/repositories/maintenance_repository.dart';
import '../datasources/maintenance_local_data_source.dart';
import '../datasources/maintenance_remote_data_source.dart';
import '../models/maintenance_request_model.dart';

class MaintenanceRepositoryImpl implements MaintenanceRepository {
  final MaintenanceRemoteDataSource remoteDataSource;
  final MaintenanceLocalDataSource localDataSource;

  MaintenanceRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, MaintenanceTicket>> raiseMaintenanceRequest(MaintenanceRequest request) async {
    try {
      final ticket = await remoteDataSource.raiseMaintenanceRequest(
        MaintenanceRequestModel.fromEntity(request),
      );
      return Right(ticket);
    } on DioException {
      return Left(NetworkFailure());
    } catch (_) {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<MaintenanceTicket>>> fetchMaintenanceHistory() async {
    try {
      final tickets = await remoteDataSource.fetchMaintenanceHistory();
      return Right(tickets);
    } on DioException {
      try {
        return Right(await localDataSource.fetchMaintenanceHistory());
      } catch (_) {
        return Left(CacheFailure());
      }
    } catch (_) {
      try {
        return Right(await localDataSource.fetchMaintenanceHistory());
      } catch (_) {
        return Left(CacheFailure());
      }
    }
  }
}
