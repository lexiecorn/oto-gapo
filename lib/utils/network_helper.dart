import 'dart:async';
import 'dart:io';

/// Network helper utilities to check connectivity and prevent hanging
class NetworkHelper {
  /// Check if the device has internet connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      // Try to connect to a reliable server with a short timeout
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Check if PocketBase server is reachable
  static Future<bool> isPocketBaseReachable(String url) async {
    try {
      final uri = Uri.parse(url);
      final socket = await Socket.connect(uri.host, uri.port)
          .timeout(const Duration(seconds: 3));
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Safe network operation with timeout and fallback
  static Future<T?> safeNetworkCall<T>(
    Future<T> Function() operation, {
    Duration timeout = const Duration(seconds: 5),
    T? fallback,
  }) async {
    try {
      return await operation().timeout(timeout);
    } catch (e) {
      return fallback;
    }
  }
}




