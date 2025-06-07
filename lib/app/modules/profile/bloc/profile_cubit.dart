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
    emit(state.copyWith(profileStatus: ProfileStatus.loading));

    try {
      // await profileRepository.duplicateDocument('6xxdHcIhaPxhv5r094Br', 'TS4E73z29qdpfsyBiBsxnBN10I43');
      final user = await profileRepository.getProfile(uid: uid);
      emit(
        state.copyWith(
          profileStatus: ProfileStatus.loaded,
          user: user,
        ),
      );
    } on CustomError catch (e) {
      emit(
        state.copyWith(
          profileStatus: ProfileStatus.error,
          error: e,
        ),
      );
    }
  }
}
