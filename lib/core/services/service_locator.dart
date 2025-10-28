import 'package:get_it/get_it.dart';
import '../../data/repositories_impl/auth_repository_impl.dart';

import '../../domains/repositories/auth_repository.dart';
import '../../domains/use_cases/login_use_case.dart';
import '../../presentation/providers/login_provider.dart';

// This is our global Service Locator instance
final getIt = GetIt.instance;

Future<void> init() async {
  // --- Presentation (Providers) ---
  // We register LoginProvider as a 'factory'. This means every time
  // we ask for a LoginProvider, getIt will create a new instance.
  // This is important for ChangeNotifiers to avoid state issues.
  getIt.registerFactory(() => LoginProvider(
        loginUseCase: getIt(),
      ));

  // --- Domain (Use Cases) ---
  // We register Use Cases as 'lazy singletons'. This means they are
  // only created once, the very first time they are needed.
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));

  // --- Data (Repositories) ---
  // We also register the repository as a 'lazy singleton'.
  //
  // IMPORTANT: We register the IMPLEMENTATION (AuthRepositoryImpl)
  // but as its ABSTRACT class (AuthRepository).
  //
  // This is the core of decoupling. Our Presentation layer will ask for
  // AuthRepository, and getIt will provide the implementation
  // without the UI ever knowing about it.
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());

  // --- Data (Services) ---
  // When we add ApiService, CacheService, or VideoSDKService,
  // we will register them here as lazy singletons as well.
  // Example:
  // getIt.registerLazySingleton(() => ApiService(dio: Dio()));
  // getIt.registerLazySingleton(() => CacheService(prefs: SharedPreferences.getInstance()));
}