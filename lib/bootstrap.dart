/// Bootstrap file for initializing the OtoGapo application.
///
/// This file handles the complete application initialization process including:
/// - Error handling setup
/// - BLoC observer configuration
/// - Dependency injection setup
/// - Service initialization
/// - Repository configuration
///
/// The bootstrap process is flavor-aware and configures the app based on
/// the current environment (development, staging, or production).

import 'dart:async';
import 'dart:developer';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:authentication_repository/src/pocketbase_auth_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:get_it/get_it.dart';
import 'package:local_storage/local_storage.dart';
import 'package:otogapo/app/routes/app_router.dart';
import 'package:otogapo/services/pocketbase_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Global GetIt instance for dependency injection.
final getIt = GetIt.instance;

/// Current application flavor name.
final flavor = FlavorConfig.instance.name.toString();

/// BLoC observer for logging and debugging BLoC state changes.
///
/// This observer logs all state changes and errors in BLoCs throughout
/// the application, useful for debugging and monitoring app behavior.
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

/// Type definition for the bootstrap builder function.
///
/// This function receives all initialized dependencies and returns
/// the root widget of the application.
typedef BootstrapBuilder = FutureOr<Widget> Function(
  AuthRepository authRepository,
  PocketBaseAuthRepository pocketBaseAuthRepository,
  Dio dio,
  PackageInfo packageInfo,
  LocalStorage storage,
);

/// Bootstraps the application with all necessary initialization.
///
/// This function:
/// 1. Sets up error handling for Flutter errors
/// 2. Configures BLoC observer for state management monitoring
/// 3. Initializes package info for version tracking
/// 4. Sets up Dio HTTP client
/// 5. Initializes PocketBase service
/// 6. Registers services in dependency injection container
/// 7. Initializes local storage
/// 8. Creates and registers repositories
/// 9. Runs the application with the provided builder
///
/// Example:
/// ```dart
/// await bootstrap((authRepo, pocketBaseRepo, dio, packageInfo, storage) {
///   return App(
///     authRepository: authRepo,
///     pocketBaseAuthRepository: pocketBaseRepo,
///   );
/// });
/// ```
Future<void> bootstrap(
  BootstrapBuilder builder,
) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  // Add cross-flavor configuration here

  final packageInfo = await PackageInfo.fromPlatform();

  final dio = Dio();
  // final a = flavor;
  // await Firebase.initializeApp(
  //   options: flavor == 'PROD'
  //       ? firebase_option_prod.DefaultFirebaseOptions.currentPlatform
  //       : firebase_option_dev.DefaultFirebaseOptions.currentPlatform,
  // );

  // Initialize PocketBase service (lazy initialization)
  final pocketBaseService = PocketBaseService();
  // Don't initialize PocketBase immediately - let it initialize when first used

  // Initialized the router.
  getIt
    // Make the dio client available globally.
    ..registerSingleton<AppRouter>(AppRouter())
    ..registerSingleton<Dio>(dio)
    ..registerSingleton<PocketBaseService>(pocketBaseService);

  const storage = LocalStorage();

  await storage.init();

  // Initialize repositories
  final authRepository = AuthRepository(
    client: dio,
    storage: storage,
  );

  final pocketBaseAuthRepository = PocketBaseAuthRepository();

  // Register repositories in GetIt
  getIt
    ..registerSingleton<AuthRepository>(authRepository)
    ..registerSingleton<PocketBaseAuthRepository>(pocketBaseAuthRepository);

  // PocketBase will be initialized lazily when first accessed
  runApp(
    await builder(
      authRepository,
      pocketBaseAuthRepository,
      dio,
      packageInfo,
      storage,
    ),
  );
}
