import 'dart:async';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../helpers/mock_factories.dart';

void main() {
  group('AuthBloc', () {
    late MockAuthRepository mockAuthRepository;
    late MockPocketBaseAuthRepository mockPocketBaseAuth;
    late StreamController<RecordModel?> userStreamController;
    late AuthBloc authBloc;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockPocketBaseAuth = MockPocketBaseAuthRepository();
      userStreamController = StreamController<RecordModel?>();

      // Setup default stream behavior
      when(() => mockPocketBaseAuth.user).thenAnswer(
        (_) => userStreamController.stream,
      );
      when(() => mockPocketBaseAuth.isAuthenticated).thenReturn(false);
      when(() => mockPocketBaseAuth.currentUser).thenReturn(null);

      authBloc = AuthBloc(
        authRepository: mockAuthRepository,
        pocketBaseAuth: mockPocketBaseAuth,
      );
    });

    tearDown(() async {
      await userStreamController.close();
      await authBloc.close();
    });

    test('initial state is unknown', () {
      expect(authBloc.state.authStatus, AuthStatus.unknown);
      expect(authBloc.state.user, isNull);
    });

    group('CheckExistingAuthEvent', () {
      blocTest<AuthBloc, AuthState>(
        'emits authenticated state when user is authenticated',
        setUp: () {
          final mockUser = createMockRecordModel();
          when(() => mockPocketBaseAuth.isAuthenticated).thenReturn(true);
          when(() => mockPocketBaseAuth.currentUser).thenReturn(mockUser);
        },
        build: () => authBloc,
        wait: const Duration(milliseconds: 100),
        expect: () => [
          AuthState(
            authStatus: AuthStatus.authenticated,
            user: createMockRecordModel(),
          ),
        ],
        verify: (_) {
          verify(() => mockPocketBaseAuth.isAuthenticated).called(1);
          verify(() => mockPocketBaseAuth.currentUser).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits unauthenticated state when user is not authenticated',
        setUp: () {
          when(() => mockPocketBaseAuth.isAuthenticated).thenReturn(false);
          when(() => mockPocketBaseAuth.currentUser).thenReturn(null);
        },
        build: () => authBloc,
        wait: const Duration(milliseconds: 100),
        expect: () => [
          const AuthState(authStatus: AuthStatus.unauthenticated),
        ],
        verify: (_) {
          verify(() => mockPocketBaseAuth.isAuthenticated).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits unauthenticated state when isAuthenticated is true but currentUser is null',
        setUp: () {
          when(() => mockPocketBaseAuth.isAuthenticated).thenReturn(true);
          when(() => mockPocketBaseAuth.currentUser).thenReturn(null);
        },
        build: () => authBloc,
        wait: const Duration(milliseconds: 100),
        expect: () => [
          const AuthState(authStatus: AuthStatus.unauthenticated),
        ],
        verify: (_) {
          verify(() => mockPocketBaseAuth.isAuthenticated).called(1);
          verify(() => mockPocketBaseAuth.currentUser).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits unauthenticated state on error',
        setUp: () {
          when(() => mockPocketBaseAuth.isAuthenticated)
              .thenThrow(Exception('Test error'));
        },
        build: () => authBloc,
        wait: const Duration(milliseconds: 100),
        expect: () => [
          const AuthState(authStatus: AuthStatus.unauthenticated),
        ],
      );
    });

    group('SignInRequestedEvent', () {
      blocTest<AuthBloc, AuthState>(
        'emits unknown then authenticated when sign-in succeeds',
        setUp: () {
          final mockUser = createMockRecordModel();
          when(
            () => mockPocketBaseAuth.signIn(
              email: any<String>(named: 'email'),
              password: any<String>(named: 'password'),
            ),
          ).thenAnswer((_) async => mockUser);

          // Simulate user stream emitting the user after sign-in
          when(() => mockPocketBaseAuth.user).thenAnswer(
            (_) => Stream.value(mockUser),
          );
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(
          const SignInRequestedEvent(
            email: 'test@example.com',
            password: 'password123',
          ),
        ),
        expect: () => [
          const AuthState(authStatus: AuthStatus.unknown),
        ],
        verify: (_) {
          verify(
            () => mockPocketBaseAuth.signIn(
              email: 'test@example.com',
              password: 'password123',
            ),
          ).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits unknown then unauthenticated when sign-in fails',
        setUp: () {
          when(
            () => mockPocketBaseAuth.signIn(
              email: any<String>(named: 'email'),
              password: any<String>(named: 'password'),
            ),
          ).thenThrow(
            createMockAuthFailure(
              code: 'Sign In Failed',
              message: 'Invalid credentials',
            ),
          );
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(
          const SignInRequestedEvent(
            email: 'test@example.com',
            password: 'wrongpassword',
          ),
        ),
        expect: () => [
          const AuthState(authStatus: AuthStatus.unknown),
          const AuthState(authStatus: AuthStatus.unauthenticated),
        ],
        errors: () => [
          isA<AuthFailure>(),
        ],
        verify: (_) {
          verify(
            () => mockPocketBaseAuth.signIn(
              email: 'test@example.com',
              password: 'wrongpassword',
            ),
          ).called(1);
        },
      );
    });

    group('SignUpRequestedEvent', () {
      blocTest<AuthBloc, AuthState>(
        'emits unknown then authenticated when sign-up succeeds',
        setUp: () {
          when(
            () => mockPocketBaseAuth.signUp(
              email: any<String>(named: 'email'),
              password: any<String>(named: 'password'),
              firstName: any<String>(named: 'firstName'),
              lastName: any<String>(named: 'lastName'),
              additionalData: any<Map<String, dynamic>?>(named: 'additionalData'),
            ),
          ).thenAnswer((_) async => createMockRecordModel());

          final mockUser = createMockRecordModel();
          when(() => mockPocketBaseAuth.user).thenAnswer(
            (_) => Stream.value(mockUser),
          );
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(
          const SignUpRequestedEvent(
            email: 'newuser@example.com',
            password: 'password123',
            firstName: 'John',
            lastName: 'Doe',
          ),
        ),
        expect: () => [
          const AuthState(authStatus: AuthStatus.unknown),
        ],
        verify: (_) {
          verify(
            () => mockPocketBaseAuth.signUp(
              email: 'newuser@example.com',
              password: 'password123',
              firstName: 'John',
              lastName: 'Doe',
            ),
          ).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits unknown then unauthenticated when sign-up fails',
        setUp: () {
          when(
            () => mockPocketBaseAuth.signUp(
              email: any<String>(named: 'email'),
              password: any<String>(named: 'password'),
              firstName: any<String>(named: 'firstName'),
              lastName: any<String>(named: 'lastName'),
              additionalData: any<Map<String, dynamic>?>(named: 'additionalData'),
            ),
          ).thenThrow(
            createMockAuthFailure(
              code: 'Sign Up Failed',
              message: 'Email already exists',
            ),
          );
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(
          const SignUpRequestedEvent(
            email: 'existing@example.com',
            password: 'password123',
            firstName: 'Jane',
            lastName: 'Doe',
          ),
        ),
        expect: () => [
          const AuthState(authStatus: AuthStatus.unknown),
          const AuthState(authStatus: AuthStatus.unauthenticated),
        ],
        errors: () => [
          isA<AuthFailure>(),
        ],
      );
    });

    group('SignoutRequestedEvent', () {
      blocTest<AuthBloc, AuthState>(
        'emits unknown then unauthenticated when sign-out succeeds',
        setUp: () {
          when(() => mockPocketBaseAuth.signOut()).thenAnswer((_) async {});
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(SignoutRequestedEvent()),
        expect: () => [
          const AuthState(authStatus: AuthStatus.unknown),
          const AuthState(authStatus: AuthStatus.unauthenticated),
        ],
        verify: (_) {
          verify(() => mockPocketBaseAuth.signOut()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits unauthenticated state even when sign-out fails',
        setUp: () {
          when(() => mockPocketBaseAuth.signOut())
              .thenThrow(Exception('Sign out error'));
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(SignoutRequestedEvent()),
        expect: () => [
          const AuthState(authStatus: AuthStatus.unknown),
          const AuthState(authStatus: AuthStatus.unauthenticated),
        ],
      );
    });

    group('AuthStateChangedEvent', () {
      blocTest<AuthBloc, AuthState>(
        'emits authenticated state when user is provided',
        build: () => authBloc,
        act: (bloc) => bloc.add(
          AuthStateChangedEvent(user: createMockRecordModel()),
        ),
        expect: () => [
          AuthState(
            authStatus: AuthStatus.authenticated,
            user: createMockRecordModel(),
          ),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits unauthenticated state when user is null',
        build: () => authBloc,
        act: (bloc) => bloc.add(
          const AuthStateChangedEvent(),
        ),
        expect: () => [
          const AuthState(authStatus: AuthStatus.unauthenticated),
        ],
      );
    });
  });
}

