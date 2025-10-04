import 'package:authentication_repository/authentication_repository.dart' as my_auth_repo;
import 'package:authentication_repository/authentication_repository.dart';
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
      print('ProfileCubit.getProfile - User memberNumber: ${user.memberNumber}');
      print('ProfileCubit.getProfile - User membership_type: ${user.membership_type}');

      // Fetch vehicles for this user
      print('ProfileCubit.getProfile - Fetching vehicles for user: ${user.uid}');
      final vehicles = await profileRepository.getUserVehicles(user.uid);
      print('ProfileCubit.getProfile - Found ${vehicles.length} vehicles');

      emit(
        state.copyWith(
          profileStatus: ProfileStatus.loaded,
          user: user,
          vehicles: vehicles,
        ),
      );
      print('ProfileCubit.getProfile - State updated to loaded');
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
    print('ProfileCubit.resetProfile - Current state before reset: ${state}');
    emit(ProfileState.initial());
    print('ProfileCubit.resetProfile - State reset to initial');
  }

  void forceClear() {
    print('ProfileCubit.forceClear - Force clearing profile state');
    print('ProfileCubit.forceClear - Current state before clear: ${state}');
    emit(ProfileState.initial());
    print('ProfileCubit.forceClear - State cleared');
  }
}
