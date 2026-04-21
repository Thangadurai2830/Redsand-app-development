import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/rent_receipts_repository.dart';

class DownloadRentReceiptParams {
  final String id;

  const DownloadRentReceiptParams(this.id);
}

class DownloadRentReceipt {
  final RentReceiptsRepository repository;

  DownloadRentReceipt(this.repository);

  Future<Either<Failure, String>> call(DownloadRentReceiptParams params) {
    return repository.downloadRentReceipt(params.id);
  }
}
