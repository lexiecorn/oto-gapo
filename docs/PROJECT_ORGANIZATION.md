# Project Organization

This document describes the organization of files and directories in the OtoGapo project.

## Directory Structure

```
oto-gapo/
├── android/              # Android platform code
├── assets/               # Application assets (images, icons)
├── docs/                 # 📚 All documentation
│   ├── play-store/      # Play Store listing assets
│   └── *.md             # Documentation files
├── ios/                  # iOS platform code
├── lib/                  # Flutter application code
├── nginx/                # Nginx configuration for Docker deployment
├── packages/             # Local packages
│   ├── attendance_repository/
│   ├── authentication_repository/
│   ├── local_storage/
│   └── otogapo_core/
├── pocketbase/          # 🗄️ PocketBase schemas and sample data
├── scripts/             # Build and deployment scripts
├── test/                # Test files
├── web/                 # Web platform files
├── windows/             # Windows platform code
├── CHANGELOG.md         # Version history
├── README.md            # Main project documentation
├── pubspec.yaml         # Flutter dependencies
└── ...                  # Configuration files
```

## Documentation Organization

### Main Documentation (`docs/`)

All markdown documentation has been organized into the `docs/` directory:

#### Architecture & API

- `ARCHITECTURE.md` - System architecture
- `API_DOCUMENTATION.md` - API reference
- `DEVELOPER_GUIDE.md` - Developer setup and workflows

#### Deployment

- `DEPLOYMENT.md` - Main deployment guide
- `DOCKER_DEPLOYMENT.md` - Docker containerized deployment
- `WEB_DEPLOYMENT.md` - Web platform deployment
- `BACKEND_UPDATE_GUIDE.md` - Quick backend update instructions
- `QUICK_START.md` - Quick start guide

#### Features

- `ATTENDANCE_IMPLEMENTATION.md` - Attendance system
- `ATTENDANCE_SCHEMA.md` - Attendance data schema
- `PAYMENT_SYSTEM.md` - Payment tracking
- `PAYMENT_DIALOG_DEBUG_GUIDE.md` - Payment debugging

#### CI/CD & Release

- `CODEMAGIC_SETUP.md` - Codemagic CI/CD
- `CODEMAGIC_MIGRATION.md` - CI/CD migration guide
- `CI_CD_VERIFICATION.md` - CI/CD verification
- `RELEASE_CHECKLIST.md` - Release verification
- `RELEASE_NOTES.md` - Release notes
- `RELEASE_NOTES_AUTOMATION.md` - Automated release notes

#### Play Store

- `PLAY_STORE_SETUP.md` - Play Store configuration
- `UPLOAD_TO_PLAY_STORE_GUIDE.md` - Upload guide
- `QUICK_UPLOAD_CHECKLIST.md` - Quick checklist
- `PLAY_STORE_RELEASE_NOTES_FORMAT.md` - Format guide
- `PLAY_STORE_RELEASE_NOTES.md` - Release notes
- `play-store/` - Store listing text files

#### PocketBase

- `POCKETBASE_ATTENDANCE_SETUP.md` - Attendance collections
- `POCKETBASE_PERMISSIONS_SETUP.md` - Security setup

#### Guides & References

- `LOCAL_BUILD_TESTING.md` - Local build testing
- `FILE_UPLOAD_FIXES.md` - File upload fixes
- `MARK_ATTENDANCE_QR_FEATURE.md` - QR attendance feature
- `USERS_COLLECTION_PERMISSIONS_FIX.md` - Permission fixes
- `16KB_PAGE_SIZE_IMPLEMENTATION.md` - 16KB page size setup
- `16KB_QUICK_START.md` - Quick start for 16KB
- `DOCUMENTATION_STATUS.md` - Documentation status
- `NEXT_STEPS.md` - Project roadmap
- `ROADMAP.md` - Feature roadmap
- `PRIVACY_POLICY_TEMPLATE.md` - Privacy policy template

### Play Store Assets (`docs/play-store/`)

Text files for Google Play Store:

- `PLAY_STORE_FULL_DESCRIPTION.txt` - Full app description (4000 chars)
- `PLAY_STORE_SHORT_DESCRIPTION.txt` - Short description (80 chars)
- `PLAY_STORE_WHATS_NEW.txt` - What's new template
- `PLAY_STORE_WHATS_NEW_v1.0.0+6.txt` - Version-specific updates
- `PLAY_STORE_RELEASE_NOTES_v1.0.0+6.txt` - Detailed release notes
- `RELEASE_NOTES_QUICK.txt` - Quick reference

### PocketBase Configuration (`pocketbase/`)

Database schemas and sample data:

#### Schema Files

