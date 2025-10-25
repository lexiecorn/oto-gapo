import 'dart:async';
import 'dart:developer';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:authentication_repository/src/pocketbase_auth_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:pocketbase/pocketbase.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required this.authRepository, required this.pocketBaseAuth}) : super(AuthState.unknown()) {
    _isLoggingOut = false;

    // Listen to PocketBase auth changes
    authSubsription = pocketBaseAuth.user.listen((RecordModel? user) {
      // Don't process auth changes during logout to prevent race conditions
      if (!_isLoggingOut) {
        add(AuthStateChangedEvent(user: user));
      }
    });

    on<AuthStateChangedEvent>((event, emit) {
      log('auth state changing');
      if (event.user != null) {
        emit(state.copyWith(authStatus: AuthStatus.authenticated, user: event.user));
      } else {
        emit(state.copyWith(authStatus: AuthStatus.unauthenticated));
      }
    });

    on<SignInRequestedEvent>((event, emit) async {
      try {
        emit(state.copyWith(authStatus: AuthStatus.unknown));
        await pocketBaseAuth.signIn(email: event.email, password: event.password);
        // Auth state will be updated via the stream listener
      } catch (e) {
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
        // Report to Crashlytics
        try {
          await FirebaseCrashlytics.instance.recordError(e, stackTrace);
        } catch (_) {
          // Ignore crashlytics errors
        }
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
        // Report to Crashlytics
        try {
          await FirebaseCrashlytics.instance.recordError(e, stackTrace);
        } catch (_) {
          // Ignore crashlytics errors
        }
        // Still emit unauthenticated state even if there's an error
        emit(state.copyWith(authStatus: AuthStatus.unauthenticated));
        _isLoggingOut = false; // Re-enable stream listener
      }
    });

    on<CheckExistingAuthEvent>((event, emit) async {
      try {
        log('Checking existing authentication...');

        // Check if PocketBase has a valid session
        final isAuthenticated = pocketBaseAuth.isAuthenticated;
        log('PocketBase isAuthenticated: $isAuthenticated');

        if (isAuthenticated) {
          final user = pocketBaseAuth.currentUser;
          log('Current user: ${user?.id}');
          if (user != null) {
            log('User found, setting authenticated state');
            emit(state.copyWith(authStatus: AuthStatus.authenticated, user: user));
          } else {
            log('No user found despite being authenticated, setting unauthenticated');
            emit(state.copyWith(authStatus: AuthStatus.unauthenticated));
          }
        } else {
          log('Not authenticated, setting unauthenticated state');
          emit(state.copyWith(authStatus: AuthStatus.unauthenticated));
        }
      } catch (e, stackTrace) {
        log('Error checking existing auth: $e');
        // Report to Crashlytics
        try {
          await FirebaseCrashlytics.instance.recordError(e, stackTrace);
        } catch (_) {
          // Ignore crashlytics errors
        }
        // Always emit unauthenticated on error to prevent hanging
        emit(state.copyWith(authStatus: AuthStatus.unauthenticated));
      }
    });

    // Check for existing authentication on startup (after all handlers are registered)
    _checkExistingAuth();
  }

  /// Check for existing authentication on startup
  void _checkExistingAuth() {
    add(CheckExistingAuthEvent());
  }

  // ignore: cancel_subscriptions
  late final StreamSubscription<RecordModel?> authSubsription;
  final AuthRepository authRepository;
  final PocketBaseAuthRepository pocketBaseAuth;

  // Flag to prevent race conditions during logout
  bool _isLoggingOut = false;
}
