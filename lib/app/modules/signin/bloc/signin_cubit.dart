import 'dart:developer';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:authentication_repository/src/pocketbase_auth_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:otogapo/utils/crashlytics_helper.dart';
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
    } on AuthFailure catch (e, stackTrace) {
      final raw = e.message.toString();
      const friendly =
          'Google Sign‑In failed. Please try again or use Email Sign‑In.\nIf the problem persists, contact the administrator.';
      log('signinWithGoogleOAuth cubit error: $raw');
      // Log to Crashlytics and n8n
      await CrashlyticsHelper.logError(
        e,
        stackTrace,
        reason: 'Google OAuth sign-in failed',
        fatal: false,
      );
      emit(
        state.copyWith(
          signinStatus: SigninStatus.error,
          error: AuthFailure(
              message: friendly, code: 'Google Sign‑In Failed', plugin: '',),
        ),
      );
    } catch (e, stackTrace) {
      log('signinWithGoogleOAuth cubit unknown error: $e');
      // Log to Crashlytics and n8n
      await CrashlyticsHelper.logError(
        e,
        stackTrace,
        reason: 'Google OAuth sign-in unknown error',
        fatal: false,
      );
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
    } on AuthFailure catch (e, stackTrace) {
      // Map PocketBase's generic 400 to a friendlier message
      final raw = e.message.toString();
      final friendly = (raw.contains('Failed to authenticate') ||
              raw.contains('status: 400'))
          ? 'Invalid email or password, or your account is not yet registered/activated.\nPlease verify your credentials or contact the administrator.'
          : raw;
      log('signin cubit error: $raw');
      // Log to Crashlytics and n8n
      await CrashlyticsHelper.logError(
        e,
        stackTrace,
        reason: 'Email/password sign-in failed',
        fatal: false,
      );
      emit(
        state.copyWith(
          signinStatus: SigninStatus.error,
          error:
              AuthFailure(message: friendly, code: 'Invalid User', plugin: ''),
        ),
      );
    } catch (e, stackTrace) {
      log('signin cubit unknown error: $e');
      // Log to Crashlytics and n8n
      await CrashlyticsHelper.logError(
        e,
        stackTrace,
        reason: 'Email/password sign-in unknown error',
        fatal: false,
      );
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
