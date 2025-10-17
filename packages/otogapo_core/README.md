# Otogapo Core

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)
[![License: MIT][license_badge]][license_link]

The core UI package for the OtoGapo application, providing reusable widgets, themes, utilities, and design system components.

## Overview

This package provides the foundational UI elements and utilities used throughout the OtoGapo application:

- **Theme System** - Consistent theming with OpstechTheme
- **Reusable Widgets** - Common UI components
- **Utilities** - Helper functions and extensions
- **Responsive Design** - ScreenUtil integration for consistent sizing
- **Design System** - Centralized color palette and typography

## Features

- Material Design 3 theme implementation
- Dark mode and light mode support
- Responsive sizing utilities
- Custom color palette
- Typography system with Google Fonts
- Reusable UI components
- Extension methods for common operations

## Installation 💻

**❗ In order to start using Otogapo Core you must have the [Flutter SDK][flutter_install_link] installed on your machine.**

Add `otogapo_core` to your `pubspec.yaml`:

```yaml
dependencies:
  otogapo_core:
    path: packages/otogapo_core
```

Install it:

```sh
flutter pub get
```

## Usage

### Theme System

```dart
import 'package:otogapo_core/otogapo_core.dart';

// Apply theme in your app
MaterialApp(
  theme: OpstechTheme.light,
  darkTheme: OpstechTheme.dark,
  themeMode: ThemeMode.system,
  home: MyHomePage(),
);
```

### Using Responsive Sizing

```dart
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo_core/otogapo_core.dart';

// Initialize ScreenUtil in your app
ScreenUtilInit(
  designSize: const Size(375, 812),
  minTextAdapt: true,
  splitScreenMode: true,
  builder: (context, child) {
    return MaterialApp(
      home: MyHomePage(),
    );
  },
);

// Use responsive sizing
Container(
  width: 200.w,  // Responsive width
  height: 100.h, // Responsive height
  padding: EdgeInsets.all(16.r), // Responsive padding
  child: Text(
    'Hello World',
    style: TextStyle(fontSize: 16.sp), // Responsive font size
  ),
);
```

### Color Palette

```dart
import 'package:otogapo_core/otogapo_core.dart';

// Access colors from the theme
Container(
  color: OpstechColors.primary,
  child: Text(
    'Primary Color',
    style: TextStyle(color: OpstechColors.onPrimary),
  ),
);
```

### Custom Widgets

The package provides several reusable widgets:

```dart
// Example widgets (if available in the package)
// Note: Add your custom widgets documentation here
```

## Components

### OpstechTheme

The main theme class providing light and dark theme configurations.

```dart
class OpstechTheme {
  static ThemeData get light => ThemeData(
    // Light theme configuration
  );

  static ThemeData get dark => ThemeData(
    // Dark theme configuration
  );
}
```

### OpstechColors

Centralized color palette for consistent color usage.

```dart
class OpstechColors {
  static const Color primary = Color(0xFF...);
  static const Color secondary = Color(0xFF...);
  static const Color accent = Color(0xFF...);
  // ... other colors
}
```

### Typography

Typography system with Google Fonts integration.

```dart
TextStyle headlineLarge = Theme.of(context).textTheme.headlineLarge;
TextStyle bodyMedium = Theme.of(context).textTheme.bodyMedium;
```

## Best Practices

1. **Use Theme Constants**: Always use theme colors instead of hardcoded values
2. **Responsive Sizing**: Use ScreenUtil (.w, .h, .sp, .r) for all dimensions
3. **Consistent Typography**: Use theme text styles for consistency
4. **Dark Mode Support**: Test UI in both light and dark modes
5. **Accessibility**: Follow accessibility guidelines for colors and text sizes

## Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo_core/otogapo_core.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return MaterialApp(
          title: 'OtoGapo',
          theme: OpstechTheme.light,
          darkTheme: OpstechTheme.dark,
          home: const HomePage(),
        );
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'OtoGapo',
          style: TextStyle(fontSize: 20.sp),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            Container(
              width: 200.w,
              height: 100.h,
              decoration: BoxDecoration(
                color: OpstechColors.primary,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: OpstechColors.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Continuous Integration 🤖

Otogapo Core comes with a built-in [GitHub Actions workflow][github_actions_link] powered by [Very Good Workflows][very_good_workflows_link] but you can also add your preferred CI/CD solution.

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
