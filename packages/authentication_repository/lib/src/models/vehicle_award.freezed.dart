// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vehicle_award.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

VehicleAward _$VehicleAwardFromJson(Map<String, dynamic> json) {
  return _VehicleAward.fromJson(json);
}

/// @nodoc
mixin _$VehicleAward {
  String? get id => throw _privateConstructorUsedError; // PocketBase record ID
  String get vehicleId =>
      throw _privateConstructorUsedError; // Relation to vehicles collection
  String get awardName =>
      throw _privateConstructorUsedError; // e.g., "Best Modified Car"
  String get eventName =>
      throw _privateConstructorUsedError; // e.g., "Manila Auto Show 2025"
  DateTime get eventDate =>
      throw _privateConstructorUsedError; // Date of the event
  String? get category =>
      throw _privateConstructorUsedError; // e.g., "Modified", "Classic", "Best in Show"
  String? get placement =>
      throw _privateConstructorUsedError; // e.g., "1st Place", "Winner", "Champion"
  String? get description =>
      throw _privateConstructorUsedError; // Optional additional details
  String? get awardImage =>
      throw _privateConstructorUsedError; // File name for award photo/certificate
  String? get createdBy =>
      throw _privateConstructorUsedError; // User who created the award entry
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this VehicleAward to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VehicleAward
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VehicleAwardCopyWith<VehicleAward> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VehicleAwardCopyWith<$Res> {
  factory $VehicleAwardCopyWith(
          VehicleAward value, $Res Function(VehicleAward) then) =
      _$VehicleAwardCopyWithImpl<$Res, VehicleAward>;
  @useResult
  $Res call(
      {String? id,
      String vehicleId,
      String awardName,
      String eventName,
      DateTime eventDate,
      String? category,
      String? placement,
      String? description,
      String? awardImage,
      String? createdBy,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$VehicleAwardCopyWithImpl<$Res, $Val extends VehicleAward>
    implements $VehicleAwardCopyWith<$Res> {
  _$VehicleAwardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VehicleAward
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? vehicleId = null,
    Object? awardName = null,
    Object? eventName = null,
    Object? eventDate = null,
    Object? category = freezed,
    Object? placement = freezed,
    Object? description = freezed,
    Object? awardImage = freezed,
    Object? createdBy = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      vehicleId: null == vehicleId
          ? _value.vehicleId
          : vehicleId // ignore: cast_nullable_to_non_nullable
              as String,
      awardName: null == awardName
          ? _value.awardName
          : awardName // ignore: cast_nullable_to_non_nullable
              as String,
      eventName: null == eventName
          ? _value.eventName
          : eventName // ignore: cast_nullable_to_non_nullable
              as String,
      eventDate: null == eventDate
          ? _value.eventDate
          : eventDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      placement: freezed == placement
          ? _value.placement
          : placement // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      awardImage: freezed == awardImage
          ? _value.awardImage
          : awardImage // ignore: cast_nullable_to_non_nullable
              as String?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VehicleAwardImplCopyWith<$Res>
    implements $VehicleAwardCopyWith<$Res> {
  factory _$$VehicleAwardImplCopyWith(
          _$VehicleAwardImpl value, $Res Function(_$VehicleAwardImpl) then) =
      __$$VehicleAwardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String vehicleId,
      String awardName,
      String eventName,
      DateTime eventDate,
      String? category,
      String? placement,
      String? description,
      String? awardImage,
      String? createdBy,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$VehicleAwardImplCopyWithImpl<$Res>
    extends _$VehicleAwardCopyWithImpl<$Res, _$VehicleAwardImpl>
    implements _$$VehicleAwardImplCopyWith<$Res> {
  __$$VehicleAwardImplCopyWithImpl(
      _$VehicleAwardImpl _value, $Res Function(_$VehicleAwardImpl) _then)
      : super(_value, _then);

  /// Create a copy of VehicleAward
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? vehicleId = null,
    Object? awardName = null,
    Object? eventName = null,
    Object? eventDate = null,
    Object? category = freezed,
    Object? placement = freezed,
    Object? description = freezed,
    Object? awardImage = freezed,
    Object? createdBy = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$VehicleAwardImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      vehicleId: null == vehicleId
          ? _value.vehicleId
          : vehicleId // ignore: cast_nullable_to_non_nullable
              as String,
      awardName: null == awardName
          ? _value.awardName
          : awardName // ignore: cast_nullable_to_non_nullable
              as String,
      eventName: null == eventName
          ? _value.eventName
          : eventName // ignore: cast_nullable_to_non_nullable
              as String,
      eventDate: null == eventDate
          ? _value.eventDate
          : eventDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      placement: freezed == placement
          ? _value.placement
          : placement // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      awardImage: freezed == awardImage
          ? _value.awardImage
          : awardImage // ignore: cast_nullable_to_non_nullable
              as String?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VehicleAwardImpl implements _VehicleAward {
  const _$VehicleAwardImpl(
      {this.id,
      required this.vehicleId,
      required this.awardName,
      required this.eventName,
      required this.eventDate,
      this.category,
      this.placement,
      this.description,
      this.awardImage,
      this.createdBy,
      this.createdAt,
      this.updatedAt});

  factory _$VehicleAwardImpl.fromJson(Map<String, dynamic> json) =>
      _$$VehicleAwardImplFromJson(json);

  @override
  final String? id;
// PocketBase record ID
  @override
  final String vehicleId;
// Relation to vehicles collection
  @override
  final String awardName;
// e.g., "Best Modified Car"
  @override
  final String eventName;
// e.g., "Manila Auto Show 2025"
  @override
  final DateTime eventDate;
// Date of the event
  @override
  final String? category;
// e.g., "Modified", "Classic", "Best in Show"
  @override
  final String? placement;
// e.g., "1st Place", "Winner", "Champion"
  @override
  final String? description;
// Optional additional details
  @override
  final String? awardImage;
// File name for award photo/certificate
  @override
  final String? createdBy;
// User who created the award entry
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'VehicleAward(id: $id, vehicleId: $vehicleId, awardName: $awardName, eventName: $eventName, eventDate: $eventDate, category: $category, placement: $placement, description: $description, awardImage: $awardImage, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VehicleAwardImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.vehicleId, vehicleId) ||
                other.vehicleId == vehicleId) &&
            (identical(other.awardName, awardName) ||
                other.awardName == awardName) &&
            (identical(other.eventName, eventName) ||
                other.eventName == eventName) &&
            (identical(other.eventDate, eventDate) ||
                other.eventDate == eventDate) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.placement, placement) ||
                other.placement == placement) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.awardImage, awardImage) ||
                other.awardImage == awardImage) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      vehicleId,
      awardName,
      eventName,
      eventDate,
      category,
      placement,
      description,
      awardImage,
      createdBy,
      createdAt,
      updatedAt);

  /// Create a copy of VehicleAward
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VehicleAwardImplCopyWith<_$VehicleAwardImpl> get copyWith =>
      __$$VehicleAwardImplCopyWithImpl<_$VehicleAwardImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VehicleAwardImplToJson(
      this,
    );
  }
}

abstract class _VehicleAward implements VehicleAward {
  const factory _VehicleAward(
      {final String? id,
      required final String vehicleId,
      required final String awardName,
      required final String eventName,
      required final DateTime eventDate,
      final String? category,
      final String? placement,
      final String? description,
      final String? awardImage,
      final String? createdBy,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$VehicleAwardImpl;

  factory _VehicleAward.fromJson(Map<String, dynamic> json) =
      _$VehicleAwardImpl.fromJson;

  @override
  String? get id; // PocketBase record ID
  @override
  String get vehicleId; // Relation to vehicles collection
  @override
  String get awardName; // e.g., "Best Modified Car"
  @override
  String get eventName; // e.g., "Manila Auto Show 2025"
  @override
  DateTime get eventDate; // Date of the event
  @override
  String? get category; // e.g., "Modified", "Classic", "Best in Show"
  @override
  String? get placement; // e.g., "1st Place", "Winner", "Champion"
  @override
  String? get description; // Optional additional details
  @override
  String? get awardImage; // File name for award photo/certificate
  @override
  String? get createdBy; // User who created the award entry
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of VehicleAward
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VehicleAwardImplCopyWith<_$VehicleAwardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
