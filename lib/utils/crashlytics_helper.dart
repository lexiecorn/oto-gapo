/// Crashlytics helper utility for logging errors and custom data.
///
/// This file provides convenient methods for logging errors, setting user
/// identification, and adding custom key-value pairs to Crashlytics reports.
/// All methods are safe to call even if Crashlytics is not initialized.

import 'dart:developer' as developer;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:otogapo/services/n8n_error_logger.dart';

class CrashlyticsHelper {
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  /// Log a non-fatal error to Crashlytics and n8n.
  ///
  /// Use this method to log errors that don't crash the app but should be
  /// tracked for debugging purposes. Errors are sent to both Firebase Crashlytics
  /// and n8n webhook for comprehensive monitoring.
  static Future<void> logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    try {
      if (kDebugMode) {
        developer.log(
          'Crashlytics Error: $error',
          error: error,
          stackTrace: stackTrace,
          name: 'CrashlyticsHelper',
        );
      }

      if (reason != null) {
        await _crashlytics.setCustomKey('error_reason', reason);
      }

      await _crashlytics.recordError(
        error,
        stackTrace,
        fatal: fatal,
        reason: reason,
      );

      // Also send to n8n webhook (non-blocking)
      _sendToN8n(error, stackTrace, reason: reason, fatal: fatal);
    } catch (e) {
      // Fail silently to prevent infinite loops
      if (kDebugMode) {
        developer.log('Failed to log error to Crashlytics: $e');
      }
    }
  }

  /// Log a custom message to Crashlytics.
  ///
  /// Useful for tracking user actions or important events.
  static Future<void> log(String message) async {
    try {
      if (kDebugMode) {
        developer.log('Crashlytics Log: $message');
      }

      await _crashlytics.log(message);
    } catch (e) {
      // Fail silently to prevent infinite loops
      if (kDebugMode) {
        developer.log('Failed to log message to Crashlytics: $e');
      }
    }
  }

  /// Set user identifier for crash reports.
  ///
  /// This helps identify which user experienced a crash.
  static Future<void> setUserId(String userId) async {
    try {
      await _crashlytics.setUserIdentifier(userId);
      if (kDebugMode) {
        developer.log('Crashlytics: Set user ID to $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log('Failed to set user ID in Crashlytics: $e');
      }
    }
  }

  /// Set custom key-value pair for crash reports.
  ///
  /// Useful for adding context like user type, app version, etc.
  static Future<void> setCustomKey(String key, Object value) async {
    try {
      await _crashlytics.setCustomKey(key, value);
      if (kDebugMode) {
        developer.log('Crashlytics: Set custom key $key = $value');
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log('Failed to set custom key in Crashlytics: $e');
      }
    }
  }

  /// Set multiple custom keys at once.
  ///
  /// More efficient than calling setCustomKey multiple times.
  static Future<void> setCustomKeys(Map<String, Object> keys) async {
    try {
      for (final entry in keys.entries) {
        await _crashlytics.setCustomKey(entry.key, entry.value);
      }
      if (kDebugMode) {
        developer.log('Crashlytics: Set custom keys: $keys');
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log('Failed to set custom keys in Crashlytics: $e');
      }
    }
  }

  /// Record a breadcrumb for debugging.
  ///
  /// Breadcrumbs help track the sequence of events leading to a crash.
  static Future<void> recordBreadcrumb(String message) async {
    try {
      await _crashlytics.log(message);
      if (kDebugMode) {
        developer.log('Crashlytics Breadcrumb: $message');
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log('Failed to record breadcrumb in Crashlytics: $e');
      }
    }
  }

  /// Check if Crashlytics is available and ready.
  static Future<bool> isAvailable() async {
    try {
      return await _crashlytics.isCrashlyticsCollectionEnabled;
    } catch (e) {
      return false;
    }
  }

  /// Enable or disable Crashlytics collection.
  ///
  /// Useful for respecting user privacy settings.
  static Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    try {
      await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
      if (kDebugMode) {
        developer.log('Crashlytics collection ${enabled ? 'enabled' : 'disabled'}');
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log('Failed to set Crashlytics collection: $e');
      }
    }
  }

  /// Record a fatal error that will crash the app.
  ///
  /// Use this sparingly, typically for critical errors that should terminate
  /// the app gracefully with a crash report. Errors are sent to both Firebase
  /// Crashlytics and n8n webhook.
  static Future<void> recordFatalError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
  }) async {
    try {
      await logError(error, stackTrace, reason: reason, fatal: true);
      // In production, this would cause the app to crash
      if (kDebugMode) {
        developer.log('FATAL ERROR RECORDED: $error');
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log('Failed to record fatal error in Crashlytics: $e');
      }
    }
  }

  /// Helper method to send error to n8n webhook (non-blocking)
  static void _sendToN8n(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) {
    // Send to n8n asynchronously without blocking the main error flow
    N8nErrorLogger.sendErrorToN8n(
      error.toString(),
      stackTrace?.toString(),
      reason: reason,
      fatal: fatal,
    ).catchError((Object e) {
      // Silently handle n8n errors to prevent infinite loops
      if (kDebugMode) {
        developer.log('Failed to send error to n8n: $e');
      }
    });
  }
}
