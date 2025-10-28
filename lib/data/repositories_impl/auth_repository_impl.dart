

import 'package:either_dart/either.dart';

import '../../core/errors/exception.dart';
import '../../core/errors/failures.dart';
import '../../domains/entities/user_entity.dart';
import '../../domains/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  // In a real app, we would inject an ApiService here.
  // const AuthRepositoryImpl(this.apiService);
  // final ApiService apiService;

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    // 1. Basic Validation
    if (email.isEmpty || password.isEmpty) {
      return Left(ValidationFailure("Email and password cannot be empty."));
    }
    
    // 2. Mock Authentication 
    try {
      // Simulate a network delay
      await Future.delayed(const Duration(seconds: 1));

      if (email == 'eve.holt@reqres.in' && password == 'cityslicka') {
        // Successful login
        // We are mocking a successful login and creating a dummy user
        // The token is a real one from ReqRes for testing other endpoints
        const user = UserEntity(
          id: '4',
          email: 'eve.holt@reqres.in',
          firstName: 'Eve',
          lastName: 'Holt',
          avatar: 'https://reqres.in/img/faces/4-image.jpg',
          token: 'QpwL5tke4Pnpja7X4',
        );
        return const Right(user);
      } else {
        // Failed login
        throw ServerException("Invalid email or password.");
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}