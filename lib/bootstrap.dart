import 'dart:async';
import 'dart:developer';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:get_it/get_it.dart';
import 'package:local_storage/local_storage.dart';
import 'package:otogapo/app/routes/app_router.dart';
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

  // Initialized the router.
  getIt

    // Make the dio client available globally.
    ..registerSingleton<AppRouter>(AppRouter())
    ..registerSingleton<Dio>(dio);

  const storage = LocalStorage();

  await storage.init();

  // final authRepository = AuthRepository(
  //   client: dio,
  //   storage: storage,
  // );
  final authRepository = AuthRepository(
    client: dio,
    storage: storage,
  );
  runApp(
    await builder(
      authRepository,
      dio,
      packageInfo,
      storage,
    ),
  );
}
