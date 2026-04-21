import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/site_visit_record.dart';
import '../repositories/profile_repository.dart';

class GetSiteVisits implements UseCase<List<SiteVisitRecord>, NoParams> {
  final ProfileRepository repository;

  GetSiteVisits(this.repository);

  @override
  Future<Either<Failure, List<SiteVisitRecord>>> call(NoParams params) {
    return repository.getSiteVisits();
  }
}
