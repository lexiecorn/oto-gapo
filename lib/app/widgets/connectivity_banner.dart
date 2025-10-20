import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/connectivity/bloc/connectivity_cubit.dart';
import 'package:otogapo/app/modules/connectivity/bloc/connectivity_state.dart';

/// Animated banner that shows connectivity status and pending sync actions
class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, state) {
        // Don't show banner if online and no pending actions
        if (!state.shouldShowOfflineIndicator) {
          return const SizedBox.shrink();
        }

        return Animate(
          effects: [
            SlideEffect(
              begin: const Offset(0, -1),
              end: Offset.zero,
              duration: 300.ms,
              curve: Curves.easeOut,
            ),
            FadeEffect(duration: 200.ms),
          ],
          child: Material(
            color: _getBackgroundColor(state),
            elevation: 4,
            child: InkWell(
              onTap: state.isOffline ? null : () => context.read<ConnectivityCubit>().triggerSync(),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                child: Row(
                  children: [
                    _buildIcon(state),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getTitle(state),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (_getSubtitle(state).isNotEmpty)
                            Text(
                              _getSubtitle(state),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12.sp,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (state.isSyncing) ...[
                      SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ] else if (state.hasPendingActions && state.isOnline) ...[
                      Icon(
                        Icons.sync,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getBackgroundColor(ConnectivityState state) {
    if (state.isOffline) {
      return Colors.red.shade700;
    }
    if (state.isSyncing) {
      return Colors.blue.shade700;
    }
    if (state.hasPendingActions) {
      return Colors.orange.shade700;
    }
    return Colors.green.shade700;
  }

  Widget _buildIcon(ConnectivityState state) {
    IconData icon;
    if (state.isOffline) {
      icon = Icons.cloud_off;
    } else if (state.isSyncing) {
      icon = Icons.cloud_sync;
    } else if (state.hasPendingActions) {
      icon = Icons.cloud_upload;
    } else {
      icon = Icons.cloud_done;
    }

    return Icon(
      icon,
      color: Colors.white,
      size: 24.sp,
    );
  }

  String _getTitle(ConnectivityState state) {
    if (state.isOffline) {
      return 'No Internet Connection';
    }
    if (state.isSyncing) {
      return 'Syncing...';
    }
    if (state.hasPendingActions) {
      return '${state.pendingActionsCount} action${state.pendingActionsCount > 1 ? 's' : ''} pending';
    }
    return 'All synced';
  }

  String _getSubtitle(ConnectivityState state) {
    if (state.isOffline) {
      return state.hasPendingActions
          ? '${state.pendingActionsCount} actions will sync when online'
          : 'You can still browse cached content';
    }
    if (state.isSyncing) {
      return 'Syncing ${state.pendingActionsCount} actions';
    }
    if (state.hasPendingActions) {
      return 'Tap to sync now';
    }
    return '';
  }
}
