# Release Checklist

This checklist ensures all necessary steps are completed before releasing a new version of Otogapo to production.

## Pre-Release Preparation

### 1. Code Quality

- [ ] All tests pass locally (`flutter test --coverage`)
- [ ] No linter errors (`flutter analyze`)
- [ ] Code is properly formatted (`dart format .`)
- [ ] Generated code is up to date (`dart run build_runner build --delete-conflicting-outputs`)
- [ ] No compiler warnings
- [ ] Code review completed (if applicable)

### 2. Version Management

- [ ] Version number bumped in `pubspec.yaml`
- [ ] `CHANGELOG.md` updated with release notes
- [ ] Git tag created with version (e.g., `v1.0.0`)
- [ ] Release notes prepared
- [ ] Breaking changes documented (if any)

### 3. Testing

- [ ] Manual testing on Android physical device
- [ ] Manual testing on Android emulator
- [ ] Test all user flows (login, signup, profile, payments, etc.)
- [ ] Test admin features
- [ ] Test super admin features
- [ ] Performance testing completed
- [ ] Memory leak checks performed
- [ ] Network error handling verified
- [ ] Offline functionality tested (if applicable)

### 4. Build Verification

- [ ] Development build successful
- [ ] Staging build successful
- [ ] Production build successful (APK)
- [ ] Production build successful (AAB)
- [ ] App size checked and optimized
- [ ] Obfuscation disabled (currently off to simplify debugging)
- [ ] APK/AAB signature verified

### 5. Play Store Requirements

- [ ] App screenshots prepared (at least 2, up to 8)
- [ ] Feature graphic created (1024x500px)
- [ ] App icon verified
- [ ] Privacy policy published and URL available
- [ ] Store listing text prepared:
  - [ ] Short description (80 chars max)
  - [ ] Full description (4000 chars max)
  - [ ] What's new text for this version
- [ ] Content rating completed
- [ ] App category selected
- [ ] Target audience defined
- [ ] Data safety section completed

## Release Process

### 6. GitHub Actions

- [ ] GitHub Secrets configured:
  - [ ] `ANDROID_KEYSTORE_BASE64`
  - [ ] `ANDROID_KEYSTORE_PASSWORD`
  - [ ] `ANDROID_KEY_ALIAS`
  - [ ] `ANDROID_KEY_PASSWORD`
  - [ ] `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`
- [ ] CI workflow passing on main branch
- [ ] Release workflow tested (dry run if possible)

### 7. Fastlane Configuration

- [ ] Fastlane installed and configured
- [ ] Google Play Console API enabled
- [ ] Service account created and configured
- [ ] Fastlane metadata updated
- [ ] Test upload to internal track successful

### 8. Release Execution

#### Option A: Automated Release (Recommended)

- [ ] Create and push git tag: `git tag v1.0.0 && git push origin v1.0.0`
- [ ] Monitor GitHub Actions release workflow
- [ ] Verify AAB uploaded to Play Store (internal track)
- [ ] Verify GitHub Release created with artifacts

#### Option B: Manual Release

- [ ] Run build script: `./scripts/build_production.sh appbundle`
- [ ] Verify build artifacts
- [ ] Upload AAB to Play Store Console manually
- [ ] Create GitHub Release manually

### 9. Play Store Console

- [ ] Internal testing track:
  - [ ] Upload verified
  - [ ] Internal testers added
  - [ ] Test with internal users
  - [ ] Gather feedback
  - [ ] Fix critical issues
- [ ] Promote to next track (alpha/beta/production)
- [ ] Complete store listing:
  - [ ] Upload screenshots
  - [ ] Upload feature graphic
  - [ ] Verify app name and description
  - [ ] Set pricing and distribution
  - [ ] Configure in-app products (if applicable)
- [ ] Submit for review

## Post-Release

### 10. Monitoring

- [ ] Monitor crash reports (Firebase Crashlytics)
- [ ] Monitor user reviews
- [ ] Monitor app analytics
- [ ] Monitor performance metrics
- [ ] Check error logs in PocketBase
- [ ] Verify backend services operational

### 11. Communication

- [ ] Announce release to team
- [ ] Update documentation
- [ ] Create release announcement (if applicable)
- [ ] Update README with latest version
- [ ] Notify users of new features (in-app or email)

### 12. Backup and Documentation

- [ ] Backup keystore (secure location)
- [ ] Document any deployment issues encountered
- [ ] Update deployment documentation if process changed
- [ ] Archive build artifacts
- [ ] Tag Docker images (if using containers)

## Rollback Plan

In case of critical issues:

### Immediate Actions

1. **Pause release**: In Play Store Console, pause the rollout
2. **Assess severity**: Determine if rollback is necessary
3. **Communicate**: Notify team and stakeholders

### Rollback Steps

- [ ] Identify last stable version
- [ ] In Play Store Console, promote previous version
- [ ] Deactivate problematic release
- [ ] Investigate and fix issues
- [ ] Prepare hotfix release

### Post-Rollback

- [ ] Document what went wrong
- [ ] Update checklist to prevent similar issues
- [ ] Review testing procedures
- [ ] Plan hotfix release

## Version-Specific Notes

### First Release (1.0.0)

- [ ] Complete all Play Store setup (first time only)
- [ ] Create app in Play Store Console
- [ ] Submit app for initial review
- [ ] Complete all compliance requirements
- [ ] Set up closed testing track first

### Major Releases (X.0.0)

- [ ] Extra testing for breaking changes
- [ ] Migration guide prepared (if API changes)
- [ ] Backward compatibility verified
- [ ] Database migration tested (if applicable)

### Minor Releases (0.X.0)

- [ ] New features thoroughly tested
- [ ] Feature flags configured (if using)
- [ ] A/B testing setup (if applicable)

### Patch Releases (0.0.X)

- [ ] Bug fixes verified
- [ ] Regression testing completed
- [ ] Hotfix process followed (if applicable)

## Emergency Hotfix Process

For critical production issues:

1. [ ] Create hotfix branch from production tag
2. [ ] Fix critical issue with minimal changes
3. [ ] Test fix thoroughly
4. [ ] Fast-track testing process
5. [ ] Deploy using manual deploy workflow
6. [ ] Monitor closely after deployment
7. [ ] Merge hotfix back to main branch

## Review Frequency

- Review this checklist after each release
- Update based on lessons learned
- Add new items as process evolves
- Remove obsolete items

---

**Last Updated**: 2025-10-11  
**Next Review**: After v1.0.0 release
