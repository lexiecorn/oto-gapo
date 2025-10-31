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
    DateTime? birthDate,
    num? age,
    required String nationality,
    String? emergencyContactNumber,
    // Driver's License information
    String? driversLicenseNumber,
    required DateTime driversLicenseExpirationDate,
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
    String? profileImage,
    /* 
    Membership Type
      1 - Super Admin
      2 - Admin
      3 - Member
   */
    num? membership_type,
  }) = _User;

  factory User.fromJson(Map<String, Object?> json) => _$UserFromJson(json);

  factory User.empty() => User(
        uid: '',
        firstName: '',
        middleName: '',
        lastName: '',
        gender: '',
        memberNumber: '',
        civilStatus: '',
        nationality: '',
        contactNumber: '',
        driversLicenseExpirationDate: DateTime.now(),
      );
}
