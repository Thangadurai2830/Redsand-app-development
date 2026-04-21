import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/site_visit_request.dart';
import '../repositories/schedule_visit_repository.dart';

class ScheduleVisit {
  final ScheduleVisitRepository repository;

  ScheduleVisit(this.repository);

  Future<Either<Failure, String>> call(SiteVisitRequest request) {
    return repository.scheduleVisit(request);
  }
}
