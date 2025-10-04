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

final getIt = GetIt.instance;
final flavor = FlavorConfig.instance.name.toString();

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

typedef BootstrapBuilder = FutureOr<Widget> Function(
  AuthRepository authRepository,
  PocketBaseAuthRepository pocketBaseAuthRepository,
  Dio dio,
  PackageInfo packageInfo,
  LocalStorage storage,
);

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
