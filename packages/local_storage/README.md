# Local Storage

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)
[![License: MIT][license_badge]][license_link]

A secure and efficient local storage solution for the OtoGapo application, providing encrypted key-value storage and persistent data management.

## Overview

This package provides a unified interface for local data persistence using:

- **Hive** - Fast and efficient NoSQL database for Flutter
- **SharedPreferences** - Simple key-value storage for settings and preferences
- **Encryption** - Secure encryption for sensitive data

## Features

- Encrypted local storage for sensitive data
- Simple key-value storage interface
- Asynchronous operations
- Type-safe storage and retrieval
- Automatic initialization
- Cross-platform support (Android, iOS, Web, Desktop)

## Installation 💻

**❗ In order to start using Local Storage you must have the [Flutter SDK][flutter_install_link] installed on your machine.**

Add `local_storage` to your `pubspec.yaml`:

```yaml
dependencies:
  local_storage:
    path: packages/local_storage
```

Install it:

```sh
flutter pub get
```

## Usage

### Initialize Storage

```dart
import 'package:local_storage/local_storage.dart';

// Create storage instance
const storage = LocalStorage();

// Initialize storage (required before first use)
await storage.init();
```

### Store and Retrieve Data

```dart
// Write data
await storage.write(key: 'user_token', value: 'abc123');
await storage.write(key: 'user_id', value: '12345');
await storage.write(key: 'is_first_launch', value: true);

// Read data
final token = storage.read(key: 'user_token'); // Returns 'abc123'
final userId = storage.read(key: 'user_id'); // Returns '12345'
final isFirstLaunch = storage.read(key: 'is_first_launch'); // Returns true

// Check if key exists
final hasToken = storage.containsKey(key: 'user_token'); // Returns true

// Delete data
await storage.delete(key: 'user_token');

// Clear all data
await storage.clear();
```

### Token Storage

The package includes a specialized `TokenStorage` implementation for authentication tokens:

```dart
import 'package:local_storage/local_storage.dart';
import 'package:fresh_dio/fresh_dio.dart';

class AuthTokenStorage implements TokenStorage<String> {
  AuthTokenStorage(this._storage);
  final LocalStorage _storage;

  static const _key = '__auth_token__';

  @override
  Future<void> write(String token) async {
    await _storage.write(key: _key, value: token);
  }

  @override
  Future<String?> read() async {
    return _storage.read(key: _key) as String?;
  }

  @override
  Future<void> delete() async {
    await _storage.delete(key: _key);
  }
}
```

### Best Practices

1. **Initialize Once**: Call `init()` once during app startup
2. **Secure Sensitive Data**: Use encrypted storage for tokens and credentials
3. **Handle Errors**: Wrap storage operations in try-catch blocks
4. **Clean Up**: Clear storage on logout or when no longer needed
5. **Type Safety**: Store and retrieve data with appropriate types

### Example: Complete Setup

```dart
import 'package:flutter/material.dart';
import 'package:local_storage/local_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  const storage = LocalStorage();
  await storage.init();

  // Check if first launch
  final isFirstLaunch = storage.read(key: 'is_first_launch') ?? true;

  if (isFirstLaunch) {
    // First launch setup
    await storage.write(key: 'is_first_launch', value: false);
  }

  runApp(MyApp(storage: storage));
}
```

## API Reference

### LocalStorage

The main storage class providing key-value storage operations.

#### Methods

- `Future<void> init()` - Initialize storage (must be called before use)
- `Future<void> write({required String key, required dynamic value})` - Write data
- `dynamic read({required String key})` - Read data (returns null if not found)
- `bool containsKey({required String key})` - Check if key exists
- `Future<void> delete({required String key})` - Delete specific key
- `Future<void> clear()` - Clear all stored data

### Storage Types

The package supports storing the following types:

- `String` - Text data
- `int` - Integer numbers
- `double` - Floating-point numbers
- `bool` - Boolean values
- `List` - Lists of supported types
- `Map` - Maps with string keys and supported value types

---

## Continuous Integration 🤖

Local Storage comes with a built-in [GitHub Actions workflow][github_actions_link] powered by [Very Good Workflows][very_good_workflows_link] but you can also add your preferred CI/CD solution.

Out of the box, on each pull request and push, the CI `formats`, `lints`, and `tests` the code. This ensures the code remains consistent and behaves correctly as you add functionality or make changes. The project uses [Very Good Analysis][very_good_analysis_link] for a strict set of analysis options used by our team. Code coverage is enforced using the [Very Good Workflows][very_good_coverage_link].

---

## Running Tests 🧪

For first time users, install the [very_good_cli][very_good_cli_link]:

```sh
dart pub global activate very_good_cli
```

To run all unit tests:

```sh
very_good test --coverage
```

To view the generated coverage report you can use [lcov](https://github.com/linux-test-project/lcov).

```sh
# Generate Coverage Report
genhtml coverage/lcov.info -o coverage/

# Open Coverage Report
open coverage/index.html
```

[flutter_install_link]: https://docs.flutter.dev/get-started/install
[github_actions_link]: https://docs.github.com/en/actions/learn-github-actions
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[logo_black]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_black.png#gh-light-mode-only
[logo_white]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_white.png#gh-dark-mode-only
[mason_link]: https://github.com/felangel/mason
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_cli_link]: https://pub.dev/packages/very_good_cli
[very_good_coverage_link]: https://github.com/marketplace/actions/very-good-coverage
[very_good_ventures_link]: https://verygood.ventures
[very_good_ventures_link_light]: https://verygood.ventures#gh-light-mode-only
[very_good_ventures_link_dark]: https://verygood.ventures#gh-dark-mode-only
[very_good_workflows_link]: https://github.com/VeryGoodOpenSource/very_good_workflows
