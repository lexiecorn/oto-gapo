// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vehicle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Vehicle _$VehicleFromJson(Map<String, dynamic> json) {
  return _Vehicle.fromJson(json);
}

/// @nodoc
mixin _$Vehicle {
  String? get id => throw _privateConstructorUsedError; // PocketBase record ID
  String get make => throw _privateConstructorUsedError;
  String get model => throw _privateConstructorUsedError;
  String get year =>
      throw _privateConstructorUsedError; // Changed from int to String to match schema
  String get type => throw _privateConstructorUsedError;
  String get color => throw _privateConstructorUsedError;
  String get plateNumber => throw _privateConstructorUsedError;
  String? get primaryPhoto => throw _privateConstructorUsedError;
  List<String>? get photos => throw _privateConstructorUsedError;
  String? get user =>
      throw _privateConstructorUsedError; // User relation field - references user ID
// New vehicle specification fields
  num? get mileage =>
      throw _privateConstructorUsedError; // Vehicle mileage in km
  String? get fuelType =>
      throw _privateConstructorUsedError; // "Petrol", "Diesel", "Electric", "Hybrid"
  String? get wheelSize =>
      throw _privateConstructorUsedError; // e.g., "18-inch Alloy"
  num? get maxSpeed =>
      throw _privateConstructorUsedError; // Maximum speed in km/h
  String? get engineDisplacement =>
      throw _privateConstructorUsedError; // e.g., "2.0L", "3.5L V6"
  num? get horsepower =>
      throw _privateConstructorUsedError; // Engine power in HP
  String? get transmission => throw _privateConstructorUsedError;

  /// Serializes this Vehicle to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Vehicle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VehicleCopyWith<Vehicle> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VehicleCopyWith<$Res> {
  factory $VehicleCopyWith(Vehicle value, $Res Function(Vehicle) then) =
      _$VehicleCopyWithImpl<$Res, Vehicle>;
  @useResult
  $Res call(
      {String? id,
      String make,
      String model,
      String year,
      String type,
      String color,
      String plateNumber,
      String? primaryPhoto,
      List<String>? photos,
      String? user,
      num? mileage,
      String? fuelType,
      String? wheelSize,
      num? maxSpeed,
      String? engineDisplacement,
      num? horsepower,
      String? transmission});
}

/// @nodoc
class _$VehicleCopyWithImpl<$Res, $Val extends Vehicle>
    implements $VehicleCopyWith<$Res> {
  _$VehicleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Vehicle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? make = null,
    Object? model = null,
    Object? year = null,
    Object? type = null,
    Object? color = null,
    Object? plateNumber = null,
    Object? primaryPhoto = freezed,
    Object? photos = freezed,
    Object? user = freezed,
    Object? mileage = freezed,
    Object? fuelType = freezed,
    Object? wheelSize = freezed,
    Object? maxSpeed = freezed,
    Object? engineDisplacement = freezed,
    Object? horsepower = freezed,
    Object? transmission = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      make: null == make
          ? _value.make
          : make // ignore: cast_nullable_to_non_nullable
              as String,
      model: null == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String,
      plateNumber: null == plateNumber
          ? _value.plateNumber
          : plateNumber // ignore: cast_nullable_to_non_nullable
              as String,
      primaryPhoto: freezed == primaryPhoto
          ? _value.primaryPhoto
          : primaryPhoto // ignore: cast_nullable_to_non_nullable
              as String?,
      photos: freezed == photos
          ? _value.photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String?,
      mileage: freezed == mileage
          ? _value.mileage
          : mileage // ignore: cast_nullable_to_non_nullable
              as num?,
      fuelType: freezed == fuelType
          ? _value.fuelType
          : fuelType // ignore: cast_nullable_to_non_nullable
              as String?,
      wheelSize: freezed == wheelSize
          ? _value.wheelSize
          : wheelSize // ignore: cast_nullable_to_non_nullable
              as String?,
      maxSpeed: freezed == maxSpeed
          ? _value.maxSpeed
          : maxSpeed // ignore: cast_nullable_to_non_nullable
              as num?,
      engineDisplacement: freezed == engineDisplacement
          ? _value.engineDisplacement
          : engineDisplacement // ignore: cast_nullable_to_non_nullable
              as String?,
      horsepower: freezed == horsepower
          ? _value.horsepower
          : horsepower // ignore: cast_nullable_to_non_nullable
              as num?,
      transmission: freezed == transmission
          ? _value.transmission
          : transmission // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VehicleImplCopyWith<$Res> implements $VehicleCopyWith<$Res> {
  factory _$$VehicleImplCopyWith(
          _$VehicleImpl value, $Res Function(_$VehicleImpl) then) =
      __$$VehicleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String make,
      String model,
      String year,
      String type,
      String color,
      String plateNumber,
      String? primaryPhoto,
      List<String>? photos,
      String? user,
      num? mileage,
      String? fuelType,
      String? wheelSize,
      num? maxSpeed,
      String? engineDisplacement,
      num? horsepower,
      String? transmission});
}

