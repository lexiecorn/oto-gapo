import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

/// Debug helper for production debugging
class DebugHelper {
  static void log(String message) {
    if (kDebugMode) {
      debugPrint('🐛 DEBUG: $message');
    }
    dev.log('🐛 DEBUG: $message');
  }

  static void logError(String message,
      [dynamic error, StackTrace? stackTrace,]) {
    if (kDebugMode) {
      debugPrint('❌ ERROR: $message');
      if (error != null) debugPrint('❌ Error details: $error');
      if (stackTrace != null) debugPrint('❌ Stack trace: $stackTrace');
    }
    dev.log('❌ ERROR: $message');
    if (error != null) dev.log('❌ Error details: $error');
    if (stackTrace != null) dev.log('❌ Stack trace: $stackTrace');
  }

  static void logWarning(String message) {
    if (kDebugMode) {
      debugPrint('⚠️ WARNING: $message');
    }
    dev.log('⚠️ WARNING: $message');
  }

  static void logSuccess(String message) {
    if (kDebugMode) {
      debugPrint('✅ SUCCESS: $message');
    }
    dev.log('✅ SUCCESS: $message');
  }
}
