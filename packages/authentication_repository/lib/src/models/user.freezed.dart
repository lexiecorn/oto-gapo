// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
/// @nodoc
mixin _$User {
  String get uid; // Add this line
  String get firstName => throw _privateConstructorUsedError;
  String? get middleName => throw _privateConstructorUsedError; // Optional middle name
  String get lastName => throw _privateConstructorUsedError;
  String get gender => throw _privateConstructorUsedError;
  String get memberNumber => throw _privateConstructorUsedError;
  String get civilStatus => throw _privateConstructorUsedError;
  @JsonKey(fromJson: TimestampConverter.fromJson, toJson: TimestampConverter.toJson)
  Timestamp get dateOfBirth => throw _privateConstructorUsedError;
  String get birthplace => throw _privateConstructorUsedError;
  String get nationality => throw _privateConstructorUsedError;
  String? get emergencyContactNumber => throw _privateConstructorUsedError;
  List<Vehicle> get vehicle => throw _privateConstructorUsedError; // Driver's License information
  String? get driversLicenseNumber => throw _privateConstructorUsedError;
  @JsonKey(fromJson: TimestampConverter.fromJson, toJson: TimestampConverter.toJson)
  Timestamp get driversLicenseExpirationDate => throw _privateConstructorUsedError;
  String? get driversLicenseRestrictionCode => throw _privateConstructorUsedError; // Contact information
  String get contactNumber => throw _privateConstructorUsedError;
  String? get bloodType => throw _privateConstructorUsedError;
  String? get religion => throw _privateConstructorUsedError;
  // Spouse information
  String? get spouseName => throw _privateConstructorUsedError;
  String? get spouseContactNumber => throw _privateConstructorUsedError;
  // Emergency Contact
  String? get emergencyContactName => throw _privateConstructorUsedError;
  String? get profile_image => throw _privateConstructorUsedError;
  num? get membership_type => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) = _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call(
      {String firstName,
      String? middleName,
      String lastName,
      String gender,
      String memberNumber,
      String civilStatus,
      @JsonKey(fromJson: TimestampConverter.fromJson, toJson: TimestampConverter.toJson) Timestamp dateOfBirth,
      String birthplace,
      String nationality,
      String? emergencyContactNumber,
      List<Vehicle> vehicle,
      String? driversLicenseNumber,
      @JsonKey(fromJson: TimestampConverter.fromJson, toJson: TimestampConverter.toJson)
      Timestamp driversLicenseExpirationDate,
      String? driversLicenseRestrictionCode,
      String contactNumber,
      String? bloodType,
      String? religion,
      String? spouseName,
      String? spouseContactNumber,
      String? emergencyContactName,
      String? profile_image,
      num? membership_type});
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User> implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? firstName = null,
    Object? middleName = freezed,
    Object? lastName = null,
    Object? gender = null,
    Object? memberNumber = null,
    Object? civilStatus = null,
    Object? dateOfBirth = null,
    Object? birthplace = null,
    Object? nationality = null,
    Object? emergencyContactNumber = freezed,
    Object? vehicle = null,
    Object? driversLicenseNumber = freezed,
    Object? driversLicenseExpirationDate = null,
    Object? driversLicenseRestrictionCode = freezed,
    Object? contactNumber = null,
    Object? bloodType = freezed,
    Object? religion = freezed,
    Object? spouseName = freezed,
    Object? spouseContactNumber = freezed,
    Object? emergencyContactName = freezed,
    Object? profile_image = freezed,
    Object? membership_type = freezed,
  }) {
    return _then(_value.copyWith(
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      middleName: freezed == middleName
          ? _value.middleName
          : middleName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String,
      memberNumber: null == memberNumber
          ? _value.memberNumber
          : memberNumber // ignore: cast_nullable_to_non_nullable
              as String,
      civilStatus: null == civilStatus
          ? _value.civilStatus
          : civilStatus // ignore: cast_nullable_to_non_nullable
              as String,
      dateOfBirth: null == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as Timestamp,
      birthplace: null == birthplace
          ? _value.birthplace
          : birthplace // ignore: cast_nullable_to_non_nullable
              as String,
      nationality: null == nationality
          ? _value.nationality
          : nationality // ignore: cast_nullable_to_non_nullable
              as String,
      emergencyContactNumber: freezed == emergencyContactNumber
          ? _value.emergencyContactNumber
          : emergencyContactNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      vehicle: null == vehicle
          ? _value.vehicle
          : vehicle // ignore: cast_nullable_to_non_nullable
              as List<Vehicle>,
      driversLicenseNumber: freezed == driversLicenseNumber
          ? _value.driversLicenseNumber
          : driversLicenseNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      driversLicenseExpirationDate: null == driversLicenseExpirationDate
          ? _value.driversLicenseExpirationDate
          : driversLicenseExpirationDate // ignore: cast_nullable_to_non_nullable
              as Timestamp,
      driversLicenseRestrictionCode: freezed == driversLicenseRestrictionCode
          ? _value.driversLicenseRestrictionCode
          : driversLicenseRestrictionCode // ignore: cast_nullable_to_non_nullable
              as String?,
      contactNumber: null == contactNumber
          ? _value.contactNumber
          : contactNumber // ignore: cast_nullable_to_non_nullable
              as String,
      bloodType: freezed == bloodType
          ? _value.bloodType
          : bloodType // ignore: cast_nullable_to_non_nullable
              as String?,
      religion: freezed == religion
          ? _value.religion
          : religion // ignore: cast_nullable_to_non_nullable
              as String?,
      spouseName: freezed == spouseName
          ? _value.spouseName
          : spouseName // ignore: cast_nullable_to_non_nullable
              as String?,
      spouseContactNumber: freezed == spouseContactNumber
          ? _value.spouseContactNumber
          : spouseContactNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      emergencyContactName: freezed == emergencyContactName
          ? _value.emergencyContactName
          : emergencyContactName // ignore: cast_nullable_to_non_nullable
              as String?,
      profile_image: freezed == profile_image
          ? _value.profile_image
          : profile_image // ignore: cast_nullable_to_non_nullable
              as String?,
      membership_type: freezed == membership_type
          ? _value.membership_type
          : membership_type // ignore: cast_nullable_to_non_nullable
              as num?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(_$UserImpl value, $Res Function(_$UserImpl) then) = __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String firstName,
      String? middleName,
      String lastName,
      String gender,
      String memberNumber,
      String civilStatus,
      @JsonKey(fromJson: TimestampConverter.fromJson, toJson: TimestampConverter.toJson) Timestamp dateOfBirth,
      String birthplace,
      String nationality,
      String? emergencyContactNumber,
      List<Vehicle> vehicle,
      String? driversLicenseNumber,
      @JsonKey(fromJson: TimestampConverter.fromJson, toJson: TimestampConverter.toJson)
      Timestamp driversLicenseExpirationDate,
      String? driversLicenseRestrictionCode,
      String contactNumber,
      String? bloodType,
      String? religion,
      String? spouseName,
      String? spouseContactNumber,
      String? emergencyContactName,
      String? profile_image,
      num? membership_type});
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res> extends _$UserCopyWithImpl<$Res, _$UserImpl> implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = freezed,
    Object? firstName = null,
    Object? middleName = freezed,
    Object? lastName = null,
    Object? gender = null,
    Object? memberNumber = null,
    Object? civilStatus = null,
    Object? dateOfBirth = null,
    Object? birthplace = null,
    Object? nationality = null,
    Object? emergencyContactNumber = freezed,
    Object? vehicle = null,
    Object? driversLicenseNumber = freezed,
    Object? driversLicenseExpirationDate = null,
    Object? driversLicenseRestrictionCode = freezed,
    Object? contactNumber = null,
    Object? bloodType = freezed,
    Object? religion = freezed,
    Object? spouseName = freezed,
    Object? spouseContactNumber = freezed,
    Object? emergencyContactName = freezed,
    Object? profile_image = freezed,
    Object? membership_type = freezed,
  }) {
    return _then(_$UserImpl(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String, // Add this line
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      middleName: freezed == middleName
          ? _value.middleName
          : middleName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String,
      memberNumber: null == memberNumber
          ? _value.memberNumber
          : memberNumber // ignore: cast_nullable_to_non_nullable
              as String,
      civilStatus: null == civilStatus
          ? _value.civilStatus
          : civilStatus // ignore: cast_nullable_to_non_nullable
              as String,
      dateOfBirth: null == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as Timestamp,
      birthplace: null == birthplace
          ? _value.birthplace
          : birthplace // ignore: cast_nullable_to_non_nullable
              as String,
      nationality: null == nationality
          ? _value.nationality
          : nationality // ignore: cast_nullable_to_non_nullable
              as String,
      emergencyContactNumber: freezed == emergencyContactNumber
          ? _value.emergencyContactNumber
          : emergencyContactNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      vehicle: null == vehicle
          ? _value._vehicle
          : vehicle // ignore: cast_nullable_to_non_nullable
              as List<Vehicle>,
      driversLicenseNumber: freezed == driversLicenseNumber
          ? _value.driversLicenseNumber
          : driversLicenseNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      driversLicenseExpirationDate: null == driversLicenseExpirationDate
          ? _value.driversLicenseExpirationDate
          : driversLicenseExpirationDate // ignore: cast_nullable_to_non_nullable
              as Timestamp,
      driversLicenseRestrictionCode: freezed == driversLicenseRestrictionCode
          ? _value.driversLicenseRestrictionCode
          : driversLicenseRestrictionCode // ignore: cast_nullable_to_non_nullable
              as String?,
      contactNumber: null == contactNumber
          ? _value.contactNumber
          : contactNumber // ignore: cast_nullable_to_non_nullable
              as String,
      bloodType: freezed == bloodType
          ? _value.bloodType
          : bloodType // ignore: cast_nullable_to_non_nullable
              as String?,
      religion: freezed == religion
          ? _value.religion
          : religion // ignore: cast_nullable_to_non_nullable
              as String?,
      spouseName: freezed == spouseName
          ? _value.spouseName
          : spouseName // ignore: cast_nullable_to_non_nullable
              as String?,
      spouseContactNumber: freezed == spouseContactNumber
          ? _value.spouseContactNumber
          : spouseContactNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      emergencyContactName: freezed == emergencyContactName
          ? _value.emergencyContactName
          : emergencyContactName // ignore: cast_nullable_to_non_nullable
              as String?,
      profile_image: freezed == profile_image
          ? _value.profile_image
          : profile_image // ignore: cast_nullable_to_non_nullable
              as String?,
      membership_type: freezed == membership_type
          ? _value.membership_type
          : membership_type // ignore: cast_nullable_to_non_nullable
              as num?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserImpl implements _User {
  const _$UserImpl(
      {required this.uid, // Add this line
      required this.firstName,
      this.middleName,
      required this.lastName,
      required this.gender,
      required this.memberNumber,
      required this.civilStatus,
      @JsonKey(fromJson: TimestampConverter.fromJson, toJson: TimestampConverter.toJson) required this.dateOfBirth,
      required this.birthplace,
      required this.nationality,
      this.emergencyContactNumber,
      required final List<Vehicle> vehicle,
      this.driversLicenseNumber,
      @JsonKey(fromJson: TimestampConverter.fromJson, toJson: TimestampConverter.toJson)
      required this.driversLicenseExpirationDate,
      this.driversLicenseRestrictionCode,
      required this.contactNumber,
      this.bloodType,
      this.religion,
      this.spouseName,
      this.spouseContactNumber,
      this.emergencyContactName,
      this.profile_image,
      this.membership_type})
      : _vehicle = vehicle;

  factory _$UserImpl.fromJson(Map<String, dynamic> json) => _$$UserImplFromJson(json);
  @override
  final String uid; // Add this line
  @override
  final String firstName;
  @override
  final String? middleName;
// Optional middle name
  @override
  final String lastName;
  @override
  final String gender;
  @override
  final String memberNumber;
  @override
  final String civilStatus;
  @override
  @JsonKey(fromJson: TimestampConverter.fromJson, toJson: TimestampConverter.toJson)
  final Timestamp dateOfBirth;
  @override
  final String birthplace;
  @override
  final String nationality;
  @override
  final String? emergencyContactNumber;
  final List<Vehicle> _vehicle;
  @override
  List<Vehicle> get vehicle {
    if (_vehicle is EqualUnmodifiableListView) return _vehicle;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_vehicle);
  }

// Driver's License information
  @override
  final String? driversLicenseNumber;
  @override
  @JsonKey(fromJson: TimestampConverter.fromJson, toJson: TimestampConverter.toJson)
  final Timestamp driversLicenseExpirationDate;
  @override
  final String? driversLicenseRestrictionCode;
// Contact information
  @override
  final String contactNumber;
// Medical information
  @override
  final String? bloodType;
  @override
  final String? religion;
// Spouse information
  @override
  final String? spouseName;
  @override
  final String? spouseContactNumber;
// Emergency Contact
  @override
  final String? emergencyContactName;
  @override
  final String? profile_image;
  @override
  final num? membership_type;

  @override
  String toString() {
    return 'User(firstName: $firstName, middleName: $middleName, lastName: $lastName, gender: $gender, memberNumber: $memberNumber, civilStatus: $civilStatus, dateOfBirth: $dateOfBirth, birthplace: $birthplace, nationality: $nationality, emergencyContactNumber: $emergencyContactNumber, vehicle: $vehicle, driversLicenseNumber: $driversLicenseNumber, driversLicenseExpirationDate: $driversLicenseExpirationDate, driversLicenseRestrictionCode: $driversLicenseRestrictionCode, contactNumber: $contactNumber, bloodType: $bloodType, religion: $religion, spouseName: $spouseName, spouseContactNumber: $spouseContactNumber, emergencyContactName: $emergencyContactName, profile_image: $profile_image, membership_type: $membership_type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.firstName, firstName) || other.firstName == firstName) &&
            (identical(other.middleName, middleName) || other.middleName == middleName) &&
            (identical(other.lastName, lastName) || other.lastName == lastName) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.memberNumber, memberNumber) || other.memberNumber == memberNumber) &&
            (identical(other.civilStatus, civilStatus) || other.civilStatus == civilStatus) &&
            (identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth) &&
            (identical(other.birthplace, birthplace) || other.birthplace == birthplace) &&
            (identical(other.nationality, nationality) || other.nationality == nationality) &&
            (identical(other.emergencyContactNumber, emergencyContactNumber) ||
                other.emergencyContactNumber == emergencyContactNumber) &&
            const DeepCollectionEquality().equals(other._vehicle, _vehicle) &&
            (identical(other.driversLicenseNumber, driversLicenseNumber) ||
                other.driversLicenseNumber == driversLicenseNumber) &&
            (identical(other.driversLicenseExpirationDate, driversLicenseExpirationDate) ||
                other.driversLicenseExpirationDate == driversLicenseExpirationDate) &&
            (identical(other.driversLicenseRestrictionCode, driversLicenseRestrictionCode) ||
                other.driversLicenseRestrictionCode == driversLicenseRestrictionCode) &&
            (identical(other.contactNumber, contactNumber) || other.contactNumber == contactNumber) &&
            (identical(other.bloodType, bloodType) || other.bloodType == bloodType) &&
            (identical(other.religion, religion) || other.religion == religion) &&
            (identical(other.spouseName, spouseName) || other.spouseName == spouseName) &&
            (identical(other.spouseContactNumber, spouseContactNumber) ||
                other.spouseContactNumber == spouseContactNumber) &&
            (identical(other.emergencyContactName, emergencyContactName) ||
                other.emergencyContactName == emergencyContactName) &&
            (identical(other.profile_image, profile_image) || other.profile_image == profile_image) &&
            (identical(other.membership_type, membership_type) || other.membership_type == membership_type));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        firstName,
        middleName,
        lastName,
        gender,
        memberNumber,
        civilStatus,
        dateOfBirth,
        birthplace,
        nationality,
        emergencyContactNumber,
        const DeepCollectionEquality().hash(_vehicle),
        driversLicenseNumber,
        driversLicenseExpirationDate,
        driversLicenseRestrictionCode,
        contactNumber,
        bloodType,
        religion,
        spouseName,
        spouseContactNumber,
        emergencyContactName,
        profile_image,
        membership_type
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith => __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(
      this,
    );
  }
}

