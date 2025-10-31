import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/app.dart';
import 'package:otogapo/bootstrap.dart';
import 'package:otogapo/firebase_options_staging.dart';
import 'package:otogapo/utils/crashlytics_helper.dart';

Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Enable Crashlytics collection with proper error handling
    // Note: Error handlers are set up in bootstrap.dart to avoid duplication
    try {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      print('Crashlytics collection enabled successfully');
    } catch (e) {
      print('Failed to enable Crashlytics collection: $e');
      // Continue execution even if Crashlytics setup fails
    }

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

        FlavorConfig(
          name: 'STAGING',
          variables: {
            'pkgInfoVersion':
                'Ver:${packageInfo.version} Build:${packageInfo.buildNumber}',
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
    await CrashlyticsHelper.logError(exception, stackTrace,
        reason: 'Main function error',);
  });
}
