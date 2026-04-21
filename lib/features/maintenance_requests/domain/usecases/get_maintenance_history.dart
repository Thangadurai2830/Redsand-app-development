import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/maintenance_ticket.dart';
import '../repositories/maintenance_repository.dart';

class GetMaintenanceHistory {
  final MaintenanceRepository repository;

  GetMaintenanceHistory(this.repository);

  Future<Either<Failure, List<MaintenanceTicket>>> call(NoParams params) {
    return repository.fetchMaintenanceHistory();
  }
}
