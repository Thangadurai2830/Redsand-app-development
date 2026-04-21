import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/rent_receipt.dart';
import '../repositories/rent_receipts_repository.dart';

class GetRentReceipts {
  final RentReceiptsRepository repository;

  GetRentReceipts(this.repository);

  Future<Either<Failure, List<RentReceipt>>> call(NoParams params) {
    return repository.fetchRentReceipts();
  }
}
