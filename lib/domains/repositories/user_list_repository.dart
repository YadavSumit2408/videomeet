import 'package:either_dart/either.dart';
import '../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<Either<Failure, List<UserEntity>>> getUsers();
}