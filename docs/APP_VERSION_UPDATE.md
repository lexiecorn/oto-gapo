# App Version Update System

## Overview

The app version update system allows administrators to control app versions via PocketBase configuration. It supports both optional and force updates with customizable release notes and store links.

## Features

- **Version Comparison**: Compares semantic version (1.0.0) and build number (+34)
- **Optional Updates**: Users can dismiss with "Remind Me Later"
- **Force Updates**: Blocks app usage until update is completed
- **Release Notes**: Display what's new in each update
- **Platform-Specific**: Separate configs for Android and iOS
- **Non-Blocking**: Version checks fail silently to not disrupt app startup

## PocketBase Configuration

### Collection: `app_version_config`

Create this collection in PocketBase with the following schema:

#### Required Fields

- **`platform`** (select, required): "android" or "ios"

  - Unique index ensures one record per platform

- **`min_version`** (text, required): Minimum required semantic version (e.g., "1.0.0")

- **`min_build_number`** (number, required): Minimum required build number (e.g., 30)

- **`current_version`** (text, required): Latest available semantic version (e.g., "1.0.0")

- **`current_build_number`** (number, required): Latest available build number (e.g., 34)

- **`store_url`** (text, required): Deep link to Play Store/App Store
  - Android: `https://play.google.com/store/apps/details?id=com.lexserver.otogapo`
  - iOS: `https://apps.apple.com/app/idXXXXXXXXXX`

#### Optional Fields

- **`force_update`** (bool, default: false): Whether update is mandatory
- **`release_notes`** (text, optional): What's new in the update
- **`enabled`** (bool, default: true): Whether version checking is active

### Sample Record

```json
{
  "platform": "android",
  "min_version": "1.0.0",
  "min_build_number": 30,
  "current_version": "1.0.0",
  "current_build_number": 34,
  "force_update": false,
  "release_notes": "• Bug fixes\n• Performance improvements\n• UI enhancements",
  "store_url": "https://play.google.com/store/apps/details?id=com.lexserver.otogapo",
  "enabled": true
}
```

## Architecture

### Components

1. **`AppVersionConfig` Model** (`lib/models/app_version_config.dart`)

   - Freezed model for version configuration
   - JSON serialization for PocketBase

2. **`VersionRepository`** (`lib/repositories/version_repository.dart`)

   - Fetches version config from PocketBase
   - Compares semantic versions and build numbers
   - Platform detection (Android/iOS)

3. **`VersionCheckCubit`** (`lib/app/modules/version_check/bloc/version_check_cubit.dart`)

   - Manages version check state
   - Triggers update checks on app launch

4. **`VersionCheckService`** (`lib/services/version_check_service.dart`)

   - Tracks dismissed versions in SharedPreferences
   - Prevents repeated "remind me later" prompts for same version

5. **`UpdateDialog`** (`lib/app/modules/version_check/widgets/update_dialog.dart`)

   - Displays update prompts
   - Different UI for force vs optional updates
   - Opens store URL on update button

6. **`VersionCheckWrapper`** (`lib/app/modules/version_check/widgets/version_check_wrapper.dart`)
   - Wraps authenticated portion of app
   - Listens to version check state
   - Shows dialogs when updates are available

### Version Comparison Logic

The system uses a two-tier comparison:

1. **Semantic Version Comparison** (major.minor.patch)

   - Parses version string into [major, minor, patch] parts
   - Compares from major to patch sequentially
   - Returns true if current version < required version

2. **Build Number Comparison**
   - If semantic versions are equal, compares build numbers
   - Returns true if current build < required build

**Example**:

```dart
// Current: 1.0.0+30, Required: 1.0.0+34
// Semantic versions equal → compare builds → 30 < 34 → Update needed ✅

// Current: 1.0.1+30, Required: 1.0.0+34
// Semantic versions: 1.0.1 > 1.0.0 → Update not needed ✅

// Current: 1.0.0+30, Required: 1.1.0+20
// Semantic versions: 1.0.0 < 1.1.0 → Update needed ✅
```

