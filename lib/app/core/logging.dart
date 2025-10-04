import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class AppLogging {
  static void init() {
    if (kDebugMode) {
      // Filter out EGL emulation logs
      developer.log(
        'sd',
        name: 'AppLogging',
      );
    }
  }
}
