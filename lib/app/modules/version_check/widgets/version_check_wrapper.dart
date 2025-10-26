import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:otogapo/app/modules/version_check/bloc/version_check_cubit.dart';
import 'package:otogapo/app/modules/version_check/bloc/version_check_state.dart';
import 'package:otogapo/app/modules/version_check/widgets/update_dialog.dart';
import 'package:otogapo/services/version_check_service.dart';

/// Wrapper widget that handles version checking and displays update dialogs.
///
/// This widget should wrap the authenticated portion of the app to ensure
/// version checks happen after login. It automatically checks for updates
/// when mounted and displays appropriate dialogs.
class VersionCheckWrapper extends StatefulWidget {
  /// Creates a [VersionCheckWrapper] instance.
  const VersionCheckWrapper({
    required this.child,
    required this.cubit,
    required this.service,
    super.key,
  });

  /// The child widget to render.
  final Widget child;

  /// The version check cubit.
  final VersionCheckCubit cubit;

  /// The version check service.
  final VersionCheckService service;

  @override
  State<VersionCheckWrapper> createState() => _VersionCheckWrapperState();
}

class _VersionCheckWrapperState extends State<VersionCheckWrapper> {
  bool _hasShownDialog = false;

  @override
  void initState() {
    super.initState();
    // Check for updates on mount with a slight delay to ensure app is fully loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          widget.cubit.checkForUpdates();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VersionCheckCubit, VersionCheckState>(
      bloc: widget.cubit,
      listener: (context, state) {
        if (state is VersionCheckUpdateAvailable && !_hasShownDialog) {
          _hasShownDialog = true;
          _showUpdateDialog(context, state);
        }
      },
      child: widget.child,
    );
  }

  /// Shows the appropriate update dialog based on the state.
  void _showUpdateDialog(BuildContext context, VersionCheckUpdateAvailable state) {
    final versionString = '${state.config.currentVersion}+${state.config.currentBuildNumber.toInt()}';

    // Check if this version was already dismissed
    if (!state.isForced && widget.service.isVersionDismissed(versionString)) {
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: !state.isForced,
      builder: (context) => UpdateDialog(
        config: state.config,
        isForced: state.isForced,
        onDismiss: state.isForced
            ? null
            : () async {
                // Save dismissed version
                await widget.service.setDismissedVersion(versionString);
              },
      ),
    );
  }
}
