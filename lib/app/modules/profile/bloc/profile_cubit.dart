import 'package:authentication_repository/authentication_repository.dart'
    as my_auth_repo;
import 'package:authentication_repository/authentication_repository.dart';
import 'package:authentication_repository/src/profile_failure.dart';
import 'package:otogapo/utils/debug_helper.dart';
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
    DebugHelper.log('ProfileCubit.getProfile - Starting profile retrieval');
    emit(state.copyWith(profileStatus: ProfileStatus.loading));

    try {
      DebugHelper.log('ProfileCubit.getProfile - Calling profileRepository.getProfile');
      final user = await profileRepository.getProfile();
      DebugHelper.log('ProfileCubit.getProfile - User loaded successfully');
      DebugHelper.log('ProfileCubit.getProfile - User memberNumber: ${user.memberNumber}');
      DebugHelper.log('ProfileCubit.getProfile - User membership_type: ${user.membership_type}');

      // Fetch vehicles for this user
      DebugHelper.log('ProfileCubit.getProfile - Fetching vehicles for user: ${user.uid}');
      final vehicles = await profileRepository.getUserVehicles(user.uid);
      DebugHelper.log('ProfileCubit.getProfile - Found ${vehicles.length} vehicles');

      // Fetch awards for this user's vehicles
      DebugHelper.log('ProfileCubit.getProfile - Fetching awards for user: ${user.uid}');
      final awards = await profileRepository.getUserVehicleAwards(user.uid);
      DebugHelper.log('ProfileCubit.getProfile - Found ${awards.length} awards');

      emit(
        state.copyWith(
          profileStatus: ProfileStatus.loaded,
          user: user,
          vehicles: vehicles,
          awards: awards,
        ),
      );
      DebugHelper.log('ProfileCubit.getProfile - State updated to loaded');
    } on ProfileFailure catch (e) {
      DebugHelper.logError('ProfileCubit.getProfile - ProfileFailure: ${e.message}');
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
      DebugHelper.log('ProfileCubit.getProfile - State updated to error');
    } on CustomError catch (e) {
      DebugHelper.logError('ProfileCubit.getProfile - CustomError: ${e.message}');
      emit(
        state.copyWith(
          profileStatus: ProfileStatus.error,
          error: e,
        ),
      );
      DebugHelper.log('ProfileCubit.getProfile - State updated to error');
    }
  }

  void resetProfile() {
    DebugHelper.log('ProfileCubit.resetProfile - Resetting profile state');
    DebugHelper.log('ProfileCubit.resetProfile - Current state before reset: $state');
    emit(ProfileState.initial());
    DebugHelper.log('ProfileCubit.resetProfile - State reset to initial');
  }

  void forceClear() {
    DebugHelper.log('ProfileCubit.forceClear - Force clearing profile state');
    DebugHelper.log('ProfileCubit.forceClear - Current state before clear: $state');
    emit(ProfileState.initial());
    DebugHelper.log('ProfileCubit.forceClear - State cleared');
  }

  Future<void> getProfileByUserId(String userId) async {
    DebugHelper.log('ProfileCubit.getProfileByUserId - Starting profile retrieval for userId: $userId');
    emit(state.copyWith(profileStatus: ProfileStatus.loading));

    try {
      DebugHelper.log('ProfileCubit.getProfileByUserId - Calling profileRepository.getProfileByUserId');
      final user = await profileRepository.getProfileByUserId(userId);
      DebugHelper.log('ProfileCubit.getProfileByUserId - User loaded successfully');

      // Fetch vehicles for this user
      DebugHelper.log('ProfileCubit.getProfileByUserId - Fetching vehicles for user: ${user.uid}');
      final vehicles = await profileRepository.getUserVehicles(user.uid);
      DebugHelper.log('ProfileCubit.getProfileByUserId - Found ${vehicles.length} vehicles');

      // Fetch awards for this user's vehicles
      DebugHelper.log('ProfileCubit.getProfileByUserId - Fetching awards for user: ${user.uid}');
      final awards = await profileRepository.getUserVehicleAwards(user.uid);
      DebugHelper.log('ProfileCubit.getProfileByUserId - Found ${awards.length} awards');

      emit(
        state.copyWith(
          profileStatus: ProfileStatus.loaded,
          user: user,
          vehicles: vehicles,
          awards: awards,
        ),
      );
      DebugHelper.log('ProfileCubit.getProfileByUserId - State updated to loaded');
    } on ProfileFailure catch (e) {
      DebugHelper.logError('ProfileCubit.getProfileByUserId - ProfileFailure: ${e.message}');
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
      DebugHelper.log('ProfileCubit.getProfileByUserId - State updated to error');
    } on CustomError catch (e) {
      DebugHelper.logError('ProfileCubit.getProfileByUserId - CustomError: ${e.message}');
      emit(
        state.copyWith(
          profileStatus: ProfileStatus.error,
          error: e,
        ),
      );
      DebugHelper.log('ProfileCubit.getProfileByUserId - State updated to error');
    }
  }
}
