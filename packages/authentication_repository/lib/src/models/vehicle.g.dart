// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VehicleImpl _$$VehicleImplFromJson(Map<String, dynamic> json) =>
    _$VehicleImpl(
      make: json['make'] as String,
      model: json['model'] as String,
      year: (json['year'] as num).toInt(),
      type: json['type'] as String,
      color: json['color'] as String,
      plateNumber: json['plateNumber'] as String,
      primaryPhoto: json['primaryPhoto'] as String?,
      photos:
          (json['photos'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$VehicleImplToJson(_$VehicleImpl instance) =>
    <String, dynamic>{
      'make': instance.make,
      'model': instance.model,
      'year': instance.year,
      'type': instance.type,
      'color': instance.color,
      'plateNumber': instance.plateNumber,
      'primaryPhoto': instance.primaryPhoto,
      'photos': instance.photos,
    };
