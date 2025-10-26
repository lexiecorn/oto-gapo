import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing version check dismissal state.
///
/// Tracks which versions the user has dismissed "remind me later" for,
/// preventing repeated prompts for the same version.
class VersionCheckService {
  /// Creates a [VersionCheckService] instance.
  VersionCheckService({required SharedPreferences sharedPreferences})
      : _sharedPreferences = sharedPreferences;

  static const String _keyDismissedVersion = 'dismissed_version';

  final SharedPreferences _sharedPreferences;

  /// Gets the last dismissed version string.
  String? getDismissedVersion() {
    return _sharedPreferences.getString(_keyDismissedVersion);
  }

  /// Sets the dismissed version string.
  Future<void> setDismissedVersion(String version) async {
    await _sharedPreferences.setString(_keyDismissedVersion, version);
  }

  /// Clears the dismissed version.
  ///
  /// Useful after a successful update or when force update is enabled.
  Future<void> clearDismissedVersion() async {
    await _sharedPreferences.remove(_keyDismissedVersion);
  }

  /// Checks if a version has been dismissed.
  ///
  /// Returns true if [version] matches the stored dismissed version.
  bool isVersionDismissed(String version) {
    final dismissedVersion = getDismissedVersion();
    return dismissedVersion == version;
  }
}
