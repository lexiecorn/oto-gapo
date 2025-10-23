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
    required this.vehicles,
    required this.awards,
  });

  factory ProfileState.initial() {
    return ProfileState(
      profileStatus: ProfileStatus.initial,
      user: my_auth_repo.User.empty(),
      error: CustomError.initial(),
      vehicles: const [],
      awards: const [],
    );
  }
  final ProfileStatus profileStatus;
  final my_auth_repo.User user;
  final CustomError error;
  final List<my_auth_repo.Vehicle> vehicles;
  final List<my_auth_repo.VehicleAward> awards;

  @override
  List<Object> get props => [profileStatus, user, error, vehicles, awards];

  @override
  String toString() =>
      'ProfileState(profileStatus: $profileStatus, user: $user, error: $error, vehicles: $vehicles, awards: $awards)';

  ProfileState copyWith({
    ProfileStatus? profileStatus,
    my_auth_repo.User? user,
    CustomError? error,
    List<my_auth_repo.Vehicle>? vehicles,
    List<my_auth_repo.VehicleAward>? awards,
  }) {
    return ProfileState(
      profileStatus: profileStatus ?? this.profileStatus,
      user: user ?? this.user,
      error: error ?? this.error,
      vehicles: vehicles ?? this.vehicles,
      awards: awards ?? this.awards,
    );
  }
}
