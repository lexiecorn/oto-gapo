import 'dart:io' show Platform;

import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:otogapo/models/app_version_config.dart';
import 'package:pocketbase/pocketbase.dart';

/// Repository for fetching and comparing app version configuration.
///
/// Handles version checking logic comparing semantic versions and build numbers.
class VersionRepository {
  /// Creates a [VersionRepository] instance.
  VersionRepository();

  /// Gets the PocketBase instance for public access (no authentication required).
  PocketBase get _pocketBase {
    final url = FlavorConfig.instance.variables['pocketbaseUrl'] as String? ??
        'https://pb.lexserver.org';
    return PocketBase(url);
  }

  /// Gets the current platform identifier.
  String get _platform => Platform.isAndroid ? 'android' : 'ios';

  /// Fetches the version configuration for the current platform.
  ///
  /// Returns null if version checking is disabled or config is not found.
  Future<AppVersionConfig?> fetchVersionConfig() async {
    try {
      final pb = _pocketBase;

      // Check if PocketBase is available
      if (pb.baseUrl.isEmpty) {
        print(
            'VersionRepository: PocketBase not initialized, skipping version check');
        return null;
      }

      // Fetch version config for current platform (public access, no auth required)
      final result = await pb.collection('app_version_config').getList(
            page: 1,
            perPage: 1,
            filter: 'platform = "$_platform" && enabled = true',
          );

      if (result.items.isEmpty) {
        print(
            'VersionRepository: No version config found for platform $_platform');
        return null;
      }

      final record = result.items.first;
      print('VersionRepository: Found version config for $_platform');
      return AppVersionConfig.fromJson(record.toJson());
    } catch (e) {
      // Silently fail to not disrupt app startup
      // Version checking should be non-blocking
      print('VersionRepository: Error fetching version config: $e');
      return null;
    }
  }

  /// Checks if an update is needed by comparing versions.
  ///
  /// Returns true if [currentVersion] or [currentBuildNumber] is less than
  /// the required minimum.
  ///
  /// Comparison logic:
  /// 1. Compare semantic versions (major.minor.patch)
  /// 2. If versions are equal, compare build numbers
  /// 3. Return true if current version is less than required
  bool needsUpdate({
    required String currentVersion,
    required int currentBuildNumber,
    required String minVersion,
    required double minBuildNumber,
  }) {
    // Compare semantic versions
    final versionComparison =
        _compareSemanticVersion(currentVersion, minVersion);

    if (versionComparison < 0) {
      // Current version is older
      return true;
    } else if (versionComparison > 0) {
      // Current version is newer
      return false;
    }

    // Versions are equal, compare build numbers
    return currentBuildNumber < minBuildNumber.toInt();
  }

  /// Compares two semantic versions (e.g., "1.0.0").
  ///
  /// Returns:
  /// - Negative if [version1] < [version2]
  /// - Zero if versions are equal
  /// - Positive if [version1] > [version2]
  int _compareSemanticVersion(String version1, String version2) {
    final v1Parts = _parseVersion(version1);
    final v2Parts = _parseVersion(version2);

    // Compare major
    final majorDiff = v1Parts[0] - v2Parts[0];
    if (majorDiff != 0) return majorDiff;

    // Compare minor
    final minorDiff = v1Parts[1] - v2Parts[1];
    if (minorDiff != 0) return minorDiff;

    // Compare patch
    return v1Parts[2] - v2Parts[2];
  }

  /// Parses a semantic version string into [major, minor, patch].
  ///
  /// Defaults to [0, 0, 0] if parsing fails.
  List<int> _parseVersion(String version) {
    try {
      final parts = version.split('.');
      return [
        int.parse(parts[0]),
        parts.length > 1 ? int.parse(parts[1]) : 0,
        parts.length > 2 ? int.parse(parts[2]) : 0,
      ];
    } catch (e) {
      return [0, 0, 0];
    }
  }
}
