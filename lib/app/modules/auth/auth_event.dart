// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStateChangedEvent extends AuthEvent {
  const AuthStateChangedEvent({
    this.user,
  });
  final RecordModel? user;

  @override
  List<Object?> get props => [user];
}

class SignInRequestedEvent extends AuthEvent {
  const SignInRequestedEvent({
    required this.email,
    required this.password,
  });
  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class SignUpRequestedEvent extends AuthEvent {
  const SignUpRequestedEvent({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.additionalData,
  });
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final Map<String, dynamic>? additionalData;

  @override
  List<Object?> get props => [email, password, firstName, lastName, additionalData];
}

class UpdatePhotoUrlEvent extends AuthEvent {
  const UpdatePhotoUrlEvent({
    required this.photoUrl,
  });
  final String photoUrl;
  @override
  List<Object?> get props => [photoUrl];
}

class SignoutRequestedEvent extends AuthEvent {}
