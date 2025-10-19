# OtoGapo - Vehicle Association Management App

![coverage][coverage_badge]
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]
[![CI](https://github.com/yourusername/oto-gapo/workflows/CI/badge.svg)](https://github.com/yourusername/oto-gapo/actions/workflows/ci.yml)
[![Release](https://github.com/yourusername/oto-gapo/workflows/Release/badge.svg)](https://github.com/yourusername/oto-gapo/actions/workflows/release.yml)

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

- **Attendance Management** ✨ **NEW**

  - Meeting creation and management
  - QR code-based check-in system
  - Manual attendance marking by admins
  - Real-time attendance statistics
  - CSV export for reports
  - Personal attendance history
  - Attendance rate tracking

- **Admin Features**

  - User management dashboard
  - Payment oversight
  - Meeting and attendance management
  - Announcement creation and management
  - Member statistics and reports
  - Gallery management for homepage carousel

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
- **QR Code**: `qr_flutter`, `mobile_scanner`
- **Data Export**: `csv`, `share_plus`
- **Charts**: `fl_chart`

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
│   │   ├── signup/              # Sign-up functionality
│   │   ├── meetings/            # Meeting management (Cubit)
│   │   └── attendance/          # Attendance tracking (Cubit)
│   ├── pages/                   # UI pages/screens
│   │   ├── meetings_list_page.dart
│   │   ├── create_meeting_page.dart
│   │   ├── meeting_details_page.dart
│   │   ├── meeting_qr_code_page.dart
│   │   ├── qr_scanner_page.dart
│   │   ├── mark_attendance_page.dart
│   │   ├── user_attendance_history_page.dart
│   │   └── ...
│   ├── routes/                  # Navigation routing
│   ├── view/                    # App shell and main views
│   └── widgets/                 # Reusable UI components
│       ├── meeting_card.dart
│       ├── attendance_card.dart
│       └── ...
├── bootstrap.dart               # App initialization
├── main_development.dart        # Development entry point
├── main_staging.dart           # Staging entry point
├── main_production.dart        # Production entry point
├── models/                     # Data models
│   ├── meeting.dart            # Meeting model
│   ├── attendance.dart         # Attendance model
│   ├── attendance_summary.dart # Attendance summary
│   └── ...
├── providers/                  # Provider classes
├── services/                   # Service classes
└── utils/                      # Utility functions

packages/                       # Local packages
├── authentication_repository/  # Authentication logic
├── attendance_repository/      # Attendance & meeting management
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
- `payment_transactions` - Modern payment management
- `meetings` - Meeting information and schedules
- `attendance` - Attendance records
- `attendance_summary` - User attendance statistics
- `gallery_images` - Homepage carousel images
- `Announcements` - Association announcements
- `app_data` - Application configuration

#### PocketBase URL Configuration

The PocketBase URL is configured per environment in `FlavorConfig`:

```dart
// In lib/main_development.dart
FlavorConfig(
  name: 'DEV',
  variables: {
    'pocketbaseUrl': 'https://pb.lexserver.org',
    'pkgInfoVersion': 'Ver:${packageInfo.version} Build:${packageInfo.buildNumber}',
  },
);

// In lib/main_production.dart
FlavorConfig(
  name: 'PROD',
  variables: {
    'pocketbaseUrl': 'https://pb.lexserver.org',
    'pkgInfoVersion': 'Ver:${packageInfo.version} Build:${packageInfo.buildNumber}',
  },
);
```

Access the URL in your code:

```dart
final pocketbaseUrl = FlavorConfig.instance.variables['pocketbaseUrl'] as String;
```

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

The project supports two automated CI/CD platforms for streamlined deployment:

1. **Codemagic** (Recommended) - Flutter-native platform with GUI-based setup
2. **GitHub Actions** (Alternative) - Git-integrated CI/CD with Fastlane

### Codemagic Deployment (Recommended)

**Setup:**

```bash
# 1. Sign up at codemagic.io
# 2. Connect your GitHub repository
# 3. Upload keystore via UI: Settings → Code signing
# 4. Upload Google Play service account: Teams → Integrations
# 5. Push a tag to trigger release
```

**Quick Release:**

```bash
./scripts/bump_version.sh minor
git tag v1.1.0
git push origin v1.1.0
# Codemagic automatically builds and deploys to Play Store
```

See [Codemagic Setup Guide](./docs/CODEMAGIC_SETUP.md) for detailed instructions.

### GitHub Actions Deployment (Alternative)

**Quick Release:**

```bash
# Bump version
./scripts/bump_version.sh minor

# Commit and tag
git add pubspec.yaml
git commit -m "chore: bump version to 1.1.0"
git tag v1.1.0
git push origin main --tags

# GitHub Actions automatically:
# - Builds AAB/APK
# - Runs tests
# - Creates GitHub Release
# - Uploads to Play Store (internal track)
```

**Manual Deployment via GitHub Actions:**

1. Go to GitHub Actions tab
2. Select "Manual Deploy" workflow
3. Choose track (internal/alpha/beta/production)
4. Click "Run workflow"

### Local Build

**Production Build:**

```bash
./scripts/build_production.sh both
```

**Manual Deployment with Fastlane:**

```bash
cd android
bundle install
bundle exec fastlane internal  # or alpha, beta, production
```

### Platform-Specific Builds

**Android APK:**

```bash
flutter build apk --release --target lib/main_production.dart --flavor production
```

**Android App Bundle:**

```bash
flutter build appbundle --release --target lib/main_production.dart --flavor production
```

**iOS:**

```bash
flutter build ios --release --target lib/main_production.dart --flavor production
```

**Web:**

```bash
flutter build web --release --target lib/main_production.dart
```

**Docker (Web):**

```bash
# Quick deploy to Ubuntu server with Docker
./scripts/deploy_docker.sh
```

This will:

- Build production web app
- Create Docker container with Nginx
- Set up SSL with Let's Encrypt
- Deploy to your domain (e.g., https://otogapo.lexserver.org)

See [Docker Deployment Guide](./DOCKER_DEPLOYMENT.md) for detailed instructions.

**Windows:**

```bash
flutter build windows --release --target lib/main_production.dart
```

For detailed deployment instructions, see:

- [Deployment Guide](./docs/DEPLOYMENT.md)
- [Web Deployment Guide](./docs/WEB_DEPLOYMENT.md)
- [Docker Deployment Guide](./DOCKER_DEPLOYMENT.md)
- [Release Checklist](./docs/RELEASE_CHECKLIST.md)
- [Play Store Setup](./docs/PLAY_STORE_SETUP.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass (`flutter test`)
6. Ensure code is formatted (`dart format .`)
7. Ensure no linter errors (`flutter analyze`)
8. Commit your changes (`git commit -m 'feat: add amazing feature'`)
9. Push to the branch (`git push origin feature/amazing-feature`)
10. Open a Pull Request

### Code Style

- Follow Dart/Flutter conventions
- Use `very_good_analysis` for linting
- Write comprehensive tests
- Document public APIs
- Use conventional commits (feat:, fix:, docs:, etc.)

### CI/CD Pipeline

The project supports two CI/CD platforms:

**Codemagic (Recommended)**

- Flutter-native platform with GUI-based setup
- Simplified Play Store deployment
- Mac builds included for iOS
- See [Codemagic Setup Guide](./docs/CODEMAGIC_SETUP.md)

**GitHub Actions (Alternative)**

- Git-integrated CI/CD with Fastlane
- All PRs automatically run tests and linting
- Merges to main trigger build verification
- Tags trigger automated releases

See [Deployment Guide](./docs/DEPLOYMENT.md) for detailed comparison and setup instructions.

## 📚 Documentation

### Architecture & Development

- [Architecture Documentation](./docs/ARCHITECTURE.md) - Complete system architecture overview
- [API Documentation](./docs/API_DOCUMENTATION.md) - Comprehensive API reference
- [Developer Guide](./docs/DEVELOPER_GUIDE.md) - Development setup and workflows
- [Project Organization](./docs/PROJECT_ORGANIZATION.md) - File structure and organization
- [Cursor Rules Guide](./docs/CURSOR_RULES_GUIDE.md) - AI assistant rules and conventions

### Deployment & Operations

- [Deployment Guide](./docs/DEPLOYMENT.md) - Production deployment instructions
- [Docker Deployment](./docs/DOCKER_DEPLOYMENT.md) - Containerized deployment setup
- [Web Deployment](./docs/WEB_DEPLOYMENT.md) - Web platform deployment
- [Release Checklist](./docs/RELEASE_CHECKLIST.md) - Pre-release verification steps
- [Quick Start Guide](./docs/QUICK_START.md) - Get started quickly

### Features & Systems

- [Payment System](./docs/PAYMENT_SYSTEM.md) - Payment tracking implementation
- [Attendance System](./docs/ATTENDANCE_IMPLEMENTATION.md) - Meeting attendance features
- [Gallery Management](./docs/ARCHITECTURE.md#gallery-management-system) - Image carousel system

### CI/CD & Quality

- [Codemagic Setup](./docs/CODEMAGIC_SETUP.md) - Codemagic CI/CD configuration
- [Testing Summary](./test/TESTING_SUMMARY.md) - Test coverage and strategies
- [Play Store Setup](./docs/PLAY_STORE_SETUP.md) - Android app store deployment
- [Play Store Upload Guide](./docs/UPLOAD_TO_PLAY_STORE_GUIDE.md) - Step-by-step upload instructions

### Configuration & Data

- [PocketBase Schemas](./pocketbase/) - Database schemas and sample data
- [Play Store Assets](./docs/play-store/) - Store listing descriptions and release notes

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
