import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/app.dart';
import 'package:otogapo/app/core/logging.dart';
import 'package:otogapo/bootstrap.dart';
import 'package:otogapo/firebase_options_dev.dart';
import 'package:otogapo/utils/crashlytics_helper.dart';

Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Crashlytics with n8n integration
    FlutterError.onError = (FlutterErrorDetails details) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      // Also send to n8n via CrashlyticsHelper
      CrashlyticsHelper.logError(
        details.exception,
        details.stack,
        reason: 'Flutter framework error',
        fatal: true,
      );
    };

    // Pass all uncaught asynchronous errors to Crashlytics and n8n
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      // Also send to n8n via CrashlyticsHelper
      CrashlyticsHelper.logError(
        error,
        stack,
        reason: 'Platform dispatcher error',
        fatal: true,
      );
      return true;
    };

    // Enable Crashlytics collection
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

    // Initialize logging configuration
    AppLogging.init();

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

        // Setup the Development Flavor
        FlavorConfig(
          name: 'DEV',
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
    // Report to Crashlytics
    await CrashlyticsHelper.logError(exception, stackTrace, reason: 'Main function error');
  });
}
