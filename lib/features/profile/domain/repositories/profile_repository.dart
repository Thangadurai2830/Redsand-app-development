import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/kyc_submission_request.dart';
import '../entities/profile_update_request.dart';
import '../entities/site_visit_record.dart';
import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getProfile();
  Future<Either<Failure, UserProfile>> updateProfile(ProfileUpdateRequest request);
  Future<Either<Failure, String>> submitKycDocuments(KycSubmissionRequest request);
  Future<Either<Failure, List<SiteVisitRecord>>> getSiteVisits();
}