abstract class _User implements User {
  const factory _User(
      {required final String uid,
      required final String firstName,
      final String? middleName,
      required final String lastName,
      required final String gender,
      required final String memberNumber,
      required final String civilStatus,
      @JsonKey(fromJson: TimestampConverter.fromJson, toJson: TimestampConverter.toJson)
      required final Timestamp dateOfBirth,
      required final String birthplace,
      required final String nationality,
      final String? emergencyContactNumber,
      required final List<Vehicle> vehicle,
      final String? driversLicenseNumber,
      @JsonKey(fromJson: TimestampConverter.fromJson, toJson: TimestampConverter.toJson)
      required final Timestamp driversLicenseExpirationDate,
      final String? driversLicenseRestrictionCode,
      required final String contactNumber,
      final String? bloodType,
      final String? religion,
      final String? spouseName,
      final String? spouseContactNumber,
      final String? emergencyContactName,
      final String? profile_image,
      final num? membership_type}) = _$UserImpl;

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  @override
  String get firstName;
  @override
  String? get middleName;
  @override // Optional middle name
  String get lastName;
  @override
  String get gender;
  @override
  String get memberNumber;
  @override
  String get civilStatus;
  @override
  @JsonKey(fromJson: TimestampConverter.fromJson, toJson: TimestampConverter.toJson)
  Timestamp get dateOfBirth;
  @override
  String get birthplace;
  @override
  String get nationality;
  @override
  String? get emergencyContactNumber;
  @override
  List<Vehicle> get vehicle;
  @override // Driver's License information
  String? get driversLicenseNumber;
  @override
  @JsonKey(fromJson: TimestampConverter.fromJson, toJson: TimestampConverter.toJson)
  Timestamp get driversLicenseExpirationDate;
  @override
  String? get driversLicenseRestrictionCode;
  @override // Contact information
  String get contactNumber;
  @override // Medical information
  String? get bloodType;
  @override
  String? get religion;
  @override // Spouse information
  String? get spouseName;
  @override
  String? get spouseContactNumber;
  @override // Emergency Contact
  String? get emergencyContactName;
  @override
  String? get profile_image;
  @override
  num? get membership_type;
  @override
  @JsonKey(ignore: true)
  _$$UserImplCopyWith<_$UserImpl> get copyWith => throw _privateConstructorUsedError;
}
