import 'package:either_dart/either.dart';
import '../errors/failures.dart';

// This is a generic UseCase class
// Type: The return type of the use case (e.g., UserEntity)
// Params: The parameters it takes (e.g., LoginParams)
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

// We'll create a special class for when no parameters are needed
class NoParams {}