## Usage

### For Administrators

#### Setting Up Version Configuration

1. Open PocketBase admin panel
2. Navigate to Collections → app_version_config
3. Create records for each platform:

   - One record with `platform = "android"`
   - One record with `platform = "ios"`

4. Configure the fields according to your app version

#### Force Update Scenario

When releasing a critical bug fix or security update:

1. Set `min_version` to the minimum supported version
2. Set `min_build_number` to the minimum supported build
3. Set `force_update = true`
4. Update `release_notes` with critical information
5. Users with older versions will be blocked until they update

#### Optional Update Scenario

When releasing a minor feature or performance improvement:

1. Set `force_update = false`
2. Update `release_notes` with new features
3. Users can dismiss the prompt with "Remind Me Later"
4. Prompt reappears on next app launch

### For Developers

#### Manual Version Check

Users can manually check for updates in Settings:

```dart
// In settings_page.dart
ElevatedButton(
  onPressed: () {
    context.read<VersionCheckCubit>().checkForUpdates();
  },
  child: Text('Check for Updates'),
)
```

## Testing

### Test Scenarios

#### 1. Force Update Test

1. Set PocketBase config with `force_update = true` and `current_build_number = 999`
2. Launch app with build number < 999
3. **Expected**: Full-screen blocking dialog with "Update Now" button
4. Button should be non-dismissible and open Play Store

#### 2. Optional Update Test

1. Set PocketBase config with `force_update = false`
2. Launch app with older build number
3. **Expected**: Dismissible dialog with "Remind Me Later" and "Update" buttons
4. Tapping "Remind Me Later" should dismiss and save version
5. Relaunch app → dialog should not appear again

#### 3. Up-to-Date Test

1. Set PocketBase config with `current_build_number = 34`
2. Launch app with build 34 or higher
3. **Expected**: No dialog appears, app loads normally

#### 4. Network Error Test

1. Disable network or make PocketBase unavailable
2. Launch app
3. **Expected**: App loads normally, no crashes, no dialog

## Troubleshooting

### Dialog Not Appearing

**Check:**

- `enabled = true` in PocketBase config
- Correct platform (android/ios) in config
- App version and build number are actually older than required
- Version check is triggered in `HomePage` initialization

### Force Update Not Blocking

**Check:**

- `force_update = true` in PocketBase config
- Dialog is set to `barrierDismissible: false`
- Version is actually below minimum requirement

### "Remind Me Later" Not Working

**Check:**

- SharedPreferences is properly initialized in bootstrap
- Version string matches exactly when checking dismissal
- Debug with: `SharedPreferences.getString('dismissed_version')`

## Implementation Files

### New Files Created

- `pocketbase/app_version_config_schema.json` - PocketBase schema
- `lib/models/app_version_config.dart` - Version config model
- `lib/repositories/version_repository.dart` - Version fetching & comparison
- `lib/app/modules/version_check/bloc/version_check_cubit.dart` - Version check state
- `lib/app/modules/version_check/bloc/version_check_state.dart` - State definitions
- `lib/app/modules/version_check/widgets/update_dialog.dart` - Update dialog UI
- `lib/app/modules/version_check/widgets/version_check_wrapper.dart` - Wrapper widget
- `lib/services/version_check_service.dart` - Dismissal tracking
- `docs/APP_VERSION_UPDATE.md` - This documentation

### Modified Files

- `lib/bootstrap.dart` - Registered SharedPreferences and PackageInfo
- `lib/app/view/app.dart` - Added VersionCheckCubit provider
- `lib/app/pages/home_page.dart` - Wrapped with VersionCheckWrapper
- `pocketbase/README.md` - Added new collection info

## References

- [Semantic Versioning](https://semver.org/)
- [Package Info Plus](https://pub.dev/packages/package_info_plus)
- [URL Launcher](https://pub.dev/packages/url_launcher)
- [Flavor Config](docs/03-flavors-and-firebase.md)
