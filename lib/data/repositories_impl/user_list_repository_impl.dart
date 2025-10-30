import 'package:either_dart/either.dart';
import 'package:videomeet/core/errors/exception.dart';
import 'package:videomeet/domains/entities/user_entity.dart';
import '../../core/errors/failures.dart';
import '../../domains/repositories/user_list_repository.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/locals/cache_service.dart';
import '../services/network_info_helper.dart';

class UserRepositoryImpl implements UserRepository {
  final ApiService apiService;
  final CacheService cacheService;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({
    required this.apiService,
    required this.cacheService,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<UserEntity>>> getUsers() async {
    if (await networkInfo.isConnected) {
     
      try {
        final remoteUsers = await apiService.getUsers();
        final userModels = remoteUsers
            .map((user) => UserModel.fromJson(user as Map<String, dynamic>))
            .toList();

        // Cache the fetched users as JSON list
        final usersJson =
            userModels.map((user) => (user as UserModel).toJson()).toList();
        await cacheService.cacheUsers(usersJson);

        return Right(userModels);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      try {
        final cachedUsersJson = cacheService.getCachedUsers();
        if (cachedUsersJson == null) {
          throw CacheException("No cached users available.");
        }

        final userModels = cachedUsersJson
            .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
            .toList();

        return Right(userModels);
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }
}
