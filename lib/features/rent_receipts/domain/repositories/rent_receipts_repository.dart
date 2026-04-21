import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/rent_receipt.dart';

abstract class RentReceiptsRepository {
  Future<Either<Failure, List<RentReceipt>>> fetchRentReceipts();
  Future<Either<Failure, String>> downloadRentReceipt(String id);
}
