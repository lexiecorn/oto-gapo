// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_version_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppVersionConfigImpl _$$AppVersionConfigImplFromJson(
        Map<String, dynamic> json) =>
    _$AppVersionConfigImpl(
      id: json['id'] as String,
      platform: json['platform'] as String,
      minVersion: json['min_version'] as String,
      minBuildNumber: (json['min_build_number'] as num).toDouble(),
      currentVersion: json['current_version'] as String,
      currentBuildNumber: (json['current_build_number'] as num).toDouble(),
      forceUpdate: json['force_update'] as bool? ?? false,
      releaseNotes: json['release_notes'] as String?,
      storeUrl: json['store_url'] as String,
      enabled: json['enabled'] as bool? ?? true,
      created: json['created'] == null
          ? null
          : DateTime.parse(json['created'] as String),
      updated: json['updated'] == null
          ? null
          : DateTime.parse(json['updated'] as String),
    );

Map<String, dynamic> _$$AppVersionConfigImplToJson(
        _$AppVersionConfigImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'platform': instance.platform,
      'min_version': instance.minVersion,
      'min_build_number': instance.minBuildNumber,
      'current_version': instance.currentVersion,
      'current_build_number': instance.currentBuildNumber,
      'force_update': instance.forceUpdate,
      'release_notes': instance.releaseNotes,
      'store_url': instance.storeUrl,
      'enabled': instance.enabled,
      'created': instance.created?.toIso8601String(),
      'updated': instance.updated?.toIso8601String(),
    };
