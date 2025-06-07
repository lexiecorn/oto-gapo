import 'dart:developer';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'signin_cubit.freezed.dart';
part 'signin_state.dart';

class SigninCubit extends Cubit<SigninState> {
  SigninCubit({required this.authRepository}) : super(const SigninState());
  final AuthRepository authRepository;

  Future<void> signinWithGoogle({required String idToken, String? displayName}) async {
    emit(state.copyWith(signinStatus: SigninStatus.submitting));
    try {
      await authRepository.signInWithGoogle(idToken: idToken, displayName: displayName); // Call your repository method
      emit(state.copyWith(signinStatus: SigninStatus.success));
    } on FirebaseAuthApiFailure catch (e) {
      emit(state.copyWith(signinStatus: SigninStatus.error, error: e));
    }
  }

  Future<void> signin({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(signinStatus: SigninStatus.submitting));

    try {
      await authRepository.signin(email: email, password: password);

      emit(state.copyWith(signinStatus: SigninStatus.success));
    } on FirebaseAuthApiFailure catch (e) {
      log('signin cubit- ${3}');
      emit(
        state.copyWith(
          signinStatus: SigninStatus.error,
          error: e,
        ),
      );
    } on AuthFailure catch (e) {
      emit(
        state.copyWith(
          signinStatus: SigninStatus.error,
          error: FirebaseAuthApiFailure(e.message.toString(), e.code, ''),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          signinStatus: SigninStatus.error,
          error: const FirebaseAuthApiFailure(
            'Unknown Authentication error',
            'Authentication error',
            '',
          ),
        ),
      );
    }
  }
}
