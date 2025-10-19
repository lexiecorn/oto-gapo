import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/app.dart';
import 'package:otogapo/bootstrap.dart';

Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Set up flavor configuration before bootstrap
    FlavorConfig(
      name: 'PROD',
      variables: {
        'pocketbaseUrl': 'https://pb.lexserver.org',
      },
    );

    await bootstrap(
      (
        authRepository,
        pocketBaseAuthRepository,
        dio,
        packageInfo,
        storage,
      ) async {
        await ScreenUtil.ensureScreenSize();

        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            systemNavigationBarColor: Colors.black,
          ),
        );

        // Update FlavorConfig with package info
        FlavorConfig(
          name: 'PROD',
          variables: {
            'pkgInfoVersion': 'Ver:${packageInfo.version} Build:${packageInfo.buildNumber}',
            'pocketbaseUrl': 'https://pb.lexserver.org',
          },
        );

        return App(
          authRepository: authRepository,
          pocketBaseAuthRepository: pocketBaseAuthRepository,
        );
      },
    );
  }, (exception, stackTrace) async {
    // await Sentry.captureException(exception, stackTrace: stackTrace);
  });
}
