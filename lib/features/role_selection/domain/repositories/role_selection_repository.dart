import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user_role.dart';

abstract class RoleSelectionRepository {
  Future<Either<Failure, void>> saveSelectedRole(UserRole role);
  Future<Either<Failure, UserRole?>> getSelectedRole();
}