- `pocketbase_users_schema.json` - User collection
- `pocketbase_announcements_schema.json` - Announcements
- `pocketbase_app_data_schema.json` - App configuration
- `pocketbase_collections_import.json` - Complete import

#### Sample Data

- `pocketbase_users_sample_data.json` - Sample users
- `pocketbase_sample_data.json` - General data
- `pocketbase_users_corrected.json` - Corrected users
- `pocketbase_announcements_corrected.json` - Corrected announcements
- `pocketbase_app_data_corrected.json` - Corrected app data

## Configuration Files

### Root Directory

Essential configuration files remain in the root:

- `pubspec.yaml` - Flutter dependencies
- `analysis_options.yaml` - Dart analyzer configuration
- `CHANGELOG.md` - Version history
- `README.md` - Main project documentation
- `codemagic.yaml` - Codemagic CI/CD configuration
- `docker-compose.yml` - Docker orchestration
- `Dockerfile` - Docker image definition
- `env.template` - Environment variables template
- `firebase.json` - Firebase configuration
- `firestore.rules` - Firestore security rules
- `firestore.indexes.json` - Firestore indexes

## Scripts Directory

Build and deployment automation:

- `build_production.sh` - Production build
- `bump_version.sh` - Version management
- `deploy_docker.sh` - Docker deployment (initial/full)
- `update_backend.sh` - Quick backend updates
- `fix_lints.sh` / `fix_lints.ps1` - Linting fixes
- `generate_release_notes.sh` - Release notes generation
- `renew_ssl.sh` - SSL renewal for Docker
- `setup_github_secrets.sh` - GitHub secrets setup
- `README.md` - Scripts documentation and usage

See `scripts/README.md` for detailed usage instructions.

## Packages Directory

Local Flutter packages:

- **attendance_repository** - Attendance management
- **authentication_repository** - Auth services
- **local_storage** - Local data storage
- **otogapo_core** - Shared UI components and theme

## Benefits of This Organization

### Clean Root Directory

- Only essential configuration files in root
- Easy to find important files
- Reduced clutter

### Organized Documentation

- All docs in one place (`docs/`)
- Logical grouping by topic
- Easy to navigate and maintain

### Separated Concerns

- PocketBase configs in dedicated directory
- Play Store assets grouped together
- Scripts in their own directory

### Improved Maintainability

- Clear structure for new contributors
- Easy to add new documentation
- Related files grouped together

### Better Discoverability

- README files in subdirectories explain contents
- Cross-references between docs
- Table of contents in README.md

## Finding Documentation

### Quick Links

- **Getting Started**: `README.md` → `docs/QUICK_START.md`
- **Architecture**: `docs/ARCHITECTURE.md`
- **API Reference**: `docs/API_DOCUMENTATION.md`
- **Deployment**: `docs/DEPLOYMENT.md`
- **Development**: `docs/DEVELOPER_GUIDE.md`

### By Topic

- **Attendance System**: `docs/ATTENDANCE_*.md`
- **Payment System**: `docs/PAYMENT_*.md`
- **Play Store**: `docs/PLAY_STORE_*.md` + `docs/play-store/`
- **PocketBase**: `docs/POCKETBASE_*.md` + `pocketbase/`
- **CI/CD**: `docs/CODEMAGIC_*.md` + `docs/CI_CD_*.md`
- **Docker**: `docs/DOCKER_*.md`

## Maintenance

### Adding New Documentation

1. Create `.md` file in appropriate location in `docs/`
2. Add link to `README.md` documentation section
3. Cross-reference from related docs
4. Update `docs/DOCUMENTATION_STATUS.md`

### Adding PocketBase Schemas

1. Export schema from PocketBase admin
2. Save to `pocketbase/` directory
3. Update `pocketbase/README.md`
4. Document in `docs/API_DOCUMENTATION.md`

### Adding Play Store Assets

1. Save text files to `docs/play-store/`
2. Follow character limits (noted in README)
3. Update version-specific files as needed

## Migration Summary

This organization was established on October 19, 2025:

### Moved to `docs/`

- 19 markdown files from root
- All documentation now centralized

### Created Subdirectories

- `docs/play-store/` - 6 text files
- `pocketbase/` - 9 JSON files

### Consolidated Files

- Removed 11 duplicate/redundant documentation files
- Merged related content

### Cleaned Up

- Removed temporary log files
- Organized keystore files
- Added README files to new directories

### Updated References

- Fixed all documentation links
- Updated README.md structure
- Cross-referenced related docs

## See Also

- [README.md](../README.md) - Main project documentation
- [docs/DOCUMENTATION_STATUS.md](./DOCUMENTATION_STATUS.md) - Documentation completeness
- [docs/DEVELOPER_GUIDE.md](./DEVELOPER_GUIDE.md) - Development workflows
