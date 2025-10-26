import 'dart:developer';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:authentication_repository/src/pocketbase_auth_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'signin_cubit.freezed.dart';
part 'signin_state.dart';

class SigninCubit extends Cubit<SigninState> {
  SigninCubit({
    required this.pocketBaseAuth,
  }) : super(const SigninState());

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
          error: AuthFailure(
              message: friendly, code: 'Google Sign‑In Failed', plugin: ''),
        ),
      );
    } catch (e) {
      log('signinWithGoogleOAuth cubit unknown error: $e');
      emit(
        state.copyWith(
          signinStatus: SigninStatus.error,
          error: AuthFailure(
            message:
                'Google Sign‑In failed. Please try again or use Email Sign‑In. If the problem persists, contact the administrator.',
            code: 'Google Sign‑In Failed',
            plugin: 'pocketbase_google_oauth',
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
      final friendly = (raw.contains('Failed to authenticate') ||
              raw.contains('status: 400'))
          ? 'Invalid email or password, or your account is not yet registered/activated.\nPlease verify your credentials or contact the administrator.'
          : raw;
      log('signin cubit error: $raw');
      emit(
        state.copyWith(
          signinStatus: SigninStatus.error,
          error:
              AuthFailure(message: friendly, code: 'Invalid User', plugin: ''),
        ),
      );
    } catch (e) {
      log('signin cubit unknown error: $e');
      emit(
        state.copyWith(
          signinStatus: SigninStatus.error,
          error: AuthFailure(
            message:
                'Sign in failed. Please check your email and password, or contact the administrator.',
            code: 'authentication_error',
            plugin: 'pocketbase_auth',
          ),
        ),
      );
    }
  }
}
