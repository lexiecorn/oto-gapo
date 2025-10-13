part of 'signup_cubit.dart';

enum SignupStatus {
  initial,
  submitting,
  success,
  error,
}

@freezed
class SignupState with _$SignupState {
  const factory SignupState({
    @Default(SignupStatus.initial) SignupStatus signupStatus,
    CustomError? error,
  }) = _SignupState;

  factory SignupState.initial() {
    return SignupState(
      signupStatus: SignupStatus.initial,
      error: CustomError.initial(),
    );
  }
}
