// ignore_for_file: public_member_api_docs

import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:otogapo/app/modules/profile/bloc/profile_cubit.dart';
import 'package:otogapo/models/custom_error.dart';

/// Mock classes for testing
class MockProfileCubit extends MockCubit<ProfileState>
    implements ProfileCubit {}

class MockProfileRepository extends Mock implements ProfileRepository {}

/// Factory for creating test Vehicle instances.
///
/// Provides sensible defaults that can be overridden.
Vehicle createMockVehicle({
  String make = 'Toyota',
  String model = 'Vios',
  num year = 2020,
  String type = 'Sedan',
  String color = 'Silver',
  String plateNumber = 'ABC-1234',
  String? primaryPhoto,
  List<String>? photos,
  String? user,
}) {
  return Vehicle(
    make: make,
    model: model,
    year: year,
    type: type,
    color: color,
    plateNumber: plateNumber,
    primaryPhoto: primaryPhoto,
    photos: photos,
    user: user,
  );
}

/// Factory for creating test ProfileState instances.
///
/// Provides sensible defaults that can be overridden.
ProfileState createMockProfileState({
  ProfileStatus status = ProfileStatus.loaded,
  User? user,
  List<Vehicle>? vehicles,
  List<VehicleAward>? awards,
  CustomError? error,
}) {
  return ProfileState(
    profileStatus: status,
    user: user ?? User.empty(),
    vehicles: vehicles ?? [],
    awards: awards ?? [],
    error: error ?? CustomError.initial(),
  );
}

/// Creates a ProfileState with a single vehicle containing test data.
ProfileState createProfileStateWithVehicle({
  String make = 'Toyota',
  String model = 'Vios',
  String plateNumber = 'ABC-1234',
  String color = 'Silver',
  num year = 2020,
  String? primaryPhoto,
  List<String>? photos,
}) {
  final vehicle = createMockVehicle(
    make: make,
    model: model,
    plateNumber: plateNumber,
    color: color,
    year: year,
    primaryPhoto: primaryPhoto,
    photos: photos,
  );

  return createMockProfileState(
    vehicles: [vehicle],
  );
}

/// Creates a ProfileState with multiple vehicles.
ProfileState createProfileStateWithMultipleVehicles({
  int vehicleCount = 3,
}) {
  final vehicles = List.generate(
    vehicleCount,
    (index) => createMockVehicle(
      make: 'Make $index',
      model: 'Model $index',
      plateNumber: 'ABC-${1000 + index}',
      color: index.isEven ? 'Red' : 'Blue',
      year: 2020 + index,
    ),
  );

  return createMockProfileState(
    vehicles: vehicles,
  );
}

/// Creates an empty ProfileState (no vehicles).
ProfileState createEmptyProfileState() {
  return createMockProfileState(
    vehicles: [],
  );
}

/// Creates a loading ProfileState.
ProfileState createLoadingProfileState() {
  return createMockProfileState(
    status: ProfileStatus.loading,
    vehicles: [],
  );
}

/// Creates an error ProfileState.
ProfileState createErrorProfileState({
  String message = 'Test error',
}) {
  return createMockProfileState(
    status: ProfileStatus.error,
    error: CustomError(
      code: 'test_error',
      message: message,
      plugin: 'test',
    ),
  );
}

/// Creates a MockProfileCubit with a given initial state.
///
/// Use with `whenListen` from bloc_test to simulate state changes:
/// ```dart
/// final cubit = createMockProfileCubitWithState(mockState);
/// whenListen(
///   cubit,
///   Stream.fromIterable([mockState]),
///   initialState: mockState,
/// );
/// ```
MockProfileCubit createMockProfileCubitWithState(ProfileState state) {
  final cubit = MockProfileCubit();
  when(() => cubit.state).thenReturn(state);
  return cubit;
}
