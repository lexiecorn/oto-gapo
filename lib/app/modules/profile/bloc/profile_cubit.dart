import 'package:authentication_repository/authentication_repository.dart'
    as my_auth_repo;
import 'package:authentication_repository/authentication_repository.dart';
import 'package:authentication_repository/src/profile_failure.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:otogapo/models/custom_error.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required this.profileRepository,
  }) : super(ProfileState.initial());
  final ProfileRepository profileRepository;

  Future<void> getProfile() async {
    print('ProfileCubit.getProfile - Starting profile retrieval');
    emit(state.copyWith(profileStatus: ProfileStatus.loading));

    try {
      print('ProfileCubit.getProfile - Calling profileRepository.getProfile');
      final user = await profileRepository.getProfile();
      print('ProfileCubit.getProfile - User loaded successfully');
      print(
          'ProfileCubit.getProfile - User memberNumber: ${user.memberNumber}',);
      print(
          'ProfileCubit.getProfile - User membership_type: ${user.membership_type}',);

      // Fetch vehicles for this user
      print(
          'ProfileCubit.getProfile - Fetching vehicles for user: ${user.uid}',);
      final vehicles = await profileRepository.getUserVehicles(user.uid);
      print('ProfileCubit.getProfile - Found ${vehicles.length} vehicles');

      // Fetch awards for this user's vehicles
      print('ProfileCubit.getProfile - Fetching awards for user: ${user.uid}');
      final awards = await profileRepository.getUserVehicleAwards(user.uid);
      print('ProfileCubit.getProfile - Found ${awards.length} awards');

      emit(
        state.copyWith(
          profileStatus: ProfileStatus.loaded,
          user: user,
          vehicles: vehicles,
          awards: awards,
        ),
      );
      print('ProfileCubit.getProfile - State updated to loaded');
    } on ProfileFailure catch (e) {
      print('ProfileCubit.getProfile - ProfileFailure: ${e.message}');
      emit(
        state.copyWith(
          profileStatus: ProfileStatus.error,
          error: CustomError(
            code: e.code,
            message: e.message,
            plugin: e.plugin,
          ),
        ),
      );
      print('ProfileCubit.getProfile - State updated to error');
    } on CustomError catch (e) {
      print('ProfileCubit.getProfile - CustomError: ${e.message}');
      emit(
        state.copyWith(
          profileStatus: ProfileStatus.error,
          error: e,
        ),
      );
      print('ProfileCubit.getProfile - State updated to error');
    }
  }

  void resetProfile() {
    print('ProfileCubit.resetProfile - Resetting profile state');
    print('ProfileCubit.resetProfile - Current state before reset: $state');
    emit(ProfileState.initial());
    print('ProfileCubit.resetProfile - State reset to initial');
  }

  void forceClear() {
    print('ProfileCubit.forceClear - Force clearing profile state');
    print('ProfileCubit.forceClear - Current state before clear: $state');
    emit(ProfileState.initial());
    print('ProfileCubit.forceClear - State cleared');
  }

  Future<void> getProfileByUserId(String userId) async {
    print(
        'ProfileCubit.getProfileByUserId - Starting profile retrieval for userId: $userId',);
    emit(state.copyWith(profileStatus: ProfileStatus.loading));

    try {
      print(
          'ProfileCubit.getProfileByUserId - Calling profileRepository.getProfileByUserId',);
      final user = await profileRepository.getProfileByUserId(userId);
      print('ProfileCubit.getProfileByUserId - User loaded successfully');

      // Fetch vehicles for this user
      print(
          'ProfileCubit.getProfileByUserId - Fetching vehicles for user: ${user.uid}',);
      final vehicles = await profileRepository.getUserVehicles(user.uid);
      print(
          'ProfileCubit.getProfileByUserId - Found ${vehicles.length} vehicles',);

      // Fetch awards for this user's vehicles
      print(
          'ProfileCubit.getProfileByUserId - Fetching awards for user: ${user.uid}',);
      final awards = await profileRepository.getUserVehicleAwards(user.uid);
      print('ProfileCubit.getProfileByUserId - Found ${awards.length} awards');

      emit(
        state.copyWith(
          profileStatus: ProfileStatus.loaded,
          user: user,
          vehicles: vehicles,
          awards: awards,
        ),
      );
      print('ProfileCubit.getProfileByUserId - State updated to loaded');
    } on ProfileFailure catch (e) {
      print('ProfileCubit.getProfileByUserId - ProfileFailure: ${e.message}');
      emit(
        state.copyWith(
          profileStatus: ProfileStatus.error,
          error: CustomError(
            code: e.code,
            message: e.message,
            plugin: e.plugin,
          ),
        ),
      );
      print('ProfileCubit.getProfileByUserId - State updated to error');
    } on CustomError catch (e) {
      print('ProfileCubit.getProfileByUserId - CustomError: ${e.message}');
      emit(
        state.copyWith(
          profileStatus: ProfileStatus.error,
          error: e,
        ),
      );
      print('ProfileCubit.getProfileByUserId - State updated to error');
    }
  }
}
