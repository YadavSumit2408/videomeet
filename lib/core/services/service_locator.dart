import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:videomeet/data/services/locals/cache_service.dart';
import 'package:videomeet/domains/use_cases/get_users_use_case.dart';
import '../../data/repositories_impl/auth_repository_impl.dart';
import '../../data/repositories_impl/user_list_repository_impl.dart';
import '../../data/repositories_impl/video_calll_repository_impl.dart';
import '../../data/services/api_service.dart';
import '../../data/services/network_info_helper.dart';
import '../../domains/repositories/auth_repository.dart';
import '../../domains/repositories/user_list_repository.dart';
import '../../domains/use_cases/login_use_case.dart';
import '../../presentation/providers/login_provider.dart';
import '../../presentation/providers/user_list_provider.dart';
import '../../domains/repositories/video_call_repository.dart';
import '../../presentation/providers/video_call_provider.dart';

final getIt = GetIt.instance;

Future<void> init(SharedPreferences prefs) async {
  // --- Presentation (Providers) ---
  getIt.registerFactory(() => LoginProvider(loginUseCase: getIt()));
  getIt.registerFactory(() => UserListProvider(getUsersUseCase: getIt()));
 
  getIt.registerFactory(() => VideoCallProvider(videoCallRepository: getIt()));

  // --- Domain (Use Cases) ---
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => GetUsersUseCase(getIt()));
 

  // --- Data (Repositories) ---
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
        cacheService: getIt(),
      ));

  getIt.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(
        apiService: getIt(),
        cacheService: getIt(),
        networkInfo: getIt(),
      ));

  getIt.registerLazySingleton<VideoCallRepository>(
      () => VideoCallRepositoryImpl());

  // --- Data (Services) ---
  getIt.registerLazySingleton<ApiService>(() => ApiService(getIt()));
  getIt.registerLazySingleton<CacheService>(() => CacheServiceImpl(getIt()));
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(getIt()));

  // --- External ---
  getIt.registerLazySingleton(() => prefs);
  getIt.registerLazySingleton(() => Connectivity());
  getIt.registerLazySingleton(() {
    final dio = Dio(BaseOptions(
      baseUrl: 'https://reqres.in/api',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (options.path.contains('/login') ||
            options.path.contains('/users')) {
          return handler.next(options);
        }

        final cacheService = getIt<CacheService>();
        final token = await cacheService.getToken();

        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        return handler.next(options);
      },
      onError: (error, handler) async {
        return handler.next(error);
      },
    ));
    return dio;
  });
}
