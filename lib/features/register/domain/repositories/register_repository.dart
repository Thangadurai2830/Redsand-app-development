import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/register_user.dart';

abstract class RegisterRepository {
  Future<Either<Failure, String>> register(RegisterUser user);
}