/// @nodoc
class __$$VehicleImplCopyWithImpl<$Res>
    extends _$VehicleCopyWithImpl<$Res, _$VehicleImpl>
    implements _$$VehicleImplCopyWith<$Res> {
  __$$VehicleImplCopyWithImpl(
      _$VehicleImpl _value, $Res Function(_$VehicleImpl) _then)
      : super(_value, _then);

  /// Create a copy of Vehicle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? make = null,
    Object? model = null,
    Object? year = null,
    Object? type = null,
    Object? color = null,
    Object? plateNumber = null,
    Object? primaryPhoto = freezed,
    Object? photos = freezed,
    Object? user = freezed,
    Object? mileage = freezed,
    Object? fuelType = freezed,
    Object? wheelSize = freezed,
    Object? maxSpeed = freezed,
    Object? engineDisplacement = freezed,
    Object? horsepower = freezed,
    Object? transmission = freezed,
  }) {
    return _then(_$VehicleImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      make: null == make
          ? _value.make
          : make // ignore: cast_nullable_to_non_nullable
              as String,
      model: null == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String,
      plateNumber: null == plateNumber
          ? _value.plateNumber
          : plateNumber // ignore: cast_nullable_to_non_nullable
              as String,
      primaryPhoto: freezed == primaryPhoto
          ? _value.primaryPhoto
          : primaryPhoto // ignore: cast_nullable_to_non_nullable
              as String?,
      photos: freezed == photos
          ? _value._photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String?,
      mileage: freezed == mileage
          ? _value.mileage
          : mileage // ignore: cast_nullable_to_non_nullable
              as num?,
      fuelType: freezed == fuelType
          ? _value.fuelType
          : fuelType // ignore: cast_nullable_to_non_nullable
              as String?,
      wheelSize: freezed == wheelSize
          ? _value.wheelSize
          : wheelSize // ignore: cast_nullable_to_non_nullable
              as String?,
      maxSpeed: freezed == maxSpeed
          ? _value.maxSpeed
          : maxSpeed // ignore: cast_nullable_to_non_nullable
              as num?,
      engineDisplacement: freezed == engineDisplacement
          ? _value.engineDisplacement
          : engineDisplacement // ignore: cast_nullable_to_non_nullable
              as String?,
      horsepower: freezed == horsepower
          ? _value.horsepower
          : horsepower // ignore: cast_nullable_to_non_nullable
              as num?,
      transmission: freezed == transmission
          ? _value.transmission
          : transmission // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VehicleImpl implements _Vehicle {
  const _$VehicleImpl(
      {this.id,
      required this.make,
      required this.model,
      required this.year,
      required this.type,
      required this.color,
      required this.plateNumber,
      this.primaryPhoto,
      final List<String>? photos,
      this.user,
      this.mileage,
      this.fuelType,
      this.wheelSize,
      this.maxSpeed,
      this.engineDisplacement,
      this.horsepower,
      this.transmission})
      : _photos = photos;

  factory _$VehicleImpl.fromJson(Map<String, dynamic> json) =>
      _$$VehicleImplFromJson(json);

  @override
  final String? id;
// PocketBase record ID
  @override
  final String make;
  @override
  final String model;
  @override
  final String year;
// Changed from int to String to match schema
  @override
  final String type;
  @override
  final String color;
  @override
  final String plateNumber;
  @override
  final String? primaryPhoto;
  final List<String>? _photos;
  @override
  List<String>? get photos {
    final value = _photos;
    if (value == null) return null;
    if (_photos is EqualUnmodifiableListView) return _photos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? user;
// User relation field - references user ID
// New vehicle specification fields
  @override
  final num? mileage;
// Vehicle mileage in km
  @override
  final String? fuelType;
// "Petrol", "Diesel", "Electric", "Hybrid"
  @override
  final String? wheelSize;
// e.g., "18-inch Alloy"
  @override
  final num? maxSpeed;
// Maximum speed in km/h
  @override
  final String? engineDisplacement;
// e.g., "2.0L", "3.5L V6"
  @override
  final num? horsepower;
// Engine power in HP
  @override
  final String? transmission;

  @override
  String toString() {
    return 'Vehicle(id: $id, make: $make, model: $model, year: $year, type: $type, color: $color, plateNumber: $plateNumber, primaryPhoto: $primaryPhoto, photos: $photos, user: $user, mileage: $mileage, fuelType: $fuelType, wheelSize: $wheelSize, maxSpeed: $maxSpeed, engineDisplacement: $engineDisplacement, horsepower: $horsepower, transmission: $transmission)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VehicleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.make, make) || other.make == make) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.plateNumber, plateNumber) ||
                other.plateNumber == plateNumber) &&
            (identical(other.primaryPhoto, primaryPhoto) ||
                other.primaryPhoto == primaryPhoto) &&
            const DeepCollectionEquality().equals(other._photos, _photos) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.mileage, mileage) || other.mileage == mileage) &&
            (identical(other.fuelType, fuelType) ||
                other.fuelType == fuelType) &&
            (identical(other.wheelSize, wheelSize) ||
                other.wheelSize == wheelSize) &&
            (identical(other.maxSpeed, maxSpeed) ||
                other.maxSpeed == maxSpeed) &&
            (identical(other.engineDisplacement, engineDisplacement) ||
                other.engineDisplacement == engineDisplacement) &&
            (identical(other.horsepower, horsepower) ||
                other.horsepower == horsepower) &&
            (identical(other.transmission, transmission) ||
                other.transmission == transmission));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      make,
      model,
      year,
      type,
      color,
      plateNumber,
      primaryPhoto,
      const DeepCollectionEquality().hash(_photos),
      user,
      mileage,
      fuelType,
      wheelSize,
      maxSpeed,
      engineDisplacement,
      horsepower,
      transmission);

  /// Create a copy of Vehicle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VehicleImplCopyWith<_$VehicleImpl> get copyWith =>
      __$$VehicleImplCopyWithImpl<_$VehicleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VehicleImplToJson(
      this,
    );
  }
}

