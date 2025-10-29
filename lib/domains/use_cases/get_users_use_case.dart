import 'package:either_dart/either.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/user_list_repository.dart';


// We implement our generic UseCase
// It returns a List<UserEntity> and takes NoParams
class GetUsersUseCase implements UseCase<List<UserEntity>, NoParams> {
  final UserRepository userRepository;

  GetUsersUseCase(this.userRepository);

  @override
  Future<Either<Failure, List<UserEntity>>> call(NoParams params) async {
    return await userRepository.getUsers();
  }
}