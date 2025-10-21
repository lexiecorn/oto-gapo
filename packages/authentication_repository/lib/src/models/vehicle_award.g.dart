// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_award.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VehicleAwardImpl _$$VehicleAwardImplFromJson(Map<String, dynamic> json) =>
    _$VehicleAwardImpl(
      id: json['id'] as String?,
      vehicleId: json['vehicleId'] as String,
      awardName: json['awardName'] as String,
      eventName: json['eventName'] as String,
      eventDate: DateTime.parse(json['eventDate'] as String),
      category: json['category'] as String?,
      placement: json['placement'] as String?,
      description: json['description'] as String?,
      awardImage: json['awardImage'] as String?,
      createdBy: json['createdBy'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$VehicleAwardImplToJson(_$VehicleAwardImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'vehicleId': instance.vehicleId,
      'awardName': instance.awardName,
      'eventName': instance.eventName,
      'eventDate': instance.eventDate.toIso8601String(),
      'category': instance.category,
      'placement': instance.placement,
      'description': instance.description,
      'awardImage': instance.awardImage,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
