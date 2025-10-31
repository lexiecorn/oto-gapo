import 'package:authentication_repository/authentication_repository.dart';
import 'package:authentication_repository/src/profile_failure.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:otogapo/app/modules/profile/bloc/profile_cubit.dart';
import 'package:otogapo/models/custom_error.dart';

import '../../../helpers/mock_factories.dart';

void main() {
  group('ProfileCubit', () {
    late MockProfileRepository mockProfileRepository;
    late ProfileCubit profileCubit;

    setUp(() {
      mockProfileRepository = MockProfileRepository();
      profileCubit = ProfileCubit(profileRepository: mockProfileRepository);
    });

    tearDown(() {
      profileCubit.close();
    });

    test('initial state is correct', () {
      expect(profileCubit.state.profileStatus, ProfileStatus.initial);
      expect(profileCubit.state.user, isA<User>());
      expect(profileCubit.state.vehicles, isEmpty);
      expect(profileCubit.state.awards, isEmpty);
      expect(profileCubit.state.error, isA<CustomError>());
    });

    group('getProfile', () {
      blocTest<ProfileCubit, ProfileState>(
        'emits loading then loaded state with user, vehicles, and awards when successful',
        setUp: () {
          final mockUser = User.empty();
          final mockVehicles = [createMockVehicle()];
          final mockAwards = <VehicleAward>[];

          when(() => mockProfileRepository.getProfile())
              .thenAnswer((_) async => mockUser);
          when(() => mockProfileRepository.getUserVehicles(any()))
              .thenAnswer((_) async => mockVehicles);
          when(() => mockProfileRepository.getUserVehicleAwards(any()))
              .thenAnswer((_) async => mockAwards);
        },
        build: () => profileCubit,
        act: (cubit) => cubit.getProfile(),
        expect: () => [
          predicate<ProfileState>(
            (state) => state.profileStatus == ProfileStatus.loading,
          ),
          predicate<ProfileState>(
            (state) =>
                state.profileStatus == ProfileStatus.loaded &&
                state.vehicles.length == 1 &&
                state.awards.isEmpty,
          ),
        ],
        verify: (_) {
          verify(() => mockProfileRepository.getProfile()).called(1);
          verify(() => mockProfileRepository.getUserVehicles(any())).called(1);
          verify(() => mockProfileRepository.getUserVehicleAwards(any()))
              .called(1);
        },
      );

      blocTest<ProfileCubit, ProfileState>(
        'emits loading then error state when ProfileFailure occurs',
        setUp: () {
          when(() => mockProfileRepository.getProfile()).thenThrow(
            ProfileFailure(
              code: 'Not Authenticated',
              message: 'User is not authenticated',
              plugin: 'pocketbase_auth',
            ),
          );
        },
        build: () => profileCubit,
        act: (cubit) => cubit.getProfile(),
        expect: () => [
          predicate<ProfileState>(
            (state) => state.profileStatus == ProfileStatus.loading,
          ),
          predicate<ProfileState>(
            (state) =>
                state.profileStatus == ProfileStatus.error &&
                state.error.code == 'Not Authenticated',
          ),
        ],
      );

      blocTest<ProfileCubit, ProfileState>(
        'emits loading then error state when CustomError occurs',
        setUp: () {
          when(() => mockProfileRepository.getProfile()).thenThrow(
            CustomError(
              code: 'network_error',
              message: 'Network connection failed',
              plugin: 'http',
            ),
          );
        },
        build: () => profileCubit,
        act: (cubit) => cubit.getProfile(),
        expect: () => [
          predicate<ProfileState>(
            (state) => state.profileStatus == ProfileStatus.loading,
          ),
          predicate<ProfileState>(
            (state) =>
                state.profileStatus == ProfileStatus.error &&
                state.error.code == 'network_error',
          ),
        ],
      );

      blocTest<ProfileCubit, ProfileState>(
        'handles empty vehicles and awards lists',
        setUp: () {
          final mockUser = User.empty();
          when(() => mockProfileRepository.getProfile())
              .thenAnswer((_) async => mockUser);
          when(() => mockProfileRepository.getUserVehicles(any()))
              .thenAnswer((_) async => <Vehicle>[]);
          when(() => mockProfileRepository.getUserVehicleAwards(any()))
              .thenAnswer((_) async => <VehicleAward>[]);
        },
        build: () => profileCubit,
        act: (cubit) => cubit.getProfile(),
        expect: () => [
          predicate<ProfileState>(
            (state) => state.profileStatus == ProfileStatus.loading,
          ),
          predicate<ProfileState>(
            (state) =>
                state.profileStatus == ProfileStatus.loaded &&
                state.vehicles.isEmpty &&
                state.awards.isEmpty,
          ),
        ],
      );
    });

    group('getProfileByUserId', () {
      blocTest<ProfileCubit, ProfileState>(
        'emits loading then loaded state when successful',
        setUp: () {
          final mockUser = User.empty();
          final mockVehicles = [createMockVehicle()];
          final mockAwards = <VehicleAward>[];

          when(
            () => mockProfileRepository.getProfileByUserId(any<String>()),
          ).thenAnswer((_) async => mockUser);
          when(() => mockProfileRepository.getUserVehicles(any()))
              .thenAnswer((_) async => mockVehicles);
          when(() => mockProfileRepository.getUserVehicleAwards(any()))
              .thenAnswer((_) async => mockAwards);
        },
        build: () => profileCubit,
        act: (cubit) => cubit.getProfileByUserId('user123'),
        expect: () => [
          predicate<ProfileState>(
            (state) => state.profileStatus == ProfileStatus.loading,
          ),
          predicate<ProfileState>(
            (state) =>
                state.profileStatus == ProfileStatus.loaded &&
                state.vehicles.length == 1,
          ),
        ],
        verify: (_) {
          verify(
            () => mockProfileRepository.getProfileByUserId('user123'),
          ).called(1);
          verify(() => mockProfileRepository.getUserVehicles(any())).called(1);
          verify(() => mockProfileRepository.getUserVehicleAwards(any()))
              .called(1);
        },
      );

      blocTest<ProfileCubit, ProfileState>(
        'emits loading then error state when ProfileFailure occurs',
        setUp: () {
          when(
            () => mockProfileRepository.getProfileByUserId(any<String>()),
          ).thenThrow(
            ProfileFailure(
              code: 'User Not Found',
              message: 'User with ID not found',
              plugin: 'pocketbase_auth',
            ),
          );
        },
        build: () => profileCubit,
        act: (cubit) => cubit.getProfileByUserId('invalid_user_id'),
        expect: () => [
          predicate<ProfileState>(
            (state) => state.profileStatus == ProfileStatus.loading,
          ),
          predicate<ProfileState>(
            (state) =>
                state.profileStatus == ProfileStatus.error &&
                state.error.code == 'User Not Found',
          ),
        ],
      );
    });

    group('resetProfile', () {
      blocTest<ProfileCubit, ProfileState>(
        'resets state to initial',
        setUp: () {
          final mockUser = User.empty();
          final mockVehicles = [createMockVehicle()];

          when(() => mockProfileRepository.getProfile())
              .thenAnswer((_) async => mockUser);
          when(() => mockProfileRepository.getUserVehicles(any()))
              .thenAnswer((_) async => mockVehicles);
          when(() => mockProfileRepository.getUserVehicleAwards(any()))
              .thenAnswer((_) async => <VehicleAward>[]);
        },
        build: () => profileCubit,
        act: (cubit) async {
          await cubit.getProfile();
          cubit.resetProfile();
        },
        expect: () => [
          predicate<ProfileState>(
            (state) => state.profileStatus == ProfileStatus.loading,
          ),
          predicate<ProfileState>(
            (state) => state.profileStatus == ProfileStatus.loaded,
          ),
          predicate<ProfileState>(
            (state) => state.profileStatus == ProfileStatus.initial,
          ),
        ],
      );
    });

    group('forceClear', () {
      blocTest<ProfileCubit, ProfileState>(
        'clears state to initial',
        setUp: () {
          final mockUser = User.empty();
          final mockVehicles = [createMockVehicle()];

          when(() => mockProfileRepository.getProfile())
              .thenAnswer((_) async => mockUser);
          when(() => mockProfileRepository.getUserVehicles(any()))
              .thenAnswer((_) async => mockVehicles);
          when(() => mockProfileRepository.getUserVehicleAwards(any()))
              .thenAnswer((_) async => <VehicleAward>[]);
        },
        build: () => profileCubit,
        act: (cubit) async {
          await cubit.getProfile();
          cubit.forceClear();
        },
        expect: () => [
          predicate<ProfileState>(
            (state) => state.profileStatus == ProfileStatus.loading,
          ),
          predicate<ProfileState>(
            (state) => state.profileStatus == ProfileStatus.loaded,
          ),
          predicate<ProfileState>(
            (state) => state.profileStatus == ProfileStatus.initial,
          ),
        ],
      );
    });
  });
}

