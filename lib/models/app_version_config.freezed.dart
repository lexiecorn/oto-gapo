// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_version_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AppVersionConfig _$AppVersionConfigFromJson(Map<String, dynamic> json) {
  return _AppVersionConfig.fromJson(json);
}

/// @nodoc
mixin _$AppVersionConfig {
  @JsonKey(name: 'id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'platform')
  String get platform => throw _privateConstructorUsedError;
  @JsonKey(name: 'min_version')
  String get minVersion => throw _privateConstructorUsedError;
  @JsonKey(name: 'min_build_number')
  double get minBuildNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_version')
  String get currentVersion => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_build_number')
  double get currentBuildNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'force_update')
  bool get forceUpdate => throw _privateConstructorUsedError;
  @JsonKey(name: 'release_notes')
  String? get releaseNotes => throw _privateConstructorUsedError;
  @JsonKey(name: 'store_url')
  String get storeUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'enabled')
  bool get enabled => throw _privateConstructorUsedError;
  @JsonKey(name: 'created')
  DateTime? get created => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated')
  DateTime? get updated => throw _privateConstructorUsedError;

  /// Serializes this AppVersionConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppVersionConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppVersionConfigCopyWith<AppVersionConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppVersionConfigCopyWith<$Res> {
  factory $AppVersionConfigCopyWith(
          AppVersionConfig value, $Res Function(AppVersionConfig) then) =
      _$AppVersionConfigCopyWithImpl<$Res, AppVersionConfig>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id') String id,
      @JsonKey(name: 'platform') String platform,
      @JsonKey(name: 'min_version') String minVersion,
      @JsonKey(name: 'min_build_number') double minBuildNumber,
      @JsonKey(name: 'current_version') String currentVersion,
      @JsonKey(name: 'current_build_number') double currentBuildNumber,
      @JsonKey(name: 'force_update') bool forceUpdate,
      @JsonKey(name: 'release_notes') String? releaseNotes,
      @JsonKey(name: 'store_url') String storeUrl,
      @JsonKey(name: 'enabled') bool enabled,
      @JsonKey(name: 'created') DateTime? created,
      @JsonKey(name: 'updated') DateTime? updated});
}

/// @nodoc
class _$AppVersionConfigCopyWithImpl<$Res, $Val extends AppVersionConfig>
    implements $AppVersionConfigCopyWith<$Res> {
  _$AppVersionConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppVersionConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? platform = null,
    Object? minVersion = null,
    Object? minBuildNumber = null,
    Object? currentVersion = null,
    Object? currentBuildNumber = null,
    Object? forceUpdate = null,
    Object? releaseNotes = freezed,
    Object? storeUrl = null,
    Object? enabled = null,
    Object? created = freezed,
    Object? updated = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      platform: null == platform
          ? _value.platform
          : platform // ignore: cast_nullable_to_non_nullable
              as String,
      minVersion: null == minVersion
          ? _value.minVersion
          : minVersion // ignore: cast_nullable_to_non_nullable
              as String,
      minBuildNumber: null == minBuildNumber
          ? _value.minBuildNumber
          : minBuildNumber // ignore: cast_nullable_to_non_nullable
              as double,
      currentVersion: null == currentVersion
          ? _value.currentVersion
          : currentVersion // ignore: cast_nullable_to_non_nullable
              as String,
      currentBuildNumber: null == currentBuildNumber
          ? _value.currentBuildNumber
          : currentBuildNumber // ignore: cast_nullable_to_non_nullable
              as double,
      forceUpdate: null == forceUpdate
          ? _value.forceUpdate
          : forceUpdate // ignore: cast_nullable_to_non_nullable
              as bool,
      releaseNotes: freezed == releaseNotes
          ? _value.releaseNotes
          : releaseNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      storeUrl: null == storeUrl
          ? _value.storeUrl
          : storeUrl // ignore: cast_nullable_to_non_nullable
              as String,
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      created: freezed == created
          ? _value.created
          : created // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updated: freezed == updated
          ? _value.updated
          : updated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppVersionConfigImplCopyWith<$Res>
    implements $AppVersionConfigCopyWith<$Res> {
  factory _$$AppVersionConfigImplCopyWith(_$AppVersionConfigImpl value,
          $Res Function(_$AppVersionConfigImpl) then) =
      __$$AppVersionConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id') String id,
      @JsonKey(name: 'platform') String platform,
      @JsonKey(name: 'min_version') String minVersion,
      @JsonKey(name: 'min_build_number') double minBuildNumber,
      @JsonKey(name: 'current_version') String currentVersion,
      @JsonKey(name: 'current_build_number') double currentBuildNumber,
      @JsonKey(name: 'force_update') bool forceUpdate,
      @JsonKey(name: 'release_notes') String? releaseNotes,
      @JsonKey(name: 'store_url') String storeUrl,
      @JsonKey(name: 'enabled') bool enabled,
      @JsonKey(name: 'created') DateTime? created,
      @JsonKey(name: 'updated') DateTime? updated});
}

