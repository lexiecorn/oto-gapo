import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:otogapo/app/modules/signin/bloc/signin_cubit.dart';

import '../../../helpers/mock_factories.dart';

void main() {
  group('SigninCubit', () {
    late MockPocketBaseAuthRepository mockPocketBaseAuth;
    late SigninCubit signinCubit;

    setUp(() {
      mockPocketBaseAuth = MockPocketBaseAuthRepository();
      signinCubit = SigninCubit(pocketBaseAuth: mockPocketBaseAuth);
    });

    tearDown(() {
      signinCubit.close();
    });

    test('initial state has initial signinStatus', () {
      expect(signinCubit.state.signinStatus, SigninStatus.initial);
      expect(signinCubit.state.error, isNull);
    });

    group('signin', () {
      blocTest<SigninCubit, SigninState>(
        'emits submitting then success when sign-in succeeds',
        setUp: () {
          when(
            () => mockPocketBaseAuth.signIn(
              email: any<String>(named: 'email'),
              password: any<String>(named: 'password'),
            ),
          ).thenAnswer((_) async => createMockRecordModel());
        },
        build: () => signinCubit,
        act: (cubit) => cubit.signin(
          email: 'test@example.com',
          password: 'password123',
        ),
        expect: () => [
          const SigninState(signinStatus: SigninStatus.submitting),
          const SigninState(signinStatus: SigninStatus.success),
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

      blocTest<SigninCubit, SigninState>(
        'emits submitting then error with friendly message when AuthFailure occurs',
        setUp: () {
          when(
            () => mockPocketBaseAuth.signIn(
              email: any<String>(named: 'email'),
              password: any<String>(named: 'password'),
            ),
          ).thenThrow(
            createMockAuthFailure(
              code: 'Sign In Failed',
              message: 'Failed to authenticate, status: 400',
            ),
          );
        },
        build: () => signinCubit,
        act: (cubit) => cubit.signin(
          email: 'test@example.com',
          password: 'wrongpassword',
        ),
        expect: () => [
          const SigninState(signinStatus: SigninStatus.submitting),
          predicate<SigninState>(
            (state) =>
                state.signinStatus == SigninStatus.error &&
                state.error != null &&
                (state.error!.message.toString().contains('Invalid email or password')),
          ),
        ],
      );

      blocTest<SigninCubit, SigninState>(
        'emits submitting then error when non-400 AuthFailure occurs',
        setUp: () {
          when(
            () => mockPocketBaseAuth.signIn(
              email: any<String>(named: 'email'),
              password: any<String>(named: 'password'),
            ),
          ).thenThrow(
            createMockAuthFailure(
              code: 'Network Error',
              message: 'Connection timeout',
            ),
          );
        },
        build: () => signinCubit,
        act: (cubit) => cubit.signin(
          email: 'test@example.com',
          password: 'password123',
        ),
        expect: () => [
          const SigninState(signinStatus: SigninStatus.submitting),
          predicate<SigninState>(
            (state) =>
                state.signinStatus == SigninStatus.error &&
                state.error != null &&
                (state.error!.message.toString().contains('Connection timeout')),
          ),
        ],
      );

      blocTest<SigninCubit, SigninState>(
        'emits submitting then error when unknown exception occurs',
        setUp: () {
          when(
            () => mockPocketBaseAuth.signIn(
              email: any<String>(named: 'email'),
              password: any<String>(named: 'password'),
            ),
          ).thenThrow(Exception('Unexpected error'));
        },
        build: () => signinCubit,
        act: (cubit) => cubit.signin(
          email: 'test@example.com',
          password: 'password123',
        ),
        expect: () => [
          const SigninState(signinStatus: SigninStatus.submitting),
          predicate<SigninState>(
            (state) =>
                state.signinStatus == SigninStatus.error &&
                state.error != null &&
                (state.error!.message.toString().contains('Sign in failed')),
          ),
        ],
      );
    });

    group('signinWithGoogleOAuth', () {
      blocTest<SigninCubit, SigninState>(
        'emits submitting then success when Google OAuth succeeds',
        setUp: () {
          when(() => mockPocketBaseAuth.signInWithGoogleOAuth())
              .thenAnswer((_) async => createMockRecordModel());
        },
        build: () => signinCubit,
        act: (cubit) => cubit.signinWithGoogleOAuth(),
        expect: () => [
          const SigninState(signinStatus: SigninStatus.submitting),
          const SigninState(signinStatus: SigninStatus.success),
        ],
        verify: (_) {
          verify(() => mockPocketBaseAuth.signInWithGoogleOAuth()).called(1);
        },
      );

      blocTest<SigninCubit, SigninState>(
        'emits submitting then error when Google OAuth AuthFailure occurs',
        setUp: () {
          when(() => mockPocketBaseAuth.signInWithGoogleOAuth()).thenThrow(
            createMockAuthFailure(
              code: 'OAuth Error',
              message: 'OAuth failed',
            ),
          );
        },
        build: () => signinCubit,
        act: (cubit) => cubit.signinWithGoogleOAuth(),
        expect: () => [
          const SigninState(signinStatus: SigninStatus.submitting),
          predicate<SigninState>(
            (state) =>
                state.signinStatus == SigninStatus.error &&
                state.error != null &&
                (state.error!.message.toString().contains('Google Sign‑In failed')),
          ),
        ],
      );

      blocTest<SigninCubit, SigninState>(
        'emits submitting then error when unknown exception occurs',
        setUp: () {
          when(() => mockPocketBaseAuth.signInWithGoogleOAuth())
              .thenThrow(Exception('Unexpected error'));
        },
        build: () => signinCubit,
        act: (cubit) => cubit.signinWithGoogleOAuth(),
        expect: () => [
          const SigninState(signinStatus: SigninStatus.submitting),
          predicate<SigninState>(
            (state) =>
                state.signinStatus == SigninStatus.error &&
                state.error != null &&
                (state.error!.message.toString().contains('Google Sign‑In failed')),
          ),
        ],
      );
    });
  });
}

