part of 'auth_bloc.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
}

class AuthState extends Equatable {
  const AuthState({
    required this.authStatus,
    this.user,
  });

  factory AuthState.unknown() {
    return const AuthState(authStatus: AuthStatus.unknown);
  }
  final AuthStatus authStatus;
  final RecordModel? user;

  @override
  List<Object?> get props => [authStatus, user];

  @override
  String toString() =>
      'AuthState(authStatus: $authStatus, user: ${user != null ? 'User(id: ${user!.id}, email: ${user!.data['email']})' : 'null'})';

  AuthState copyWith({
    AuthStatus? authStatus,
    RecordModel? user,
  }) {
    return AuthState(
      authStatus: authStatus ?? this.authStatus,
      user: user ?? this.user,
    );
  }
}
