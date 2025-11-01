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
library;

import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:authentication_repository/src/pocketbase_auth_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:firebase_performance_dio/firebase_performance_dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_storage/local_storage.dart';
import 'package:otogapo/app/routes/app_router.dart';
import 'package:otogapo/models/cached_data.dart';
import 'package:otogapo/services/connectivity_service.dart';
import 'package:otogapo/services/notification_service.dart';
import 'package:otogapo/services/pocketbase_service.dart';
import 'package:otogapo/services/sync_service.dart';
import 'package:otogapo/utils/clarity_helper.dart';
import 'package:otogapo/utils/crashlytics_helper.dart';
import 'package:otogapo/utils/performance_helper.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
/// 3. Initializes Firebase and Crashlytics
/// 4. Initializes package info for version tracking
/// 5. Sets up Dio HTTP client
/// 6. Initializes PocketBase service
/// 7. Registers services in dependency injection container
/// 8. Initializes local storage
/// 9. Creates and registers repositories
/// 10. Runs the application with the provided builder
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
  // Set up error handling for Flutter errors and report to Crashlytics and n8n
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);

    // Report to Crashlytics and n8n via CrashlyticsHelper
    // CrashlyticsHelper internally handles both Crashlytics and n8n logging
    CrashlyticsHelper.logError(
      details.exception,
      details.stack,
      reason: 'Bootstrap Flutter error',
      fatal: true,
    );

    // In production, ensure we don't crash on initialization errors
    if (details.exception.toString().contains('SharedPreferences') ||
        details.exception.toString().contains('PocketBase') ||
        details.exception.toString().contains('Hive')) {
      log('Non-critical initialization error, continuing with app startup');
    }
  };

  // Set up error handling for async errors
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    log('Async error: $error', stackTrace: stack);

    // Report to Crashlytics and n8n via CrashlyticsHelper
    // CrashlyticsHelper internally handles both Crashlytics and n8n logging
    CrashlyticsHelper.logError(
      error,
      stack,
      reason: 'Bootstrap async error',
      fatal: true,
    );

    return true;
  };

  Bloc.observer = const AppBlocObserver();

  // Add cross-flavor configuration here
  // Tune Flutter in-memory image cache to balance performance and memory.
  // These values can be adjusted per product needs.
  PaintingBinding.instance.imageCache
    ..maximumSize = 400
    ..maximumSizeBytes = 100 * 1024 * 1024; // 100 MB

  final packageInfo = await PackageInfo.fromPlatform();

  // Set up Dio HTTP client with performance monitoring interceptor
  final dio = Dio();
  dio.interceptors.add(DioFirebasePerformanceInterceptor());
  // final a = flavor;
  // await Firebase.initializeApp(
  //   options: flavor == 'PROD'
  //       ? firebase_option_prod.DefaultFirebaseOptions.currentPlatform
  //       : firebase_option_dev.DefaultFirebaseOptions.currentPlatform,
  // );

  // Initialize PocketBase service (lazy initialization)
  final pocketBaseService = PocketBaseService();
  // Don't initialize PocketBase immediately - let it initialize when first used

  // Initialize local storage FIRST (initializes Hive)
  const storage = LocalStorage();

  // Add timeout to Hive initialization to prevent hanging
  try {
    await storage.init().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        log('Hive initialization timeout - continuing with app startup');
        return;
      },
    );
  } catch (e) {
    log('Hive initialization error: $e - continuing with app startup');
  }

  // Register Hive type adapters for cached data models BEFORE opening boxes
  Hive.registerAdapter(CachedPostAdapter());
  Hive.registerAdapter(CachedMeetingAdapter());
  Hive.registerAdapter(CachedUserProfileAdapter());
  Hive.registerAdapter(OfflineActionAdapter());
  Hive.registerAdapter(OfflineActionTypeAdapter());
  Hive.registerAdapter(CachedAnnouncementAdapter());

  // Initialize Connectivity, Sync, and Notification services AFTER Hive is ready
  final connectivityService = ConnectivityService();
  final syncService = SyncService();
  final notificationService = NotificationService();

  // Initialize notification service
  try {
    await notificationService.initialize();
    log('Notification service initialized successfully');
  } catch (e) {
    log('Notification service initialization error: $e - continuing with app startup');
  }

  // Add timeout to sync service initialization
  try {
    await syncService.init().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        log('Sync service initialization timeout - continuing with app startup');
        return;
      },
    );
  } catch (e) {
    log('Sync service initialization error: $e - continuing with app startup');
  }

  // Initialize SharedPreferences for version check service
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialized the router.
  getIt
    // Make the dio client available globally.
    ..registerSingleton<AppRouter>(AppRouter())
    ..registerSingleton<Dio>(dio)
    ..registerSingleton<PocketBaseService>(pocketBaseService)
    ..registerSingleton<ConnectivityService>(connectivityService)
    ..registerSingleton<SyncService>(syncService)
    ..registerSingleton<NotificationService>(notificationService)
    ..registerSingleton<SharedPreferences>(sharedPreferences)
    ..registerSingleton<PackageInfo>(packageInfo);

  // Initialize repositories
  final authRepository = AuthRepository(
    storage: storage,
  );

  // Create PocketBaseAuthRepository with storage and initialize it
  final pocketBaseAuthRepository = PocketBaseAuthRepository(storage: storage);

  // Initialize PocketBase with timeout to prevent hanging
  final pbInitTrace = PerformanceHelper.startTrace('pocketbase_init');
  try {
    log('Initializing PocketBase with timeout...');
    await pocketBaseAuthRepository.initialize().timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        log('PocketBase initialization timeout - continuing with app startup');
        return;
      },
    );
    log('PocketBase initialized successfully');
  } catch (e) {
    log('PocketBase initialization error: $e - continuing with app startup');
    await PerformanceHelper.setAttribute(pbInitTrace, 'error', e.toString());
    // Continue with app startup even if PocketBase fails to initialize
  } finally {
    await PerformanceHelper.stopTrace(pbInitTrace);
  }

  // Register repositories in GetIt
  getIt
    ..registerSingleton<AuthRepository>(authRepository)
    ..registerSingleton<PocketBaseAuthRepository>(pocketBaseAuthRepository);

  // PocketBase is now initialized with persistent auth store
  final appWidget = await builder(
    authRepository,
    pocketBaseAuthRepository,
    dio,
    packageInfo,
    storage,
  );

  final wrappedApp = ClarityHelper.wrapWithClarity(
    appWidget,
    // Optionally pass userId if available at startup
  );

  runApp(wrappedApp);
}
