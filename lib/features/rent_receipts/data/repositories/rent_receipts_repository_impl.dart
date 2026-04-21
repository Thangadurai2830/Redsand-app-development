import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/rent_receipt.dart';
import '../../domain/repositories/rent_receipts_repository.dart';
import '../datasources/rent_receipts_local_data_source.dart';
import '../datasources/rent_receipts_remote_data_source.dart';

class RentReceiptsRepositoryImpl implements RentReceiptsRepository {
  final RentReceiptsRemoteDataSource remoteDataSource;
  final RentReceiptsLocalDataSource localDataSource;

  RentReceiptsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<RentReceipt>>> fetchRentReceipts() async {
    try {
      final receipts = await remoteDataSource.fetchRentReceipts();
      return Right(receipts);
    } on DioException {
      try {
        return Right(await localDataSource.fetchRentReceipts());
      } catch (_) {
        return Left(CacheFailure());
      }
    } catch (_) {
      try {
        return Right(await localDataSource.fetchRentReceipts());
      } catch (_) {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, String>> downloadRentReceipt(String id) async {
    try {
      final path = await remoteDataSource.downloadRentReceipt(id);
      return Right(path);
    } on DioException {
      return Left(NetworkFailure());
    } catch (_) {
      return Left(NetworkFailure());
    }
  }
}