/// @nodoc
class __$$AppVersionConfigImplCopyWithImpl<$Res>
    extends _$AppVersionConfigCopyWithImpl<$Res, _$AppVersionConfigImpl>
    implements _$$AppVersionConfigImplCopyWith<$Res> {
  __$$AppVersionConfigImplCopyWithImpl(_$AppVersionConfigImpl _value,
      $Res Function(_$AppVersionConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppVersionConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? platform = null,
    Object? minVersion = null,
    Object? minBuildNumber = null,
    Object? currentVersion = null,
    Object? currentBuildNumber = null,
    Object? forceUpdate = null,
    Object? releaseNotes = freezed,
    Object? storeUrl = null,
    Object? enabled = null,
    Object? created = freezed,
    Object? updated = freezed,
  }) {
    return _then(_$AppVersionConfigImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      platform: null == platform
          ? _value.platform
          : platform // ignore: cast_nullable_to_non_nullable
              as String,
      minVersion: null == minVersion
          ? _value.minVersion
          : minVersion // ignore: cast_nullable_to_non_nullable
              as String,
      minBuildNumber: null == minBuildNumber
          ? _value.minBuildNumber
          : minBuildNumber // ignore: cast_nullable_to_non_nullable
              as double,
      currentVersion: null == currentVersion
          ? _value.currentVersion
          : currentVersion // ignore: cast_nullable_to_non_nullable
              as String,
      currentBuildNumber: null == currentBuildNumber
          ? _value.currentBuildNumber
          : currentBuildNumber // ignore: cast_nullable_to_non_nullable
              as double,
      forceUpdate: null == forceUpdate
          ? _value.forceUpdate
          : forceUpdate // ignore: cast_nullable_to_non_nullable
              as bool,
      releaseNotes: freezed == releaseNotes
          ? _value.releaseNotes
          : releaseNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      storeUrl: null == storeUrl
          ? _value.storeUrl
          : storeUrl // ignore: cast_nullable_to_non_nullable
              as String,
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      created: freezed == created
          ? _value.created
          : created // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updated: freezed == updated
          ? _value.updated
          : updated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AppVersionConfigImpl implements _AppVersionConfig {
  const _$AppVersionConfigImpl(
      {@JsonKey(name: 'id') required this.id,
      @JsonKey(name: 'platform') required this.platform,
      @JsonKey(name: 'min_version') required this.minVersion,
      @JsonKey(name: 'min_build_number') required this.minBuildNumber,
      @JsonKey(name: 'current_version') required this.currentVersion,
      @JsonKey(name: 'current_build_number') required this.currentBuildNumber,
      @JsonKey(name: 'force_update') this.forceUpdate = false,
      @JsonKey(name: 'release_notes') this.releaseNotes,
      @JsonKey(name: 'store_url') required this.storeUrl,
      @JsonKey(name: 'enabled') this.enabled = true,
      @JsonKey(name: 'created') this.created,
      @JsonKey(name: 'updated') this.updated});

  factory _$AppVersionConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppVersionConfigImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final String id;
  @override
  @JsonKey(name: 'platform')
  final String platform;
  @override
  @JsonKey(name: 'min_version')
  final String minVersion;
  @override
  @JsonKey(name: 'min_build_number')
  final double minBuildNumber;
  @override
  @JsonKey(name: 'current_version')
  final String currentVersion;
  @override
  @JsonKey(name: 'current_build_number')
  final double currentBuildNumber;
  @override
  @JsonKey(name: 'force_update')
  final bool forceUpdate;
  @override
  @JsonKey(name: 'release_notes')
  final String? releaseNotes;
  @override
  @JsonKey(name: 'store_url')
  final String storeUrl;
  @override
  @JsonKey(name: 'enabled')
  final bool enabled;
  @override
  @JsonKey(name: 'created')
  final DateTime? created;
  @override
  @JsonKey(name: 'updated')
  final DateTime? updated;

  @override
  String toString() {
    return 'AppVersionConfig(id: $id, platform: $platform, minVersion: $minVersion, minBuildNumber: $minBuildNumber, currentVersion: $currentVersion, currentBuildNumber: $currentBuildNumber, forceUpdate: $forceUpdate, releaseNotes: $releaseNotes, storeUrl: $storeUrl, enabled: $enabled, created: $created, updated: $updated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppVersionConfigImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.platform, platform) ||
                other.platform == platform) &&
            (identical(other.minVersion, minVersion) ||
                other.minVersion == minVersion) &&
            (identical(other.minBuildNumber, minBuildNumber) ||
                other.minBuildNumber == minBuildNumber) &&
            (identical(other.currentVersion, currentVersion) ||
                other.currentVersion == currentVersion) &&
            (identical(other.currentBuildNumber, currentBuildNumber) ||
                other.currentBuildNumber == currentBuildNumber) &&
            (identical(other.forceUpdate, forceUpdate) ||
                other.forceUpdate == forceUpdate) &&
            (identical(other.releaseNotes, releaseNotes) ||
                other.releaseNotes == releaseNotes) &&
            (identical(other.storeUrl, storeUrl) ||
                other.storeUrl == storeUrl) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.created, created) || other.created == created) &&
            (identical(other.updated, updated) || other.updated == updated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      platform,
      minVersion,
      minBuildNumber,
      currentVersion,
      currentBuildNumber,
      forceUpdate,
      releaseNotes,
      storeUrl,
      enabled,
      created,
      updated);

  /// Create a copy of AppVersionConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppVersionConfigImplCopyWith<_$AppVersionConfigImpl> get copyWith =>
      __$$AppVersionConfigImplCopyWithImpl<_$AppVersionConfigImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppVersionConfigImplToJson(
      this,
    );
  }
}

