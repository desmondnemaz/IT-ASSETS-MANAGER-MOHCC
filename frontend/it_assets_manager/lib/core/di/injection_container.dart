import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../network/dio_client.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/profile/providers/profile_provider.dart';
import '../../features/admin/data/admin_repository.dart';
import '../../features/admin/providers/admin_provider.dart';

final sl = GetIt.instance; // Service Locator

Future<void> initLocator() async {
  // 1. External
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  // 2. Core
  sl.registerLazySingleton(() => DioClient(sl(), sl()));

  // 3. Features - Auth
  sl.registerLazySingleton(() => AuthRepository(sl(), sl()));
  sl.registerFactory(() => AuthProvider(sl()));

  // 4. Features - Profile
  sl.registerLazySingleton(() => ProfileRepository(sl()));
  sl.registerFactory(() => ProfileProvider(sl()));

  // 5. Features - Admin
  sl.registerLazySingleton(() => AdminRepository(sl()));
  sl.registerFactory(() => AdminProvider(sl()));
}
