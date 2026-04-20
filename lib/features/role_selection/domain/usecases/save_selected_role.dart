import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../repositories/role_selection_repository.dart';

class SaveSelectedRoleParams {
  final UserRole role;
  const SaveSelectedRoleParams(this.role);
}

class SaveSelectedRole implements UseCase<void, SaveSelectedRoleParams> {
  final RoleSelectionRepository repository;
  SaveSelectedRole(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveSelectedRoleParams params) =>
      repository.saveSelectedRole(params.role);
}
