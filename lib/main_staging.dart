import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';

final getIt = GetIt.instance;

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
  PackageInfo packageInfo,
  // FirebaseOptions fbOptionsBuilder,
  // AuthRepository authRepository,
);

Future<void> bootstrap(
  BootstrapBuilder builder,
) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  // Add cross-flavor configuration here

  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      final packageInfo = await PackageInfo.fromPlatform();

      // Initialize Firebase
      // await Firebase.initializeApp(
      //   options: fbOptionsBuilder,
      // );

      final dio = Dio();

      // Initialized the router.
      // getIt
      //   ..registerSingleton<AppRouter>(AppRouter())
      //   // Make the dio client available globally.
      //   ..registerSingleton<Dio>(dio);

      // const storage = LocalStorage();

      // await storage.init();

      // final authRepository = AuthRepository(
      //   client: dio,
      //   storage: storage,
      // );

      runApp(
        await builder(
          // dio,
          // storage,
          packageInfo,

          // authRepository,
        ),
      );
    },
    (error, stackTrace) => log(error.toString(), stackTrace: stackTrace),
  );
}
