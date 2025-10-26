import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Service for monitoring network connectivity status.
///
/// Uses a singleton pattern to ensure consistent connectivity monitoring
/// throughout the application lifecycle.
///
/// Example:
/// ```dart
/// final service = ConnectivityService();
/// service.connectivityStream.listen((status) {
///   if (status == ConnectivityStatus.offline) {
///     // Handle offline state
///   }
/// });
/// ```
class ConnectivityService {
  factory ConnectivityService() => _instance;
  ConnectivityService._internal() {
    _init();
  }
  static final ConnectivityService _instance = ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<ConnectivityStatus> _connectivityController =
      StreamController<ConnectivityStatus>.broadcast();

  ConnectivityStatus _currentStatus = ConnectivityStatus.online;
  StreamSubscription<ConnectivityResult>? _subscription;

  /// Stream of connectivity status changes
  Stream<ConnectivityStatus> get connectivityStream =>
      _connectivityController.stream;

  /// Current connectivity status
  ConnectivityStatus get currentStatus => _currentStatus;

  /// Check if currently online
  bool get isOnline => _currentStatus == ConnectivityStatus.online;

  /// Check if currently offline
  bool get isOffline => _currentStatus == ConnectivityStatus.offline;

  void _init() {
    // Check initial connectivity
    _checkConnectivity();

    // Listen to connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) {
        _updateConnectivityStatus([result]);
      },
    );
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectivityStatus([result]);
    } catch (e) {
      print('ConnectivityService - Error checking connectivity: $e');
      _updateStatus(ConnectivityStatus.offline);
    }
  }

  void _updateConnectivityStatus(List<ConnectivityResult> results) {
    if (results.isEmpty) {
      _updateStatus(ConnectivityStatus.offline);
      return;
    }

    // Check if any result is not none
    final hasConnection = results.any(
      (result) => result != ConnectivityResult.none,
    );

    _updateStatus(
      hasConnection ? ConnectivityStatus.online : ConnectivityStatus.offline,
    );
  }

  void _updateStatus(ConnectivityStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      _connectivityController.add(status);
      print('ConnectivityService - Status changed to: $status');
    }
  }

  /// Manually refresh connectivity status
  Future<void> refresh() async {
    await _checkConnectivity();
  }

  /// Dispose of resources
  void dispose() {
    _subscription?.cancel();
    _connectivityController.close();
  }
}

/// Enum representing connectivity status
enum ConnectivityStatus {
  /// Device is connected to the internet
  online,

  /// Device is not connected to the internet
  offline,
}
