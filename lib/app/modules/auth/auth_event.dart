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
  final fb_auth.User? user;

  @override
  List<Object?> get props => [user];
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
