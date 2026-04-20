import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../domain/repositories/role_selection_repository.dart';
import '../datasources/role_selection_local_data_source.dart';

class RoleSelectionRepositoryImpl implements RoleSelectionRepository {
  final RoleSelectionLocalDataSource dataSource;
  RoleSelectionRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, void>> saveSelectedRole(UserRole role) async {
    try {
      await dataSource.saveRole(role);
      return const Right(null);
    } catch (_) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, UserRole?>> getSelectedRole() async {
    try {
      final role = await dataSource.getRole();
      return Right(role);
    } catch (_) {
      return Left(CacheFailure());
    }
  }
}
