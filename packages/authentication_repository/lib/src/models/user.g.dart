// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      uid: json['uid'] as String,
      firstName: json['firstName'] as String,
      middleName: json['middleName'] as String?,
      lastName: json['lastName'] as String,
      gender: json['gender'] as String,
      memberNumber: json['memberNumber'] as String,
      civilStatus: json['civilStatus'] as String,
      dateOfBirth: TimestampConverter.fromJson(json['dateOfBirth']),
      birthplace: json['birthplace'] as String,
      nationality: json['nationality'] as String,
      emergencyContactNumber: json['emergencyContactNumber'] as String?,
      driversLicenseNumber: json['driversLicenseNumber'] as String?,
      driversLicenseExpirationDate:
          TimestampConverter.fromJson(json['driversLicenseExpirationDate']),
      driversLicenseRestrictionCode:
          json['driversLicenseRestrictionCode'] as String?,
      contactNumber: json['contactNumber'] as String,
      bloodType: json['bloodType'] as String?,
      religion: json['religion'] as String?,
      spouseName: json['spouseName'] as String?,
      spouseContactNumber: json['spouseContactNumber'] as String?,
      emergencyContactName: json['emergencyContactName'] as String?,
      profile_image: json['profile_image'] as String?,
      membership_type: json['membership_type'] as num?,
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'firstName': instance.firstName,
      'middleName': instance.middleName,
      'lastName': instance.lastName,
      'gender': instance.gender,
      'memberNumber': instance.memberNumber,
      'civilStatus': instance.civilStatus,
      'dateOfBirth': TimestampConverter.toJson(instance.dateOfBirth),
      'birthplace': instance.birthplace,
      'nationality': instance.nationality,
      'emergencyContactNumber': instance.emergencyContactNumber,
      'driversLicenseNumber': instance.driversLicenseNumber,
      'driversLicenseExpirationDate':
          TimestampConverter.toJson(instance.driversLicenseExpirationDate),
      'driversLicenseRestrictionCode': instance.driversLicenseRestrictionCode,
      'contactNumber': instance.contactNumber,
      'bloodType': instance.bloodType,
      'religion': instance.religion,
      'spouseName': instance.spouseName,
      'spouseContactNumber': instance.spouseContactNumber,
      'emergencyContactName': instance.emergencyContactName,
      'profile_image': instance.profile_image,
      'membership_type': instance.membership_type,
    };
