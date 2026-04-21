import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/maintenance_request.dart';
import '../entities/maintenance_ticket.dart';

abstract class MaintenanceRepository {
  Future<Either<Failure, MaintenanceTicket>> raiseMaintenanceRequest(MaintenanceRequest request);
  Future<Either<Failure, List<MaintenanceTicket>>> fetchMaintenanceHistory();
}
