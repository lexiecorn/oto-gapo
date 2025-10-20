import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:otogapo/app/modules/connectivity/bloc/connectivity_state.dart';
import 'package:otogapo/services/connectivity_service.dart';
import 'package:otogapo/services/sync_service.dart';

/// Cubit for managing connectivity and sync state
class ConnectivityCubit extends Cubit<ConnectivityState> {
  ConnectivityCubit({
    required ConnectivityService connectivityService,
    required SyncService syncService,
  })  : _connectivityService = connectivityService,
        _syncService = syncService,
        super(const ConnectivityState()) {
    _init();
  }

  final ConnectivityService _connectivityService;
  final SyncService _syncService;

  StreamSubscription<ConnectivityStatus>? _connectivitySubscription;
  StreamSubscription<SyncStatus>? _syncSubscription;

  void _init() {
    // Initialize with current status
    emit(
      state.copyWith(
        connectivityStatus: _connectivityService.currentStatus,
        syncStatus: _syncService.currentStatus,
        pendingActionsCount: _syncService.pendingActionsCount,
      ),
    );

    // Listen to connectivity changes
    _connectivitySubscription = _connectivityService.connectivityStream.listen(_onConnectivityChanged);

    // Listen to sync status changes
    _syncSubscription = _syncService.syncStatusStream.listen(_onSyncStatusChanged);
  }

  void _onConnectivityChanged(ConnectivityStatus status) {
    emit(state.copyWith(connectivityStatus: status));

    // Trigger sync when coming back online
    if (status == ConnectivityStatus.online && state.hasPendingActions) {
      triggerSync();
    }
  }

  void _onSyncStatusChanged(SyncStatus status) {
    emit(
      state.copyWith(
        syncStatus: status,
        pendingActionsCount: _syncService.pendingActionsCount,
        lastSyncTime: status == SyncStatus.synced ? DateTime.now() : state.lastSyncTime,
      ),
    );
  }

  /// Manually trigger sync
  Future<void> triggerSync() async {
    if (!state.isOnline || state.isSyncing) {
      return;
    }

    await _syncService.syncPendingActions();
  }

  /// Refresh connectivity status
  Future<void> refreshConnectivity() async {
    await _connectivityService.refresh();
  }

  /// Get pending actions count
  int get pendingActionsCount => _syncService.pendingActionsCount;

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    _syncSubscription?.cancel();
    return super.close();
  }
}
