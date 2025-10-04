# Developer Guide - OtoGapo

## Overview

This guide provides comprehensive information for developers working on the OtoGapo Flutter application. It covers development setup, coding standards, testing procedures, and contribution guidelines.

## Table of Contents

- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Project Structure](#project-structure)
- [State Management](#state-management)
- [Testing Guidelines](#testing-guidelines)
- [Code Generation](#code-generation)
- [Debugging](#debugging)
- [Performance Optimization](#performance-optimization)
- [Contributing](#contributing)
- [Troubleshooting](#troubleshooting)

## Development Setup

### Prerequisites

- Flutter SDK (>=3.3.0)
- Dart SDK (>=3.3.0)
- Android Studio / VS Code with Flutter extensions
- Git
- Firebase CLI (optional)

### Initial Setup

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd oto-gapo
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Generate code**

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run --flavor development --target lib/main_development.dart
   ```

### IDE Configuration

#### VS Code Settings

```json
{
  "dart.flutterSdkPath": "/path/to/flutter",
  "dart.lineLength": 80,
  "editor.rulers": [80],
  "editor.formatOnSave": true,
  "dart.previewFlutterUiGuides": true,
  "dart.previewFlutterUiGuidesCustomTracking": true
}
```

#### Android Studio Settings

1. Install Flutter and Dart plugins
2. Configure Flutter SDK path
3. Enable format on save
4. Set up code inspection rules

## Coding Standards

### Dart Style Guide

The project follows the official Dart style guide with additional rules from `very_good_analysis`:

#### Naming Conventions

```dart
// Classes: PascalCase
class UserRepository {}

// Variables and functions: camelCase
String userName = 'john_doe';
void updateUserProfile() {}

// Constants: camelCase with descriptive names
const String defaultApiUrl = 'https://api.example.com';

// Private members: underscore prefix
String _privateField = 'private';

// File names: snake_case
user_repository.dart
auth_bloc.dart
```

#### Code Formatting

```dart
// Use trailing commas for better formatting
Widget build(BuildContext context) {
  return Column(
    children: [
      Text('Hello'),
      Text('World'),
    ],
  );
}

// Prefer single quotes for strings
String message = 'Hello World';

// Use meaningful variable names
final List<User> activeUsers = [];
final DateTime currentDate = DateTime.now();

// Avoid abbreviations
String userFirstName = 'John'; // Good
String usrFstNm = 'John'; // Bad
```

#### Documentation

```dart
/// A repository that handles user authentication operations.
///
/// This class provides methods for signing in, signing up,
/// and managing user authentication state.
class AuthRepository {
  /// Signs in a user with email and password.
  ///
  /// Returns a [User] object if authentication is successful.
  /// Throws [AuthException] if authentication fails.
  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    // Implementation
  }
}
```

### Widget Guidelines

#### Widget Structure

```dart
class UserProfilePage extends StatefulWidget {
  const UserProfilePage({
    required this.userId,
    super.key,
  });

  final String userId;

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        return state.when(
          loading: () => const CircularProgressIndicator(),
          loaded: (user) => _buildUserInfo(user),
          error: (error) => _buildError(error),
        );
      },
    );
  }
}
```

#### Responsive Design

```dart
// Use ScreenUtil for responsive sizing
Container(
  width: 200.w,
  height: 100.h,
  margin: EdgeInsets.all(16.r),
  child: Text(
    'Responsive Text',
    style: TextStyle(fontSize: 16.sp),
  ),
)
```

### BLoC/Cubit Guidelines

#### Event Definition

```dart
@freezed
abstract class AuthEvent with _$AuthEvent {
  const factory AuthEvent.signInRequested({
    required String email,
    required String password,
  }) = SignInRequestedEvent;

  const factory AuthEvent.signOutRequested() = SignOutRequestedEvent;

  const factory AuthEvent.authStatusChanged({
    required AuthStatus status,
    User? user,
  }) = AuthStatusChangedEvent;
}
```

#### State Definition

```dart
@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;

  const factory AuthState.loading() = _Loading;

  const factory AuthState.authenticated({
    required User user,
  }) = _Authenticated;

  const factory AuthState.unauthenticated() = _Unauthenticated;

  const factory AuthState.error({
    required String message,
  }) = _Error;
}
```

#### BLoC Implementation

```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this.authRepository,
  }) : super(const AuthState.initial()) {
    on<SignInRequestedEvent>(_onSignInRequested);
    on<SignOutRequestedEvent>(_onSignOutRequested);
  }

  final AuthRepository authRepository;

  Future<void> _onSignInRequested(
    SignInRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    try {
      final user = await authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      emit(AuthState.authenticated(user: user));
    } catch (error) {
      emit(AuthState.error(message: error.toString()));
    }
  }
}
```

## Project Structure

### Directory Organization

```
lib/
├── app/
│   ├── modules/           # Feature modules
│   │   ├── auth/         # Authentication feature
│   │   │   ├── auth_bloc.dart
│   │   │   ├── auth_event.dart
│   │   │   ├── auth_state.dart
│   │   │   └── auth_page.dart
│   │   └── profile/      # Profile feature
│   ├── pages/            # Application pages
│   ├── routes/           # Navigation
│   ├── view/            # App shell
│   └── widgets/         # Reusable widgets
├── models/              # Data models
├── providers/           # Provider classes
├── services/           # Service classes
└── utils/             # Utility functions
```

### File Naming Conventions

- `*_bloc.dart` - BLoC classes
- `*_cubit.dart` - Cubit classes
- `*_event.dart` - BLoC events
- `*_state.dart` - BLoC states
- `*_page.dart` - Page widgets
- `*_widget.dart` - Reusable widgets
- `*_repository.dart` - Repository classes
- `*_service.dart` - Service classes

## State Management

### BLoC vs Cubit

Use **BLoC** for complex state management with multiple events:

```dart
// Use BLoC when you have multiple events
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // Multiple event handlers
}
```

Use **Cubit** for simpler state management:

```dart
// Use Cubit for simple state changes
class CounterCubit extends Cubit<int> {
  void increment() => emit(state + 1);
}
```

### State Management Best Practices

1. **Immutable States**

   ```dart
   @freezed
   abstract class UserState with _$UserState {
     const factory UserState.initial() = _Initial;
     const factory UserState.loading() = _Loading;
     const factory UserState.loaded(User user) = _Loaded;
   }
   ```

2. **Error Handling**

   ```dart
   try {
     final result = await repository.getData();
     emit(State.loaded(result));
   } catch (error) {
     emit(State.error(error.toString()));
   }
   ```

3. **Loading States**
   ```dart
   Future<void> loadData() async {
     emit(state.copyWith(isLoading: true));
     try {
       final data = await repository.fetchData();
       emit(state.copyWith(data: data, isLoading: false));
     } catch (error) {
       emit(state.copyWith(error: error, isLoading: false));
     }
   }
   ```

## Testing Guidelines

### Unit Tests

#### BLoC Testing

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('AuthBloc', () {
    late AuthBloc authBloc;
    late MockAuthRepository mockRepository;

    setUp(() {
      mockRepository = MockAuthRepository();
      authBloc = AuthBloc(authRepository: mockRepository);
    });

    tearDown(() {
      authBloc.close();
    });

    test('initial state is AuthState.initial', () {
      expect(authBloc.state, const AuthState.initial());
    });

    blocTest<AuthBloc, AuthState>(
      'emits [loading, authenticated] when sign in succeeds',
      build: () {
        when(() => mockRepository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => mockUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(const SignInRequestedEvent(
        email: 'test@example.com',
        password: 'password',
      )),
      expect: () => [
        const AuthState.loading(),
        AuthState.authenticated(user: mockUser),
      ],
    );
  });
}
```

