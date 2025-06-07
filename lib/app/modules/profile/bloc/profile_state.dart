part of 'profile_cubit.dart';

enum ProfileStatus {
  initial,
  loading,
  loaded,
  error,
}

class ProfileState extends Equatable {
  const ProfileState({
    required this.profileStatus,
    required this.user,
    required this.error,
  });

  factory ProfileState.initial() {
    return ProfileState(
      profileStatus: ProfileStatus.initial,
      user: my_auth_repo.User.empty(),
      error: CustomError.initial(),
    );
  }
  final ProfileStatus profileStatus;
  final my_auth_repo.User user;
  final CustomError error;

  @override
  List<Object> get props => [profileStatus, user, error];

  @override
  String toString() => 'ProfileState(profileStatus: $profileStatus, user: $user, error: $error)';

  ProfileState copyWith({
    ProfileStatus? profileStatus,
    my_auth_repo.User? user,
    CustomError? error,
  }) {
    return ProfileState(
      profileStatus: profileStatus ?? this.profileStatus,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}
