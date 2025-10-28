import 'package:either_dart/either.dart';
import '../entities/user_entity.dart';
import '../../core/errors/failures.dart'; // Make sure you have this file

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });
}