#### Repository Testing

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  group('AuthRepository', () {
    late AuthRepository authRepository;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      authRepository = AuthRepository(client: mockDio);
    });

    test('signIn returns user when API call succeeds', () async {
      // Arrange
      when(() => mockDio.post('/auth/signin')).thenAnswer(
        (_) async => Response(
          data: {'user': userJson},
          statusCode: 200,
        ),
      );

      // Act
      final result = await authRepository.signIn(
        email: 'test@example.com',
        password: 'password',
      );

      // Assert
      expect(result.email, 'test@example.com');
      verify(() => mockDio.post('/auth/signin')).called(1);
    });
  });
}
```

### Widget Tests

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  group('AuthPage', () {
    late MockAuthBloc mockAuthBloc;

    setUp(() {
      mockAuthBloc = MockAuthBloc();
    });

    testWidgets('shows loading indicator when state is loading', (tester) async {
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(const AuthState.loading());
      when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: const AuthPage(),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
```

### Integration Tests

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('User Authentication Flow', () {
    testWidgets('complete sign in flow', (tester) async {
      // Start the app
      await tester.pumpWidget(const MyApp());

      // Navigate to sign in page
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Enter credentials
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password');

      // Tap sign in button
      await tester.tap(find.byKey(const Key('sign_in_button')));
      await tester.pumpAndSettle();

      // Verify navigation to home page
      expect(find.text('Welcome'), findsOneWidget);
    });
  });
}
```

## Code Generation

### Freezed Code Generation

```dart
// Run code generation
dart run build_runner build --delete-conflicting-outputs

