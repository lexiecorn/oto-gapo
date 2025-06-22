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

  Future<void> getProfile({required String uid}) async {
    print('ProfileCubit.getProfile - Starting with UID: $uid');
    emit(state.copyWith(profileStatus: ProfileStatus.loading));

    try {
      // await profileRepository.duplicateDocument('6xxdHcIhaPxhv5r094Br', 'TS4E73z29qdpfsyBiBsxnBN10I43');
      print('ProfileCubit.getProfile - Calling profileRepository.getProfile');
      final user = await profileRepository.getProfile(uid: uid);
      print('ProfileCubit.getProfile - User loaded successfully');
      print('ProfileCubit.getProfile - User memberNumber: ${user.memberNumber}');
      print('ProfileCubit.getProfile - User membership_type: ${user.membership_type}');

      emit(
        state.copyWith(
          profileStatus: ProfileStatus.loaded,
          user: user,
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
