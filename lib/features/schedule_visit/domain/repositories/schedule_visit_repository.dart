import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/site_visit_request.dart';

abstract class ScheduleVisitRepository {
  Future<Either<Failure, String>> scheduleVisit(SiteVisitRequest request);
}