// Watch for changes
dart run build_runner watch --delete-conflicting-outputs

// Clean generated files
dart run build_runner clean
```

### Auto Route Generation

```dart
// Generate routes
dart run build_runner build --delete-conflicting-outputs

// The generated file will be created at:
// lib/app/routes/app_router.gr.dart
```

### JSON Serialization

```dart
@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String name,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

## Debugging

### Debug Tools

1. **Flutter Inspector**

   - Widget tree inspection
   - Performance profiling
   - Layout debugging

2. **Dart DevTools**

   ```bash
   flutter run --debug
   # Open DevTools in browser
   ```

3. **Logging**

   ```dart
   import 'dart:developer' as developer;

   void logInfo(String message) {
     developer.log(message, name: 'App');
   }

   void logError(String message, [Object? error, StackTrace? stackTrace]) {
     developer.log(
       message,
       name: 'App',
       error: error,
       stackTrace: stackTrace,
     );
   }
   ```

### Common Debug Scenarios

1. **State Management Issues**

   ```dart
   // Add debug prints in BLoC
   @override
   void onChange(Change<AuthState> change) {
     super.onChange(change);
     print('AuthBloc: ${change.currentState} -> ${change.nextState}');
   }
   ```

2. **Navigation Issues**

   ```dart
   // Debug route navigation
   void debugPrintRoutes() {
     print('Current route: ${ModalRoute.of(context)?.settings.name}');
   }
   ```

3. **API Issues**
   ```dart
   // Add request/response logging
   dio.interceptors.add(LogInterceptor(
     requestBody: true,
     responseBody: true,
     logPrint: (obj) => print(obj),
   ));
   ```

## Performance Optimization

### Widget Optimization

1. **Use const constructors**

   ```dart
   const Text('Static text'); // Good
   Text('Static text'); // Bad
   ```

2. **Minimize rebuilds**

   ```dart
   // Use BlocBuilder only where needed
   BlocBuilder<AuthBloc, AuthState>(
     builder: (context, state) {
       return state.when(
         loading: () => const CircularProgressIndicator(),
         loaded: (user) => UserWidget(user: user),
         error: (error) => ErrorWidget(error: error),
       );
     },
   )
   ```

3. **Optimize images**
   ```dart
   // Use ExtendedImage for caching
   ExtendedImage.network(
     imageUrl,
     cache: true,
     fit: BoxFit.cover,
   )
   ```

### Memory Management

1. **Dispose resources**

   ```dart
   @override
   void dispose() {
     _controller.dispose();
     _subscription.cancel();
     super.dispose();
   }
   ```

2. **Use weak references**
   ```dart
   // Avoid strong references in callbacks
   Timer.periodic(Duration(seconds: 1), (timer) {
     if (mounted) {
       setState(() {});
     }
   });
   ```

## Contributing

### Pull Request Process

1. **Create feature branch**

   ```bash
   git checkout -b feature/new-feature
   ```

2. **Make changes**

   - Follow coding standards
   - Add tests for new functionality
   - Update documentation

3. **Run tests**

   ```bash
   flutter test
   flutter analyze
   ```

4. **Submit pull request**
   - Provide clear description
   - Link related issues
   - Request code review

### Code Review Checklist

- [ ] Code follows style guidelines
- [ ] Tests are included and passing
- [ ] Documentation is updated
- [ ] No breaking changes (or documented)
- [ ] Performance impact considered
- [ ] Security implications reviewed

### Commit Message Format

```
type(scope): description

[optional body]

[optional footer]
```

Examples:

```
feat(auth): add Google Sign-In support

fix(profile): resolve image upload issue

docs(readme): update installation instructions

refactor(bloc): simplify auth state management
```

## Troubleshooting

### Common Issues

1. **Build failures**

   ```bash
   # Clean and rebuild
   flutter clean
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   ```

2. **Code generation issues**

   ```bash
   # Delete generated files and regenerate
   find . -name "*.g.dart" -delete
   find . -name "*.freezed.dart" -delete
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **Dependency conflicts**

   ```bash
   # Check dependency tree
   flutter pub deps

   # Update dependencies
   flutter pub upgrade
   ```

4. **State management issues**
   - Check BLoC/Cubit initialization
   - Verify event/state definitions
   - Ensure proper disposal of resources

### Getting Help

1. **Check existing issues** in the repository
2. **Search documentation** for similar problems
3. **Ask questions** in team channels
4. **Create detailed issue** with reproduction steps

### Development Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [BLoC Documentation](https://bloclibrary.dev/)
- [Freezed Package](https://pub.dev/packages/freezed)
- [Auto Route](https://pub.dev/packages/auto_route)

This developer guide provides comprehensive information for contributing to the OtoGapo project effectively and efficiently.
