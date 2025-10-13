import 'dart:developer';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:authentication_repository/src/pocketbase_auth_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'signin_cubit.freezed.dart';
part 'signin_state.dart';

class SigninCubit extends Cubit<SigninState> {
  SigninCubit({
    required this.authRepository,
    required this.pocketBaseAuth,
  }) : super(const SigninState());

  final AuthRepository authRepository;
  final PocketBaseAuthRepository pocketBaseAuth;

  /// Sign in with Google using PocketBase native OAuth
  Future<void> signinWithGoogleOAuth() async {
    emit(state.copyWith(signinStatus: SigninStatus.submitting));
    try {
      log('Starting PocketBase Google OAuth...');

      // Use PocketBase's native Google OAuth
      await pocketBaseAuth.signInWithGoogleOAuth();

      emit(state.copyWith(signinStatus: SigninStatus.success));
      log('PocketBase Google OAuth successful');
    } on AuthFailure catch (e) {
      log('signinWithGoogleOAuth cubit error: ${e.message}');
      emit(
        state.copyWith(
          signinStatus: SigninStatus.error,
          error: FirebaseAuthApiFailure(e.message.toString(), e.code, e.plugin),
        ),
      );
    } catch (e) {
      log('signinWithGoogleOAuth cubit unknown error: $e');
      emit(
        state.copyWith(
          signinStatus: SigninStatus.error,
          error: const FirebaseAuthApiFailure(
            'Google OAuth failed. Please try again.',
            'google_oauth_error',
            'pocketbase_oauth',
          ),
        ),
      );
    }
  }

  // Keep the old Firebase method as fallback if needed
  Future<void> signinWithGoogle({required String idToken, String? displayName}) async {
    emit(state.copyWith(signinStatus: SigninStatus.submitting));
    try {
      await authRepository.signInWithGoogle(idToken: idToken, displayName: displayName); // Call your repository method
      emit(state.copyWith(signinStatus: SigninStatus.success));
    } on AuthFailure catch (e) {
      log('signinWithGoogle cubit error: ${e.message}');
      emit(
        state.copyWith(
          signinStatus: SigninStatus.error,
          error: FirebaseAuthApiFailure(e.message.toString(), e.code, e.plugin),
        ),
      );
    } on FirebaseAuthApiFailure catch (e) {
      emit(state.copyWith(signinStatus: SigninStatus.error, error: e));
    } catch (e) {
      log('signinWithGoogle cubit unknown error: $e');
      emit(
        state.copyWith(
          signinStatus: SigninStatus.error,
          error: const FirebaseAuthApiFailure(
            'Unknown Authentication error',
            'Authentication error',
            'google_sign_in',
          ),
        ),
      );
    }
  }

  Future<void> signin({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(signinStatus: SigninStatus.submitting));

    try {
      // Use PocketBase authentication instead of Firebase
      await pocketBaseAuth.signIn(email: email, password: password);

      emit(state.copyWith(signinStatus: SigninStatus.success));
    } on AuthFailure catch (e) {
      log('signin cubit error: ${e.message}');
      emit(
        state.copyWith(
          signinStatus: SigninStatus.error,
          error: FirebaseAuthApiFailure(e.message.toString(), e.code, e.plugin),
        ),
      );
    } catch (e) {
      log('signin cubit unknown error: $e');
      emit(
        state.copyWith(
          signinStatus: SigninStatus.error,
          error: const FirebaseAuthApiFailure(
            'Unknown Authentication error',
            'Authentication error',
            'pocketbase_auth',
          ),
        ),
      );
    }
  }
}
