import 'package:authentication_repository/src/models/time_stamp_converter.dart';
import 'package:authentication_repository/src/models/vehicle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// import './emergency_contact.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String uid,
    required String firstName,
    String? middleName, // Optional middle name
    required String lastName,
    required String gender,
    required String memberNumber,
    required String civilStatus,
    @JsonKey(
      fromJson: TimestampConverter.fromJson,
      toJson: TimestampConverter.toJson,
    )
    required Timestamp dateOfBirth,
    required String birthplace,
    required String nationality,
    String? emergencyContactNumber,
    required List<Vehicle> vehicle,
    // Driver's License information
    String? driversLicenseNumber,
    @JsonKey(
      fromJson: TimestampConverter.fromJson,
      toJson: TimestampConverter.toJson,
    )
    required Timestamp driversLicenseExpirationDate,
    String? driversLicenseRestrictionCode,
    // Contact information
    required String contactNumber,
    // Medical information
    String? bloodType,
    String? religion,
    // Spouse information
    String? spouseName,
    String? spouseContactNumber,
    // Emergency Contact
    String? emergencyContactName,
    String? profile_image,
    /* 
    Membership Type
      1 - Super Admin
      2 - Admin
      3 - Member
   */
    num? membership_type,
  }) = _User;

  factory User.fromJson(Map<String, Object?> json) => _$UserFromJson(json);

  factory User.fromDoc(DocumentSnapshot<Object?> userDoc, String uid) {
    try {
      final data = userDoc.data()! as Map<String, dynamic>;
      data['uid'] = uid;
      return User.fromJson(data);
    } catch (e, stack) {
      print('Error in User.fromDoc: $e');
      print('Stack trace: $stack');
      print('Document data: ${userDoc.data()}');
      print('Document ID: ${userDoc.id}');
      rethrow; // Optionally rethrow to propagate the error
    }
  }

  factory User.empty() => User(
        uid: '',
        firstName: '',
        middleName: '',
        lastName: '',
        gender: '',
        memberNumber: '0',
        civilStatus: '',
        dateOfBirth: Timestamp.now(),
        birthplace: '',
        nationality: '',
        vehicle: [],
        contactNumber: '',
        driversLicenseExpirationDate: Timestamp.now(),
      );
}
