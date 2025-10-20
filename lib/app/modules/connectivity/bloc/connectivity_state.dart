import 'package:equatable/equatable.dart';
import 'package:otogapo/services/connectivity_service.dart';
import 'package:otogapo/services/sync_service.dart';

/// State for connectivity monitoring and sync status
class ConnectivityState extends Equatable {
  const ConnectivityState({
    this.connectivityStatus = ConnectivityStatus.online,
    this.syncStatus = SyncStatus.idle,
    this.pendingActionsCount = 0,
    this.lastSyncTime,
  });

  /// Current connectivity status
  final ConnectivityStatus connectivityStatus;

  /// Current sync status
  final SyncStatus syncStatus;

  /// Number of pending actions to sync
  final int pendingActionsCount;

  /// Last successful sync time
  final DateTime? lastSyncTime;

  /// Check if device is online
  bool get isOnline => connectivityStatus == ConnectivityStatus.online;

  /// Check if device is offline
  bool get isOffline => connectivityStatus == ConnectivityStatus.offline;

  /// Check if currently syncing
  bool get isSyncing => syncStatus == SyncStatus.syncing;

  /// Check if has pending actions
  bool get hasPendingActions => pendingActionsCount > 0;

  /// Check if should show offline indicator
  bool get shouldShowOfflineIndicator => isOffline || hasPendingActions;

  ConnectivityState copyWith({
    ConnectivityStatus? connectivityStatus,
    SyncStatus? syncStatus,
    int? pendingActionsCount,
    DateTime? lastSyncTime,
  }) {
    return ConnectivityState(
      connectivityStatus: connectivityStatus ?? this.connectivityStatus,
      syncStatus: syncStatus ?? this.syncStatus,
      pendingActionsCount: pendingActionsCount ?? this.pendingActionsCount,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }

  @override
  List<Object?> get props => [
        connectivityStatus,
        syncStatus,
        pendingActionsCount,
        lastSyncTime,
      ];
}
