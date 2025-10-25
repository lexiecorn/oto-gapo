import 'dart:async';
import 'dart:developer' as developer;
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
  // Start performance monitoring
  developer.Timeline.startSync('app_start');

  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      developer.Timeline.finishSync();
      developer.Timeline.startSync('firebase_init');

      // Initialize Firebase
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      developer.Timeline.finishSync();
      developer.Timeline.startSync('crashlytics_init');

      // Initialize Crashlytics with n8n integration
      FlutterError.onError = (FlutterErrorDetails details) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
        // Also send to n8n via CrashlyticsHelper
        CrashlyticsHelper.logError(details.exception, details.stack, reason: 'Flutter framework error', fatal: true);
      };

      // Pass all uncaught asynchronous errors to Crashlytics and n8n
      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        // Also send to n8n via CrashlyticsHelper
        CrashlyticsHelper.logError(error, stack, reason: 'Platform dispatcher error', fatal: true);
        return true;
      };

      // Enable Crashlytics collection with proper error handling
      try {
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
        print('Crashlytics collection enabled successfully');
      } catch (e) {
        print('Failed to enable Crashlytics collection: $e');
        // Continue execution even if Crashlytics setup fails
      }
      developer.Timeline.finishSync();
      developer.Timeline.startSync('flavor_config');

      // Set up flavor configuration before bootstrap
      FlavorConfig(name: 'PROD', variables: {'pocketbaseUrl': 'https://pb.lexserver.org'});
      developer.Timeline.finishSync();
      developer.Timeline.startSync('bootstrap');

      await bootstrap((authRepository, pocketBaseAuthRepository, dio, packageInfo, storage) async {
        await ScreenUtil.ensureScreenSize();

        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(systemNavigationBarColor: Colors.black));

        // Update FlavorConfig with package info
        FlavorConfig(
          name: 'PROD',
          variables: {
            'pkgInfoVersion': 'Ver:${packageInfo.version} Build:${packageInfo.buildNumber}',
            'pocketbaseUrl': 'https://pb.lexserver.org',
          },
        );

        developer.Timeline.finishSync();
        developer.Timeline.startSync('app_creation');

        final app = App(authRepository: authRepository, pocketBaseAuthRepository: pocketBaseAuthRepository);

        developer.Timeline.finishSync(); // Finish the app_creation timeline

        return app;
      });
    },
    (exception, stackTrace) async {
      // Report to Crashlytics
      await CrashlyticsHelper.logError(exception, stackTrace, reason: 'Main function error');
    },
  );
}
