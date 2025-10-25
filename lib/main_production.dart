import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/app.dart';
import 'package:otogapo/bootstrap.dart';
import 'package:otogapo/firebase_options_prod.dart';
import 'package:otogapo/utils/crashlytics_helper.dart';

Future<void> main() async {
  await runZonedGuarded(() async {
    // AGGRESSIVE TIMEOUT: Set a very short timeout for production
    await Future<void>.delayed(const Duration(milliseconds: 100));

    WidgetsFlutterBinding.ensureInitialized();

    // PRODUCTION BYPASS: Skip Firebase initialization to prevent hanging
    try {
      // Initialize Firebase with timeout
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          print('Firebase initialization timeout - continuing without Firebase');
          throw TimeoutException('Firebase initialization timeout', const Duration(seconds: 2));
        },
      );
    } catch (e) {
      print('Firebase initialization failed - continuing without Firebase: $e');
    }

    // Initialize Crashlytics with timeout
    try {
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

      // Pass all uncaught asynchronous errors to Crashlytics
      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      // Enable Crashlytics collection with timeout
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true).timeout(
        const Duration(seconds: 1),
        onTimeout: () {
          print('Crashlytics initialization timeout - continuing without Crashlytics');
        },
      );
    } catch (e) {
      print('Crashlytics initialization failed - continuing without Crashlytics: $e');
    }

    // Set up flavor configuration before bootstrap
    FlavorConfig(
      name: 'PROD',
      variables: {
        'pocketbaseUrl': 'https://pb.lexserver.org',
      },
    );

    // AGGRESSIVE TIMEOUT: Set a very short timeout for bootstrap
    await bootstrap(
      (
        authRepository,
        pocketBaseAuthRepository,
        dio,
        packageInfo,
        storage,
      ) async {
        // PRODUCTION BYPASS: Skip ScreenUtil to prevent hanging
        try {
          await ScreenUtil.ensureScreenSize().timeout(
            const Duration(seconds: 1),
            onTimeout: () {
              print('ScreenUtil initialization timeout - continuing without ScreenUtil');
            },
          );
        } catch (e) {
          print('ScreenUtil initialization failed - continuing without ScreenUtil: $e');
        }

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
    ).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        print('Bootstrap timeout - creating minimal app');
        // Create a minimal app if bootstrap fails
        // Note: This timeout callback cannot access the repository variables
        // as they are not in scope. This is a fallback that should not be reached.
        throw TimeoutException('Bootstrap timeout', const Duration(seconds: 5));
      },
    );
  }, (exception, stackTrace) async {
    // Report to Crashlytics
    await CrashlyticsHelper.logError(exception, stackTrace, reason: 'Main function error');
  });
}
