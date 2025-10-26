/// N8N Error Logger Service
///
/// This service sends comprehensive error data to n8n webhook for production debugging.
/// It collects detailed context including app version, device info, user data, and network status.
/// All methods are safe to call and won't crash the app if n8n is unreachable.

import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:get_it/get_it.dart';
import 'package:otogapo/utils/network_helper.dart';
import 'package:package_info_plus/package_info_plus.dart';

class N8nErrorLogger {
  static const String _productionWebhookUrl =
      'https://n8n.lexserver.org/webhook/af1310af-d54b-461a-a982-9f58b6ae4d30';
  static const String _testWebhookUrl =
      'https://n8n.lexserver.org/webhook-test/af1310af-d54b-461a-a982-9f58b6ae4d30';

  /// Send error data to n8n webhook
  ///
  /// [errorMessage] - The error message or exception string
  /// [stackTrace] - The stack trace (optional)
  /// [reason] - Additional context about why the error occurred (optional)
  /// [fatal] - Whether this is a fatal error (optional)
  /// [useTestUrl] - Whether to use test webhook URL (default: false for production)
  static Future<void> sendErrorToN8n(
    String errorMessage,
    String? stackTrace, {
    String? reason,
    bool fatal = false,
    bool useTestUrl = false,
  }) async {
    try {
      // Get Dio instance from GetIt
      final dio = GetIt.instance<Dio>();

      // Determine which webhook URL to use
      final webhookUrl = useTestUrl ? _testWebhookUrl : _productionWebhookUrl;

      // Collect comprehensive error context
      final errorData = await _buildErrorData(
        errorMessage: errorMessage,
        stackTrace: stackTrace,
        reason: reason,
        fatal: fatal,
      );

      if (kDebugMode) {
        developer.log('N8N Error Logger: Sending error to $webhookUrl');
        developer.log('N8N Error Data: ${jsonEncode(errorData)}');
      }

      // Send to n8n webhook
      final response = await dio.post<Map<String, dynamic>>(
        webhookUrl,
        data: errorData,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        if (kDebugMode) {
          developer.log('N8N Error Logger: Successfully sent error log');
        }
      } else {
        if (kDebugMode) {
          developer.log(
              'N8N Error Logger: Failed to send error log: ${response.statusCode} ${response.data}');
        }
      }
    } catch (e) {
      // Handle cases where the phone can't reach the n8n webhook (e.g., no network)
      if (kDebugMode) {
        developer.log(
            'N8N Error Logger: Exception caught while sending error log: $e');
      }
      // Don't rethrow - this is a logging service, not critical functionality
    }
  }

  /// Build comprehensive error data with context
  static Future<Map<String, dynamic>> _buildErrorData({
    required String errorMessage,
    String? stackTrace,
    String? reason,
    bool fatal = false,
  }) async {
    // Get package info
    final packageInfo = await PackageInfo.fromPlatform();

    // Get current flavor
    final flavor = FlavorConfig.instance.name.toString();

    // Get device info
    final deviceInfo = await _getDeviceInfo();

    // Get network status
    final networkStatus = await _getNetworkStatus();

    // Get user ID if available (this would need to be implemented based on your auth system)
    final userId = await _getCurrentUserId();

    return {
      'errorMessage': errorMessage,
      'stackTrace': stackTrace ?? 'No stack trace available',
      'timestamp': DateTime.now().toIso8601String(),
      'appVersion': packageInfo.version,
      'buildNumber': packageInfo.buildNumber,
      'flavor': flavor,
      'userId': userId,
      'fatal': fatal,
      'reason': reason,
      'deviceInfo': deviceInfo,
      'networkStatus': networkStatus,
    };
  }

  /// Get device information
  static Future<Map<String, String>> _getDeviceInfo() async {
    try {
      return {
        'platform': Platform.operatingSystem,
        'osVersion': Platform.operatingSystemVersion,
        'model': Platform.isAndroid ? 'Android Device' : 'iOS Device',
        'locale': Platform.localeName,
      };
    } catch (e) {
      return {
        'platform': 'unknown',
        'osVersion': 'unknown',
        'model': 'unknown',
        'locale': 'unknown',
      };
    }
  }

  /// Get current network status
  static Future<String> _getNetworkStatus() async {
    try {
      final hasInternet = await NetworkHelper.hasInternetConnection();
      return hasInternet ? 'online' : 'offline';
    } catch (e) {
      return 'unknown';
    }
  }

  /// Get current user ID (placeholder - implement based on your auth system)
  static Future<String?> _getCurrentUserId() async {
    try {
      // TODO: Implement based on your authentication system
      // This is a placeholder - you'll need to integrate with your auth repository
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Test the n8n webhook connection
  static Future<bool> testConnection({bool useTestUrl = true}) async {
    try {
      await sendErrorToN8n(
        'Test error from Flutter app',
        'This is a test stack trace',
        reason: 'Testing n8n webhook connection',
        useTestUrl: useTestUrl,
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        developer.log('N8N Error Logger: Test connection failed: $e');
      }
      return false;
    }
  }
}
