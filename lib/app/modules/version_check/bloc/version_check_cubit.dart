import 'package:bloc/bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:otogapo/app/modules/version_check/bloc/version_check_state.dart';
import 'package:otogapo/models/app_version_config.dart';
import 'package:otogapo/repositories/version_repository.dart';

/// Cubit for managing app version checking state.
///
/// Fetches version configuration from PocketBase and determines if an
/// update is required based on semantic version and build number comparison.
class VersionCheckCubit extends Cubit<VersionCheckState> {
  /// Creates a [VersionCheckCubit] instance.
  VersionCheckCubit({
    required VersionRepository versionRepository,
    required PackageInfo packageInfo,
  })  : _versionRepository = versionRepository,
        _packageInfo = packageInfo,
        super(const VersionCheckInitial());

  final VersionRepository _versionRepository;
  final PackageInfo _packageInfo;

  /// Checks if the app needs to be updated.
  ///
  /// Compares current app version with minimum required version from
  /// PocketBase configuration.
  Future<void> checkForUpdates() async {
    emit(const VersionCheckLoading());

    try {
      final config = await _versionRepository.fetchVersionConfig();

      // If no config found or version checking is disabled, consider up-to-date
      if (config == null) {
        emit(const VersionCheckUpToDate());
        return;
      }

      // Parse current version and build number
      final currentVersion = _packageInfo.version;
      final currentBuildNumber = int.parse(_packageInfo.buildNumber);

      // Debug logging
      print('VersionCheck: Current version: $currentVersion');
      print('VersionCheck: Current build: $currentBuildNumber');
      print('VersionCheck: Config min_version: ${config.minVersion}');
      print('VersionCheck: Config min_build_number: ${config.minBuildNumber}');
      print('VersionCheck: Config current_version: ${config.currentVersion}');
      print('VersionCheck: Config current_build_number: ${config.currentBuildNumber}');
      print('VersionCheck: Config force_update: ${config.forceUpdate}');

      // Compare against current_build_number (latest available), not min_build_number
      final needsUpdate = _versionRepository.needsUpdate(
        currentVersion: currentVersion,
        currentBuildNumber: currentBuildNumber,
        minVersion: config.currentVersion,
        minBuildNumber: config.currentBuildNumber,
      );

      print('VersionCheck: Needs update: $needsUpdate');

      if (!needsUpdate) {
        emit(const VersionCheckUpToDate());
        return;
      }

      // Update is required
      emit(
        VersionCheckUpdateAvailable(
          config: config,
          isForced: config.forceUpdate,
        ),
      );
    } catch (e) {
      // On error, silently pass to not disrupt app usage
      emit(VersionCheckError(message: e.toString()));
    }
  }
}
