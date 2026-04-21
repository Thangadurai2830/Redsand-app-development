import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/profile_update_request.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class UpdateProfile implements UseCase<UserProfile, ProfileUpdateRequest> {
  final ProfileRepository repository;

  UpdateProfile(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(ProfileUpdateRequest params) {
    return repository.updateProfile(params);
  }
}
