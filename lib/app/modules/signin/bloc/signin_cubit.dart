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
      await pocketBaseAuth.signInWithGoogleOAuth();
      emit(state.copyWith(signinStatus: SigninStatus.success));
      log('PocketBase Google OAuth successful');
    } on AuthFailure catch (e) {
      final raw = e.message.toString();
      final friendly =
          'Google Sign‑In failed. Please try again or use Email Sign‑In.\nIf the problem persists, contact the administrator.';
      log('signinWithGoogleOAuth cubit error: $raw');
      emit(
        state.copyWith(
          signinStatus: SigninStatus.error,
          error: FirebaseAuthApiFailure(friendly, 'Google Sign‑In Failed', ''),
        ),
      );
    } catch (e) {
      log('signinWithGoogleOAuth cubit unknown error: $e');
      emit(
        state.copyWith(
          signinStatus: SigninStatus.error,
          error: const FirebaseAuthApiFailure(
            'Google Sign‑In failed. Please try again or use Email Sign‑In. If the problem persists, contact the administrator.',
            'Google Sign‑In Failed',
            'pocketbase_google_oauth',
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
      // Map PocketBase's generic 400 to a friendlier message
      final raw = e.message.toString();
      final friendly = (raw.contains('Failed to authenticate') || raw.contains('status: 400'))
          ? 'Invalid email or password, or your account is not yet registered/activated.\nPlease verify your credentials or contact the administrator.'
          : raw;
      log('signin cubit error: $raw');
      emit(
        state.copyWith(
          signinStatus: SigninStatus.error,
          error: FirebaseAuthApiFailure(friendly, 'Invalid User', ''),
        ),
      );
    } catch (e) {
      log('signin cubit unknown error: $e');
      emit(
        state.copyWith(
          signinStatus: SigninStatus.error,
          error: const FirebaseAuthApiFailure(
            'Sign in failed. Please check your email and password, or contact the administrator.',
            'authentication_error',
            'pocketbase_auth',
          ),
        ),
      );
    }
  }
}