abstract class _Vehicle implements Vehicle {
  const factory _Vehicle(
      {final String? id,
      required final String make,
      required final String model,
      required final String year,
      required final String type,
      required final String color,
      required final String plateNumber,
      final String? primaryPhoto,
      final List<String>? photos,
      final String? user,
      final num? mileage,
      final String? fuelType,
      final String? wheelSize,
      final num? maxSpeed,
      final String? engineDisplacement,
      final num? horsepower,
      final String? transmission}) = _$VehicleImpl;

  factory _Vehicle.fromJson(Map<String, dynamic> json) = _$VehicleImpl.fromJson;

  @override
  String? get id; // PocketBase record ID
  @override
  String get make;
  @override
  String get model;
  @override
  String get year; // Changed from int to String to match schema
  @override
  String get type;
  @override
  String get color;
  @override
  String get plateNumber;
  @override
  String? get primaryPhoto;
  @override
  List<String>? get photos;
  @override
  String? get user; // User relation field - references user ID
// New vehicle specification fields
  @override
  num? get mileage; // Vehicle mileage in km
  @override
  String? get fuelType; // "Petrol", "Diesel", "Electric", "Hybrid"
  @override
  String? get wheelSize; // e.g., "18-inch Alloy"
  @override
  num? get maxSpeed; // Maximum speed in km/h
  @override
  String? get engineDisplacement; // e.g., "2.0L", "3.5L V6"
  @override
  num? get horsepower; // Engine power in HP
  @override
  String? get transmission;

  /// Create a copy of Vehicle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VehicleImplCopyWith<_$VehicleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
