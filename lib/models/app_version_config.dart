import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_version_config.freezed.dart';
part 'app_version_config.g.dart';

/// Model for app version configuration stored in PocketBase.
///
/// Contains information about minimum required version, current version,
/// force update flags, and store URLs for managing app updates.
@freezed
class AppVersionConfig with _$AppVersionConfig {
  /// Creates an [AppVersionConfig] instance.
  ///
  /// [platform] must be 'android' or 'ios'
  /// [minVersion] is the minimum required semantic version (e.g., "1.0.0")
  /// [minBuildNumber] is the minimum required build number
  /// [currentVersion] is the latest available semantic version
  /// [currentBuildNumber] is the latest available build number
  /// [forceUpdate] indicates if the update is mandatory
  /// [releaseNotes] describes what's new in the update
  /// [storeUrl] is the deep link to Play Store/App Store
  /// [enabled] determines if version checking is active
  const factory AppVersionConfig({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'platform') required String platform,
    @JsonKey(name: 'min_version') required String minVersion,
    @JsonKey(name: 'min_build_number') required double minBuildNumber,
    @JsonKey(name: 'current_version') required String currentVersion,
    @JsonKey(name: 'current_build_number') required double currentBuildNumber,
    @JsonKey(name: 'force_update') @Default(false) bool forceUpdate,
    @JsonKey(name: 'release_notes') String? releaseNotes,
    @JsonKey(name: 'store_url') required String storeUrl,
    @JsonKey(name: 'enabled') @Default(true) bool enabled,
    @JsonKey(name: 'created') DateTime? created,
    @JsonKey(name: 'updated') DateTime? updated,
  }) = _AppVersionConfig;

  /// Creates an [AppVersionConfig] from JSON.
  factory AppVersionConfig.fromJson(Map<String, dynamic> json) =>
      _$AppVersionConfigFromJson(json);
}