abstract class _AppVersionConfig implements AppVersionConfig {
  const factory _AppVersionConfig(
      {@JsonKey(name: 'id') required final String id,
      @JsonKey(name: 'platform') required final String platform,
      @JsonKey(name: 'min_version') required final String minVersion,
      @JsonKey(name: 'min_build_number') required final double minBuildNumber,
      @JsonKey(name: 'current_version') required final String currentVersion,
      @JsonKey(name: 'current_build_number')
      required final double currentBuildNumber,
      @JsonKey(name: 'force_update') final bool forceUpdate,
      @JsonKey(name: 'release_notes') final String? releaseNotes,
      @JsonKey(name: 'store_url') required final String storeUrl,
      @JsonKey(name: 'enabled') final bool enabled,
      @JsonKey(name: 'created') final DateTime? created,
      @JsonKey(name: 'updated')
      final DateTime? updated}) = _$AppVersionConfigImpl;

  factory _AppVersionConfig.fromJson(Map<String, dynamic> json) =
      _$AppVersionConfigImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  String get id;
  @override
  @JsonKey(name: 'platform')
  String get platform;
  @override
  @JsonKey(name: 'min_version')
  String get minVersion;
  @override
  @JsonKey(name: 'min_build_number')
  double get minBuildNumber;
  @override
  @JsonKey(name: 'current_version')
  String get currentVersion;
  @override
  @JsonKey(name: 'current_build_number')
  double get currentBuildNumber;
  @override
  @JsonKey(name: 'force_update')
  bool get forceUpdate;
  @override
  @JsonKey(name: 'release_notes')
  String? get releaseNotes;
  @override
  @JsonKey(name: 'store_url')
  String get storeUrl;
  @override
  @JsonKey(name: 'enabled')
  bool get enabled;
  @override
  @JsonKey(name: 'created')
  DateTime? get created;
  @override
  @JsonKey(name: 'updated')
  DateTime? get updated;

  /// Create a copy of AppVersionConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppVersionConfigImplCopyWith<_$AppVersionConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
