import 'dart:async';
import 'dart:developer' as developer;

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
import 'package:otogapo/utils/performance_helper.dart';

Future<void> main() async {
  // Start performance monitoring with Flutter DevTools
  developer.Timeline.startSync('app_start');
  // Start Firebase Performance trace
  final appStartTrace = PerformanceHelper.startTrace('app_start');

  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      developer.Timeline.finishSync();
      developer.Timeline.startSync('firebase_init');

      // Initialize Firebase
      final firebaseInitTrace = PerformanceHelper.startTrace('firebase_init');
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,);
      developer.Timeline.finishSync();
      await PerformanceHelper.stopTrace(firebaseInitTrace);
      developer.Timeline.startSync('crashlytics_init');

      // Enable Crashlytics collection with proper error handling
      // Note: Error handlers are set up in bootstrap.dart to avoid duplication
      try {
        await FirebaseCrashlytics.instance
            .setCrashlyticsCollectionEnabled(true);
        print('Crashlytics collection enabled successfully');
      } catch (e) {
        print('Failed to enable Crashlytics collection: $e');
        // Continue execution even if Crashlytics setup fails
      }
      developer.Timeline.finishSync();

      // Enable Performance Monitoring collection
      developer.Timeline.startSync('perf_enable');
      final perfEnableTrace = PerformanceHelper.startTrace('perf_enable');
      try {
        await PerformanceHelper.setPerformanceCollectionEnabled(true);
        print('Performance Monitoring enabled successfully');
      } catch (e) {
        print('Failed to enable Performance Monitoring: $e');
      }
      developer.Timeline.finishSync();
      await PerformanceHelper.stopTrace(perfEnableTrace);

      developer.Timeline.startSync('flavor_config');

      // Set up flavor configuration before bootstrap
      FlavorConfig(
          name: 'PROD',
          variables: {
            'pocketbaseUrl': 'https://pb.lexserver.org',
            'clarityProjectId': 'tyroze7rek',
          },);
      developer.Timeline.finishSync();
      developer.Timeline.startSync('bootstrap');

      await bootstrap((authRepository, pocketBaseAuthRepository, dio,
          packageInfo, storage,) async {
        await ScreenUtil.ensureScreenSize();

        SystemChrome.setSystemUIOverlayStyle(
            const SystemUiOverlayStyle(systemNavigationBarColor: Colors.black),);

        // Update FlavorConfig with package info
        FlavorConfig(
          name: 'PROD',
          variables: {
            'pkgInfoVersion':
                'Ver:${packageInfo.version} Build:${packageInfo.buildNumber}',
            'pocketbaseUrl': 'https://pb.lexserver.org',
            'clarityProjectId': 'tyroze7rek',
          },
        );

        developer.Timeline.finishSync();
        developer.Timeline.startSync('app_creation');

        final app = App(
            authRepository: authRepository,
            pocketBaseAuthRepository: pocketBaseAuthRepository,);

        developer.Timeline.finishSync(); // Finish the app_creation timeline

        // Stop app start trace
        await PerformanceHelper.stopTrace(appStartTrace);

        return app;
      });
    },
    (exception, stackTrace) async {
      // Stop app start trace on error
      await PerformanceHelper.stopTrace(appStartTrace);
      // Report to Crashlytics
      await CrashlyticsHelper.logError(exception, stackTrace,
          reason: 'Main function error',);
    },
  );
}
