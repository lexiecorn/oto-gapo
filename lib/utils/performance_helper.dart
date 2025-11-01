/// Performance monitoring helper utility for Firebase Performance Monitoring.
///
/// This file provides convenient methods for creating custom traces, recording
/// metrics, and tracking performance for various app operations. All methods
/// are safe to call even if Performance Monitoring is not initialized.
library;

import 'dart:developer' as developer;
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';

class PerformanceHelper {
  static FirebasePerformance? _performance;

  /// Lazy initialization of FirebasePerformance to avoid errors
  /// if Firebase is not yet initialized.
  static FirebasePerformance get _performanceInstance {
    _performance ??= FirebasePerformance.instance;
    return _performance!;
  }

  /// Create a custom trace for tracking specific operations.
  ///
  /// Use this method to measure the performance of custom operations like
  /// authentication, database queries, image processing, etc.
  ///
  /// Example:
  /// ```dart
  /// final trace = PerformanceHelper.startTrace('user_login');
  /// // ... perform login operation ...
  /// await PerformanceHelper.stopTrace(trace);
  /// ```
  static Trace? startTrace(String traceName) {
    try {
      final trace = _performanceInstance.newTrace(traceName);
      trace.start();
      if (kDebugMode) {
        developer.log('Started trace: $traceName');
      }
      return trace;
    } catch (e) {
      if (kDebugMode) {
        developer.log('Failed to start trace: $e');
      }
      return null;
    }
  }

  /// Stop a custom trace.
  ///
  /// Call this method when the operation being tracked is complete.
  static Future<void> stopTrace(Trace? trace) async {
    if (trace == null) return;
    try {
      await trace.stop();
      if (kDebugMode) {
        developer.log('Stopped trace');
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log('Failed to stop trace: $e');
      }
    }
  }

  /// Record a custom metric for a trace.
  ///
  /// Use this to track specific metrics like request size, number of items
  /// processed, cache hit rate, etc.
  ///
  /// Example:
  /// ```dart
  /// final trace = PerformanceHelper.startTrace('fetch_posts');
  /// // ... fetch posts ...
  /// await PerformanceHelper.putMetric(trace, 'post_count', posts.length);
  /// await PerformanceHelper.stopTrace(trace);
  /// ```
  static Future<void> putMetric(Trace? trace, String metricName, int value) async {
    if (trace == null) return;
    try {
      trace.setMetric(metricName, value);
      if (kDebugMode) {
        developer.log('Set metric $metricName = $value for trace');
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log('Failed to put metric: $e');
      }
    }
  }

  /// Add a custom attribute to a trace.
  ///
  /// Attributes provide additional context about the trace, such as user ID,
  /// screen name, error type, etc.
  ///
  /// Example:
  /// ```dart
  /// final trace = PerformanceHelper.startTrace('api_request');
  /// await PerformanceHelper.setAttribute(trace, 'endpoint', '/api/posts');
  /// await PerformanceHelper.setAttribute(trace, 'method', 'GET');
  /// ```
  static Future<void> setAttribute(
    Trace? trace,
    String attributeName,
    String value,
  ) async {
    if (trace == null) return;
    try {
      trace.putAttribute(attributeName, value);
      if (kDebugMode) {
        developer.log('Set attribute $attributeName = $value for trace');
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log('Failed to set attribute: $e');
      }
    }
  }

  /// Track an async operation with automatic start/stop.
  ///
  /// This method starts a trace, executes the provided function, and stops
  /// the trace when complete. It's useful for tracking async operations.
  ///
  /// Example:
  /// ```dart
  /// final result = await PerformanceHelper.trackOperation(
  ///   'fetch_user_data',
  ///   () => apiService.getUserData(),
  /// );
  /// ```
  static Future<T> trackOperation<T>(
    String traceName,
    Future<T> Function() operation,
  ) async {
    final trace = startTrace(traceName);
    try {
      final result = await operation();
      await stopTrace(trace);
      return result;
    } catch (e) {
      await setAttribute(trace, 'error', e.toString());
      await stopTrace(trace);
      rethrow;
    }
  }

  /// Track an async operation with custom metrics.
  ///
  /// Similar to trackOperation but allows you to add custom metrics based
  /// on the result.
  ///
  /// Example:
  /// ```dart
  /// final posts = await PerformanceHelper.trackOperationWithMetrics(
  ///   'fetch_posts',
  ///   () => apiService.getPosts(),
  ///   (result) => {'post_count': result.length},
  /// );
  /// ```
  static Future<T> trackOperationWithMetrics<T>(
    String traceName,
    Future<T> Function() operation,
    Map<String, int> Function(T result) computeMetrics,
  ) async {
    final trace = startTrace(traceName);
    try {
      final result = await operation();
      final metrics = computeMetrics(result);
      for (final entry in metrics.entries) {
        await putMetric(trace, entry.key, entry.value);
      }
      await stopTrace(trace);
      return result;
    } catch (e) {
      await setAttribute(trace, 'error', e.toString());
      await stopTrace(trace);
      rethrow;
    }
  }

  /// Check if Performance Monitoring is available and ready.
  static Future<bool> isAvailable() async {
    try {
      return await _performanceInstance.isPerformanceCollectionEnabled();
    } catch (e) {
      return false;
    }
  }

  /// Enable or disable Performance Monitoring collection.
  ///
  /// Useful for respecting user privacy settings.
  static Future<void> setPerformanceCollectionEnabled(bool enabled) async {
    try {
      await _performanceInstance.setPerformanceCollectionEnabled(enabled);
      if (kDebugMode) {
        developer.log('Performance collection ${enabled ? 'enabled' : 'disabled'}');
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log('Failed to set Performance collection: $e');
      }
    }
  }
}
