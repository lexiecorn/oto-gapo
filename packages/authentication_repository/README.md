# Authentication Repository

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)
[![License: MIT][license_badge]][license_link]

A comprehensive authentication repository for the OtoGapo application, providing dual authentication support with Firebase and PocketBase.

## Overview

This package provides a complete authentication solution that integrates:

- **Firebase Authentication** - Primary authentication provider with Google Sign-In support
- **PocketBase Authentication** - Secondary authentication for data management and user records
- **Token Management** - Automatic token handling and refresh with `fresh_dio`
- **Secure Storage** - Encrypted local storage for authentication tokens

## Features

- Dual authentication with Firebase and PocketBase
- Google Sign-In integration
- Email/Password authentication
- OAuth 2.0 authentication with external providers
- Automatic token refresh and management
- Secure local token storage
- User profile management
- Authentication state streams
- Error handling with custom exceptions

## Installation 💻

**❗ In order to start using Authentication Repository you must have the [Dart SDK][dart_install_link] installed on your machine.**

Add `authentication_repository` to your `pubspec.yaml`:

```yaml
dependencies:
  authentication_repository:
    path: packages/authentication_repository
```

Install it:

```sh
flutter pub get
```

## Usage

### Initialize Repositories

```dart
import 'package:authentication_repository/authentication_repository.dart';
import 'package:local_storage/local_storage.dart';
import 'package:dio/dio.dart';

// Initialize dependencies
final storage = LocalStorage();
await storage.init();
final dio = Dio();

// Create repositories
final authRepository = AuthRepository(
  client: dio,
  storage: storage,
);

final pocketBaseAuthRepository = PocketBaseAuthRepository();
```

### Firebase Authentication

```dart
// Sign in with Google
final user = await authRepository.signInWithGoogle(
  idToken: googleIdToken,
  displayName: googleDisplayName,
);

// Get authentication state stream
authRepository.user.listen((user) {
  if (user != null) {
    print('User authenticated: ${user.uid}');
  } else {
    print('User signed out');
  }
});

// Sign out
await authRepository.signOut();
```

### PocketBase Authentication

```dart
// Sign up with email and password
final user = await pocketBaseAuthRepository.signUp(
  email: 'user@example.com',
  password: 'securePassword123',
  firstName: 'John',
  lastName: 'Doe',
);

// Sign in with email and password
final user = await pocketBaseAuthRepository.signIn(
  email: 'user@example.com',
  password: 'securePassword123',
);

// Check authentication status
final isAuthenticated = pocketBaseAuthRepository.isAuthenticated;

// Get current user
final currentUser = pocketBaseAuthRepository.currentUser;

// Sign out
await pocketBaseAuthRepository.signOut();
```

### OAuth2 Authentication

```dart
// Authenticate with OAuth2 provider
await pocketBaseAuthRepository.authWithOAuth2(
  provider: 'google',
  onAuthPopup: (url, cleanup) async {
    // Open OAuth popup and handle authentication
    await launchUrl(Uri.parse(url));
  },
);
```

### Error Handling

```dart
try {
  await pocketBaseAuthRepository.signIn(
    email: email,
    password: password,
  );
} on AuthFailure catch (e) {
  print('Authentication failed: ${e.message}');
  print('Error code: ${e.code}');
} catch (e) {
  print('Unexpected error: $e');
}
```

## Architecture

### AuthRepository

Handles Firebase authentication and token management:

- `signInWithGoogle()` - Google Sign-In authentication
- `signOut()` - Sign out current user
- `user` - Stream of authentication state changes
- `isAuthenticated` - Check if user is authenticated

### PocketBaseAuthRepository

Handles PocketBase authentication and user management:

- `signUp()` - Create new user account
- `signIn()` - Email/password authentication
- `signOut()` - Clear authentication state
- `authWithOAuth2()` - OAuth2 authentication
- `currentUser` - Get current authenticated user
- `isAuthenticated` - Check authentication status
- `user` - Stream of authentication state changes

## Models

### User

Firebase user model with profile information:

```dart
class User {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String memberNumber;
  final int membership_type;
  // ... other fields
}
```

### AuthFailure

Custom exception for authentication errors:

```dart
class AuthFailure implements Exception {
  final String code;
  final String message;
  final String plugin;
}
```

## Token Management

The repository uses `fresh_dio` for automatic token management:

- Tokens are securely stored using `LocalStorage`
- Automatic token refresh on expiration
- Tokens are included in HTTP requests automatically
- Token cleanup on sign out

---

## Continuous Integration 🤖

Authentication Repository comes with a built-in [GitHub Actions workflow][github_actions_link] powered by [Very Good Workflows][very_good_workflows_link] but you can also add your preferred CI/CD solution.

Out of the box, on each pull request and push, the CI `formats`, `lints`, and `tests` the code. This ensures the code remains consistent and behaves correctly as you add functionality or make changes. The project uses [Very Good Analysis][very_good_analysis_link] for a strict set of analysis options used by our team. Code coverage is enforced using the [Very Good Workflows][very_good_coverage_link].

---

## Running Tests 🧪

To run all unit tests:

```sh
dart pub global activate coverage 1.2.0
dart test --coverage=coverage
dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info
```

To view the generated coverage report you can use [lcov](https://github.com/linux-test-project/lcov).

```sh
# Generate Coverage Report
genhtml coverage/lcov.info -o coverage/

# Open Coverage Report
open coverage/index.html
```

[dart_install_link]: https://dart.dev/get-dart
[github_actions_link]: https://docs.github.com/en/actions/learn-github-actions
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[logo_black]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_black.png#gh-light-mode-only
[logo_white]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_white.png#gh-dark-mode-only
[mason_link]: https://github.com/felangel/mason
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_coverage_link]: https://github.com/marketplace/actions/very-good-coverage
[very_good_ventures_link]: https://verygood.ventures
[very_good_ventures_link_light]: https://verygood.ventures#gh-light-mode-only
[very_good_ventures_link_dark]: https://verygood.ventures#gh-dark-mode-only
[very_good_workflows_link]: https://github.com/VeryGoodOpenSource/very_good_workflows
