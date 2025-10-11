# OtoGapo - Vehicle Association Management App

![coverage][coverage_badge]
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

A comprehensive Flutter application for managing vehicle associations, built with modern architecture patterns and best practices.

## 🚗 Overview

OtoGapo is a vehicle association management application that provides:

- **User Authentication & Management** - Secure login with Firebase and PocketBase
- **Member Profile Management** - Complete member information and vehicle details
- **Payment Tracking** - Monthly dues management and payment status tracking
- **Admin Dashboard** - User management and administrative functions
- **Announcements** - Association-wide announcements and updates
- **Multi-platform Support** - iOS, Android, Web, and Windows

## 🏗️ Architecture

The app follows a clean architecture pattern with:

- **State Management**: BLoC pattern with Cubits for local state
- **Dependency Injection**: GetIt for service locator pattern
- **Routing**: Auto Route for type-safe navigation
- **Backend**: Firebase + PocketBase hybrid approach
- **UI**: Material Design with responsive layouts using ScreenUtil

## 📱 Features

### Core Features

- **Authentication System**

  - Firebase Authentication integration
  - PocketBase authentication
  - Google Sign-In support
  - Secure session management

- **User Management**

  - Member registration and profile creation
  - User roles (Super Admin, Admin, Member)
  - Profile photo upload and management
  - Driver's license information tracking

- **Payment Management**

  - Monthly dues tracking
  - Payment status monitoring
  - Payment history and statistics
  - Advance payment support

- **Admin Features**

  - User management dashboard
  - Payment oversight
  - Announcement creation and management
  - Member statistics and reports

- **Profile Management**
  - Personal information management
  - Vehicle registration details
  - Emergency contact information
  - Medical information tracking

## 🛠️ Technology Stack

### Core Technologies

- **Flutter**: Cross-platform mobile framework
- **Dart**: Programming language
- **Firebase**: Authentication and cloud services
- **PocketBase**: Backend-as-a-Service for data management

### Key Dependencies

- **State Management**: `flutter_bloc`, `bloc`
- **Routing**: `auto_route`
- **Networking**: `dio`
- **Local Storage**: `hive`, `shared_preferences`
- **UI Components**: `flutter_screenutil`, `extended_image`
- **Authentication**: `firebase_auth`, `google_sign_in`
- **Image Handling**: `image_picker`
- **Validation**: `validators`

### Development Tools

- **Code Generation**: `build_runner`, `freezed`
- **Testing**: `flutter_test`, `bloc_test`, `mocktail`
- **Analysis**: `very_good_analysis`, `flutter_lints`

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.3.0)
- Dart SDK (>=3.3.0)
- Firebase project setup
- PocketBase instance

### Installation

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

4. **Configure Firebase**

   - Set up Firebase project
   - Download configuration files
   - Update `firebase_options_*.dart` files

5. **Configure PocketBase**
   - Set up PocketBase instance
   - Update PocketBase URL in flavor configurations

### Running the App

The app supports three flavors:

#### Development

```bash
flutter run --flavor development --target lib/main_development.dart
```

#### Staging

```bash
flutter run --flavor staging --target lib/main_staging.dart
```

#### Production

```bash
flutter run --flavor production --target lib/main_production.dart
```

### Building for Release

#### Android APK

```bash
# Development
flutter build apk --debug --target lib/main_development.dart --flavor development

# Production
flutter build apk --release --target lib/main_production.dart --flavor production
```

#### iOS

```bash
flutter build ios --release --target lib/main_production.dart --flavor production
```

## 📁 Project Structure

```
lib/
├── app/                          # Main application code
│   ├── modules/                  # Feature modules (BLoC/Cubit)
│   │   ├── auth/                # Authentication module
│   │   ├── profile/             # Profile management
│   │   ├── signin/              # Sign-in functionality
│   │   └── signup/              # Sign-up functionality
│   ├── pages/                   # UI pages/screens
│   ├── routes/                  # Navigation routing
│   ├── view/                    # App shell and main views
│   └── widgets/                 # Reusable UI components
├── bootstrap.dart               # App initialization
├── main_development.dart        # Development entry point
├── main_staging.dart           # Staging entry point
├── main_production.dart        # Production entry point
├── models/                     # Data models
├── providers/                  # Provider classes
├── services/                   # Service classes
└── utils/                      # Utility functions

packages/                       # Local packages
├── authentication_repository/  # Authentication logic
├── local_storage/             # Local storage abstraction
└── otogapo_core/             # Core UI components and themes
```

## 🔧 Configuration

### Flavor Configuration

Each flavor has its own configuration:

- **Development**: `lib/main_development.dart`
- **Staging**: `lib/main_staging.dart`
- **Production**: `lib/main_production.dart`

Configuration includes:

- PocketBase URL
- Firebase options
- Package version information
- Environment-specific settings

### PocketBase Configuration

The app uses PocketBase for backend services with the following collections:

- `users` - Member information
- `monthly_dues` - Payment tracking
- `Announcements` - Association announcements
- `app_data` - Application configuration

## 🧪 Testing

### Running Tests

```bash
# Run all tests with coverage
flutter test --coverage --test-randomize-ordering-seed random

# Run specific test files
flutter test test/unit/
flutter test test/widget/
```

### Viewing Coverage

```bash
# Generate coverage report
genhtml coverage/lcov.info -o coverage/

# Open coverage report
open coverage/index.html
```

### Test Structure

- `test/unit/` - Unit tests
- `test/widget/` - Widget tests
- `test/integration/` - Integration tests

## 📦 Build Runner Commands

```bash
# Build generated files
dart run build_runner build --delete-conflicting-outputs

# Watch for changes and rebuild
dart run build_runner watch --delete-conflicting-outputs

# Clean generated files
dart run build_runner clean
```

## 🌐 Internationalization

The app supports internationalization using `flutter_localizations`:

1. Add strings to `lib/l10n/arb/app_en.arb`
2. Generate localization files
3. Use `AppLocalizations.of(context)` in widgets

## 🔐 Security

- **Authentication**: Firebase Auth with Google Sign-In
- **Data Encryption**: Local data encrypted with Hive
- **Network Security**: HTTPS for all API calls
- **Input Validation**: Comprehensive validation using validators package

## 📊 Performance

- **Image Optimization**: Extended Image for caching and optimization
- **Responsive Design**: ScreenUtil for consistent sizing across devices
- **State Management**: Efficient BLoC pattern for predictable state updates
- **Lazy Loading**: On-demand initialization of services

## 🚀 Deployment

### Android

1. Configure signing in `android/key.properties`
2. Build release APK/AAB
3. Upload to Google Play Store

### iOS

1. Configure signing in Xcode
2. Build release archive
3. Upload to App Store Connect

### Web

```bash
flutter build web --release
```

### Windows

```bash
flutter build windows --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

### Code Style

- Follow Dart/Flutter conventions
- Use `very_good_analysis` for linting
- Write comprehensive tests
- Document public APIs

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:

- Create an issue in the repository
- Contact the development team
- Check the documentation in the `docs/` folder

## 🔄 Version History

- **v1.0.0+1** - Initial release with core functionality
  - User authentication and management
  - Payment tracking system
  - Admin dashboard
  - Profile management

---

**Built with ❤️ using Flutter and modern development practices**

[coverage_badge]: coverage_badge.svg
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C88.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
