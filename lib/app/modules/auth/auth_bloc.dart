import 'dart:async';
import 'dart:developer';

import 'package:authentication_repository/authentication_repository.dart';
// ignore: implementation_imports
import 'package:authentication_repository/src/pocketbase_auth_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:otogapo/utils/clarity_helper.dart';
import 'package:otogapo/utils/crashlytics_helper.dart';
import 'package:pocketbase/pocketbase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this.authRepository,
    required this.pocketBaseAuth,
  }) : super(AuthState.unknown()) {
    _isLoggingOut = false;

    // Listen to PocketBase auth changes
    authSubsription = pocketBaseAuth.user.listen(
      (RecordModel? user) {
        // Don't process auth changes during logout to prevent race conditions
        if (!_isLoggingOut) {
          add(AuthStateChangedEvent(user: user));
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        // Log stream errors to Crashlytics and n8n
        CrashlyticsHelper.logError(
          error,
          stackTrace,
          reason: 'AuthBloc user stream error',
        );
      },
    );

    on<AuthStateChangedEvent>((event, emit) {
      log('auth state changing');
      if (event.user != null) {
        // Best-effort: set Clarity user id when authenticated
        final userId = event.user!.id;
        // Fire and forget
        // ignore: discarded_futures
        ClarityHelper.setUserId(userId);
        emit(
          state.copyWith(
            authStatus: AuthStatus.authenticated,
            user: event.user,
          ),
        );
      } else {
        emit(state.copyWith(authStatus: AuthStatus.unauthenticated));
      }
    });

    on<SignInRequestedEvent>((event, emit) async {
      try {
        emit(state.copyWith(authStatus: AuthStatus.unknown));
        await pocketBaseAuth.signIn(
          email: event.email,
          password: event.password,
        );
        // Auth state will be updated via the stream listener
      } catch (e, stackTrace) {
        // Report to Crashlytics and n8n
        await CrashlyticsHelper.logError(
          e,
          stackTrace,
          reason: 'SignInRequestedEvent failed',
        );
        emit(state.copyWith(authStatus: AuthStatus.unauthenticated));
        rethrow;
      }
    });

    on<SignUpRequestedEvent>((event, emit) async {
      try {
        emit(state.copyWith(authStatus: AuthStatus.unknown));
        await pocketBaseAuth.signUp(
          email: event.email,
          password: event.password,
          firstName: event.firstName,
          lastName: event.lastName,
          additionalData: event.additionalData,
        );
        // Auth state will be updated via the stream listener
      } catch (e, stackTrace) {
        // Report to Crashlytics and n8n
        await CrashlyticsHelper.logError(
          e,
          stackTrace,
          reason: 'SignUpRequestedEvent failed',
        );
        emit(state.copyWith(authStatus: AuthStatus.unauthenticated));
        rethrow;
      }
    });

    on<SignoutRequestedEvent>((event, emit) async {
      try {
        log('Signout requested...');
        _isLoggingOut = true; // Prevent stream listener from interfering
        emit(state.copyWith(authStatus: AuthStatus.unknown));

        await pocketBaseAuth.signOut();

        // Immediately emit unauthenticated state
        emit(state.copyWith(authStatus: AuthStatus.unauthenticated));
        log('Signout completed successfully');

        // Re-enable stream listener after a short delay
        Future<void>.delayed(const Duration(milliseconds: 1000), () {
          _isLoggingOut = false;
        });
      } catch (e, stackTrace) {
        log('Error during signout: $e');
        // Report to Crashlytics and n8n
        await CrashlyticsHelper.logError(
          e,
          stackTrace,
          reason: 'SignoutRequestedEvent failed',
        );
        // Still emit unauthenticated state even if there's an error
        emit(state.copyWith(authStatus: AuthStatus.unauthenticated));
        _isLoggingOut = false; // Re-enable stream listener
      }
    });

    on<CheckExistingAuthEvent>((event, emit) async {
      try {
        log('Checking existing authentication...');
        debugPrint(
          'AuthBloc - CheckExistingAuthEvent: Checking existing auth...',
        );

        // Check if PocketBase has a valid session
        final isAuthenticated = pocketBaseAuth.isAuthenticated;
        log('PocketBase isAuthenticated: $isAuthenticated');
        debugPrint(
          'AuthBloc - CheckExistingAuthEvent: isAuthenticated=$isAuthenticated',
        );

        if (isAuthenticated) {
          final user = pocketBaseAuth.currentUser;
          log('Current user: ${user?.id}');
          debugPrint(
            'AuthBloc - CheckExistingAuthEvent: Current user: ${user?.id}',
          );
          if (user != null) {
            log('User found, setting authenticated state');
            debugPrint(
              'AuthBloc - CheckExistingAuthEvent: User found',
            );
            debugPrint(
              'AuthBloc: authStatus=${state.authStatus}',
            );
            emit(
              state.copyWith(
                authStatus: AuthStatus.authenticated,
                user: user,
              ),
            );
            debugPrint(
              'AuthBloc - CheckExistingAuthEvent: State emitted successfully',
            );
          } else {
            log(
              'No user found despite authenticated, setting unauthenticated',
            );
            debugPrint(
              'AuthBloc - CheckExistingAuthEvent: No user found',
            );
            emit(state.copyWith(authStatus: AuthStatus.unauthenticated));
          }
        } else {
          log('Not authenticated, setting unauthenticated state');
          debugPrint(
            'AuthBloc - CheckExistingAuthEvent: Not authenticated',
          );
          emit(state.copyWith(authStatus: AuthStatus.unauthenticated));
        }
      } catch (e, stackTrace) {
        log('Error checking existing auth: $e');
        debugPrint('AuthBloc - CheckExistingAuthEvent: Error: $e');
        // Report to Crashlytics and n8n
        await CrashlyticsHelper.logError(
          e,
          stackTrace,
          reason: 'CheckExistingAuthEvent failed',
        );
        // Always emit unauthenticated on error to prevent hanging
        emit(state.copyWith(authStatus: AuthStatus.unauthenticated));
      }
    });

    // Note: CheckExistingAuthEvent removed - the user stream automatically
    // emits the current auth state on subscription
  }

  @override
  Future<void> close() {
    // Cancel stream subscription before closing bloc
    authSubsription.cancel();
    return super.close();
  }

  late final StreamSubscription<RecordModel?> authSubsription;
  final AuthRepository authRepository;
  final PocketBaseAuthRepository pocketBaseAuth;

  // Flag to prevent race conditions during logout
  bool _isLoggingOut = false;
}
