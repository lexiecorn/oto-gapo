import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/app.dart';
import 'package:otogapo/bootstrap.dart';
import 'package:otogapo/firebase_options_prod.dart';

Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await bootstrap(
      (
        authRepository,
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

        FlavorConfig(
          name: 'PROD',
          variables: {
            'pkgInfoVersion': 'Ver:${packageInfo.version} Build:${packageInfo.buildNumber}',
          },
        );

        return App(
          authRepository: authRepository,
        );
      },
    );
  }, (exception, stackTrace) async {
    // await Sentry.captureException(exception, stackTrace: stackTrace);
  });
}
