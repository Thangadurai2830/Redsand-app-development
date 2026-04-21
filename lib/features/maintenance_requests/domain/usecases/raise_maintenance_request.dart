import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/maintenance_request.dart';
import '../entities/maintenance_ticket.dart';
import '../repositories/maintenance_repository.dart';

class RaiseMaintenanceRequest {
  final MaintenanceRepository repository;

  RaiseMaintenanceRequest(this.repository);

  Future<Either<Failure, MaintenanceTicket>> call(MaintenanceRequest request) {
    return repository.raiseMaintenanceRequest(request);
  }
}
