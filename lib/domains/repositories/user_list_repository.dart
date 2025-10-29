import 'package:either_dart/either.dart';
import '../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class UserRepository {
  // We'll return a List of UserEntity
  Future<Either<Failure, List<UserEntity>>> getUsers();
}