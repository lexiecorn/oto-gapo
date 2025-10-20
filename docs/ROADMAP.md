# Roadmap & Future Features

## 🎯 Priority Levels

- **P0**: Critical - Next release
- **P1**: High - Upcoming releases
- **P2**: Medium - Planned
- **P3**: Low - Backlog/Ideas

## 📋 Planned Features

### P0 - Critical (Next Release)

<!-- Features planned for the immediate next release -->

### P1 - High Priority

<!-- Features planned for upcoming releases -->

**Note**: Social Feed (v1.0.0+10) and Attendance Management have been completed and moved to the Feature Archive.

**Feature Name**: Version Update Notifications & Force Update
**Priority**: P1
**Status**: Planned
**Target Release**: v1.3.0
**Description**: Implement an app version management system that can notify users about new versions and enforce mandatory updates when critical fixes are deployed.

**User Stories**:

- As an admin, I want to configure version requirements in the backend so that I can control which versions are supported
- As an admin, I want to mark certain updates as "force update" so users must upgrade before continuing
- As a user, I want to be notified when a new version is available so I can stay up-to-date
- As a user, I want to see what's new in the latest version so I can understand the benefits of updating
- As a user, I want to easily update the app when prompted
- As a user, if an update is mandatory, I should be guided to update before accessing the app

**Technical Notes**:

- **Backend**:
  - Store version configuration in PocketBase (min_version, current_version, force_update flag, release_notes)
  - API endpoint to check version compatibility
  - Admin interface to manage version settings
- **Frontend**:
  - Version check on app launch and resume
  - Dialog/modal for update notifications (optional vs force)
  - Link to app store (Play Store/App Store) for updates
  - Display release notes in update dialog
  - Block app usage if force update is required
- **Package**: Current app version from `package_info_plus`
- **Dependencies**:
  - `package_info_plus` (already in use)
  - PocketBase collection for version management
  - Optional: `url_launcher` for app store links (already in use)
- **Estimated Effort**: Medium

**Implementation Checklist**:

- [ ] Create PocketBase collection for version management
- [ ] Add version check service/repository
- [ ] Implement version comparison logic
- [ ] Create update dialog UI (optional vs mandatory)
- [ ] Add app store deep links
- [ ] Add version check on app startup
- [ ] Add version check on app resume
- [ ] Add admin UI for version management
- [ ] Write tests for version comparison logic
- [ ] Update documentation

### P2 - Medium Priority

<!-- Features in planning stage -->

**Feature Name**: Maintenance Mode
**Priority**: P2
**Status**: Planned
**Target Release**: v1.4.0
**Description**: Implement a maintenance mode system that can be triggered via database configuration, allowing admins to gracefully disable app functionality during maintenance windows, critical updates, or emergencies with customizable messaging.

**User Stories**:

- As an admin, I want to enable maintenance mode from the database so I can perform system maintenance without deploying app updates
- As an admin, I want to customize the maintenance message and estimated downtime
- As an admin, I want to allow certain users (e.g., admins) to bypass maintenance mode for testing
- As a user, I want to see a clear message explaining why the app is unavailable and when it will be back
- As a developer, I want to enable maintenance mode quickly in emergencies without requiring code deployment
- As a support team member, I want to see maintenance status in real-time

**Technical Notes**:

- **Database Configuration**: Store maintenance settings in PocketBase
  - `maintenance_enabled` (boolean)
  - `maintenance_message` (string)
  - `maintenance_title` (string)
  - `estimated_end_time` (datetime, optional)
  - `allowed_user_ids` (array, for bypass access)
  - `allowed_roles` (array, e.g., admin, developer)
  - `maintenance_start_time` (datetime, for logging)
  - `show_contact_support` (boolean)
  - `support_email` or `support_url` (string, optional)
- **Backend**:
  - PocketBase collection: `app_settings` or `maintenance_config`
  - API endpoint to check maintenance status
  - Real-time subscription for instant updates
  - Admin UI to toggle maintenance mode and configure settings
- **Frontend**:
  - Check maintenance status on app launch
  - Poll or subscribe to maintenance status during app use
  - Display full-screen maintenance overlay/page when enabled
  - Graceful handling of in-progress operations
  - Optional: Show countdown timer if end time is provided
  - Cache last maintenance check to handle offline scenarios
- **User Experience**:
  - Clear, friendly messaging explaining the situation
  - Branded maintenance screen matching app theme
  - Optional illustration/icon for maintenance
  - Estimated time until service restoration
  - Support contact information
  - Retry button to check if maintenance is complete
- **Implementation Strategy**:
  - Intercept all API calls with maintenance check
  - Use middleware/interceptor pattern in Dio
  - Alternative: Check on app resume and navigation
  - Block or queue operations during maintenance
- **Bypass Mechanism**:
  - Check user role or ID against allowed lists
  - Allow admins and developers to test during maintenance
  - Display banner indicating "Maintenance Mode Active (Admin Bypass)"
- **Notifications**:
  - Optional: Send push notification before maintenance starts
  - Optional: Send notification when maintenance is complete
- **Dependencies**:
  - PocketBase collection for configuration
  - Real-time subscription support (PocketBase real-time API)
  - Dio interceptor for API-level checks
- **Security Considerations**:
  - Only admins can modify maintenance settings
  - Audit log of maintenance mode changes
  - Prevent abuse by rate-limiting status checks
- **Estimated Effort**: Small-Medium

**Implementation Checklist**:

- [ ] Design maintenance mode screen UI/UX
- [ ] Create PocketBase collection for maintenance configuration
- [ ] Set up collection permissions (admin write, public read)
- [ ] Create maintenance service/repository
- [ ] Implement maintenance status check logic
- [ ] Add Dio interceptor for maintenance mode detection
- [ ] Create maintenance mode screen/overlay widget
- [ ] Implement user bypass logic (role-based)
- [ ] Add real-time subscription for maintenance status updates
- [ ] Create admin UI for toggling maintenance mode
- [ ] Add countdown timer for estimated end time
- [ ] Implement retry/refresh functionality
- [ ] Add maintenance mode banner for bypassed users
- [ ] Write tests for maintenance mode logic
- [ ] Test edge cases (mid-operation, offline, etc.)
- [ ] Document maintenance mode procedures
- [ ] Create runbook for enabling/disabling maintenance

**Prerequisites**:

- PocketBase backend operational
- Admin authentication and authorization
- Dio HTTP client configured

**Use Cases**:

- Scheduled maintenance windows
- Emergency hotfixes or database migrations
- Third-party service outages
- Load management during high traffic
- Graceful degradation during incidents

---

**Feature Name**: Shorebird Code Push Integration
**Priority**: P2
**Status**: Planned
**Target Release**: TBD
**Description**: Integrate Shorebird for over-the-air (OTA) code updates, enabling rapid bug fixes and feature updates without requiring users to download from the app store or wait for app store review.

**User Stories**:

- As a developer, I want to push critical bug fixes instantly so users don't have to wait for app store approval
- As a developer, I want to deploy small feature updates quickly so I can iterate faster
- As a developer, I want to rollback problematic updates remotely if issues are discovered
- As a user, I want to receive bug fixes automatically without having to manually update from the store
- As a user, I want the app to stay up-to-date seamlessly in the background

**Technical Notes**:

- **What is Shorebird**: Code push solution for Flutter that allows instant updates to Dart code without app store releases
- **Use Cases**:
  - Hot fixes for critical bugs
  - UI tweaks and minor feature updates
  - A/B testing and gradual rollouts
  - Emergency patches
- **Limitations**:
  - Cannot update native code (iOS/Android)
  - Cannot update assets or dependencies (requires full release)
  - Best for Dart code changes only
- **Integration Points**:
  - Works alongside existing version update system (P1 feature)
  - Shorebird handles code patches; app store handles major releases
  - Can configure patch deployment strategies (immediate, gradual, staged)
- **Backend**:
  - Shorebird CLI for managing patches
  - Shorebird console for patch analytics and rollback
  - Optional: Track patch versions in PocketBase alongside app versions
- **Frontend**:
  - Minimal changes - Shorebird SDK handles patch downloads
  - Add patch check on app launch/resume
  - Optional: Display patch download progress
- **Dependencies**:
  - Shorebird account and CLI
  - Shorebird Flutter SDK
  - CI/CD pipeline updates for patch deployment
  - Codemagic integration for automated patches
- **Security Considerations**:
  - Code signing for patch integrity
  - Compliance with app store policies (iOS/Android)
  - Testing strategy for patches
- **Estimated Effort**: Medium-Large

**Implementation Checklist**:

- [ ] Research Shorebird pricing and limitations
- [ ] Create Shorebird account and set up organization
- [ ] Install and configure Shorebird CLI
- [ ] Integrate Shorebird SDK into the app
- [ ] Update build scripts for Shorebird releases
- [ ] Configure Codemagic workflows for patch deployment
- [ ] Set up patch testing strategy and QA process
- [ ] Document patch deployment procedures
- [ ] Train team on Shorebird workflows
- [ ] Create rollback procedures
- [ ] Monitor patch adoption metrics
- [ ] Update developer guide with Shorebird usage

**Prerequisites**:

- Version Update Notifications (P1) should be implemented first
- Stable release process and version management
- Comprehensive testing infrastructure

---

**Feature Name**: Microsoft Clarity Analytics Integration
**Priority**: P2
**Status**: Planned
**Target Release**: TBD
**Description**: Integrate Microsoft Clarity for advanced user behavior analytics, session recordings, heatmaps, and insights to understand how users interact with the app and identify usability issues.

**User Stories**:

- As a product manager, I want to see session recordings so I can understand real user behavior
- As a UX designer, I want heatmaps to identify which areas users interact with most
- As a developer, I want to see where users encounter errors or friction
- As a product owner, I want insights on user flows to optimize conversion and engagement
- As a business stakeholder, I want to understand feature adoption and usage patterns

**Technical Notes**:

- **What is Microsoft Clarity**: Free analytics tool providing session recordings, heatmaps, and user insights
- **Key Features**:
  - Session recordings (replay user sessions)
  - Heatmaps (click, scroll, and area maps)
  - Rage clicks detection (frustrated user behavior)
  - Dead clicks detection (clicks on non-interactive elements)
  - Excessive scrolling detection
  - Quick back detection (users leaving pages immediately)
- **Benefits**:
  - Free forever with unlimited sessions
  - Privacy-focused (GDPR compliant)
  - Lightweight SDK with minimal performance impact
  - Integrates with Google Analytics
  - No session sampling (100% coverage)
- **Integration Approach**:
  - Use unofficial Flutter/Dart SDK or web view wrapper
  - Consider web platform first (easiest integration)
  - Mobile apps may require custom event tracking
  - Alternative: Use clarity for web version, native analytics for mobile
- **Privacy Considerations**:
  - Masking sensitive data (passwords, PII)
  - User consent for session recording
  - Compliance with privacy policies
  - Configure data retention policies
- **Data Collection**:
  - Automatic: Taps, scrolls, navigation, errors
  - Custom events: Feature usage, conversions, user flows
  - User properties: Device type, OS, app version
- **Dependencies**:
  - Microsoft Clarity account
  - Flutter SDK for Clarity (or custom implementation)
  - Privacy policy updates
  - User consent management
- **Integration Platforms**:
  - **Web**: Direct JavaScript SDK integration (recommended)
  - **Mobile**: Custom event tracking or community packages
  - Consider platform-specific approaches
- **Estimated Effort**: Small-Medium

**Implementation Checklist**:

- [ ] Research Flutter SDK options for Clarity
- [ ] Create Microsoft Clarity account and project
- [ ] Evaluate web vs mobile integration approaches
- [ ] Implement SDK integration (web first, then mobile)
- [ ] Configure data masking for sensitive fields
- [ ] Add custom event tracking for key features
- [ ] Implement user consent flow for session recording
- [ ] Update privacy policy to include session recording
- [ ] Set up dashboards and insights in Clarity portal
- [ ] Configure alerts for rage clicks and errors
- [ ] Train team on Clarity analytics and insights
- [ ] Document usage and best practices
- [ ] Monitor performance impact
- [ ] Establish data review cadence (weekly/monthly)

**Prerequisites**:

- Privacy policy compliance review
- User consent management system
- Understanding of data privacy regulations (GDPR, CCPA)

**Alternatives Considered**:

- Google Analytics 4 (already in use, but lacks session replay)
- Mixpanel (paid, more expensive)
- Hotjar (paid)
- FullStory (expensive, enterprise-focused)

---

**Feature Name**: Dynamic Monthly Dues Configuration
**Priority**: P2
**Status**: Planned
**Target Release**: v1.5.0
**Description**: Replace the hardcoded 100 pesos monthly dues amount with a dynamic, database-driven value that admins can update through an admin interface, allowing flexible dues management without requiring app updates.

**User Stories**:

- As an admin, I want to update the monthly dues amount from the admin panel so I don't need to deploy a new app version
- As an admin, I want to set different dues amounts for different membership tiers (future enhancement)
- As an admin, I want to see the history of dues changes for audit purposes
- As a member, I want to see the current monthly dues amount when making payments
- As a developer, I want the app to fetch the latest dues amount dynamically so it's always accurate

**Technical Notes**:

- **Database Schema** (PocketBase collection):
  - **app_settings** or **dues_config** collection:
    - `id` (auto)
    - `setting_key` (text, e.g., "monthly_dues_amount")
    - `setting_value` (number or text)
    - `description` (text, e.g., "Monthly membership dues in PHP")
    - `last_updated_by` (relation to users)
    - `updated_at` (datetime)
    - `is_active` (boolean)
  - Alternative: Single settings document approach with JSON fields
- **Current State**:
  - Find and document where 100 pesos is currently hardcoded
  - Replace hardcoded value with dynamic fetching
- **Backend**:
  - PocketBase collection for app settings/configuration
  - API endpoint to fetch current dues amount
  - Admin-only endpoint to update dues amount
  - Version history for dues changes (audit trail)
- **Frontend**:
  - Fetch dues amount on app launch or when needed
  - Cache dues amount locally with TTL (Time To Live)
  - Refresh dues amount periodically or on app resume
  - Display current dues in payment screens
  - Admin settings screen to update dues amount
  - Validation: Minimum/maximum dues limits
  - Confirmation dialog before changing dues
- **Caching Strategy**:
  - Cache dues amount in local storage
  - Refresh every 24 hours or on app startup
  - Force refresh when admin updates value
  - Fallback to cached value if network unavailable
- **Admin Interface**:
  - Input field with validation (numeric, positive value)
  - Save button with confirmation
  - Display current dues amount
  - Show last updated timestamp and user
  - Optional: Schedule future dues changes
- **Migration**:
  - Initialize database with current 100 pesos value
  - Update all screens that reference dues amount
  - Search for "100" in codebase and replace with dynamic fetch
- **Future Enhancements**:
  - Multiple dues tiers (regular, student, senior)
  - Scheduled dues changes (e.g., increase on Jan 1)
  - Dues history and trends
  - Member notification when dues change
  - Prorate dues for mid-month joiners
- **Dependencies**:
  - PocketBase collection for settings
  - Local storage for caching (already available)
  - Admin authentication and authorization
- **Estimated Effort**: Small

**Implementation Checklist**:

- [ ] Search codebase for hardcoded "100" dues references
- [ ] Document all locations where dues amount is used
- [ ] Create PocketBase collection for app settings/dues config
- [ ] Set up collection permissions (admin write, all read)
- [ ] Initialize collection with current 100 pesos value
- [ ] Create settings repository/service
- [ ] Implement dues amount fetch logic
- [ ] Add local caching with TTL
- [ ] Create DuesProvider or SettingsProvider for state management
- [ ] Update payment screens to use dynamic dues amount
- [ ] Create admin settings screen for dues management
- [ ] Add input validation for dues amount
- [ ] Implement update dues functionality
- [ ] Add confirmation dialog for dues changes
- [ ] Create dues history/audit log
- [ ] Add error handling and fallback to cached value
- [ ] Test with various dues amounts
- [ ] Test offline behavior with cached values
- [ ] Update documentation with new dues management process
- [ ] Create admin guide for changing dues

**Prerequisites**:

- PocketBase backend operational
- Admin authentication and role management
- Payment system implementation

**Migration Plan**:

1. Create and populate settings collection with 100 pesos
2. Update app to fetch from database (backward compatible)
3. Test thoroughly in staging
4. Deploy to production
5. Verify all payment flows work correctly
6. Remove hardcoded values from codebase

---

**Feature Name**: Announcement Management
**Priority**: P2
**Status**: Planned
**Target Release**: TBD
**Description**: Implement an announcement management system where admins can create, edit, and manage announcements that are visible to all members on the main Otogapo page. This provides a centralized way to communicate important information, events, and updates to the community.

**User Stories**:

- As an admin, I want to create announcements so I can communicate important information to all members
- As an admin, I want to edit or delete announcements so I can keep information current and accurate
- As an admin, I want to schedule announcements to be published at a specific date/time
- As an admin, I want to pin important announcements to keep them at the top of the list
- As an admin, I want to set announcement priority or categories (urgent, general, event, etc.)
- As a member, I want to see announcements on the main Otogapo page so I stay informed
- As a member, I want to see the most recent and important announcements first
- As a member, I want to read the full details of an announcement

**Technical Notes**:

- **Database Schema** (PocketBase collection):
  - **announcements** collection (already exists):
    - `id` (auto)
    - `title` (text)
    - `content` (text, rich text support)
    - `author_id` (relation to users)
    - `created_at` (datetime)
    - `updated_at` (datetime)
    - `published_at` (datetime, for scheduled publishing)
    - `is_published` (boolean)
    - `is_pinned` (boolean, for sticky announcements)
    - `priority` (text: normal, important, urgent)
    - `category` (text: general, event, maintenance, etc.)
    - `expires_at` (datetime, optional, for temporary announcements)
- **Backend**:
  - PocketBase collection for announcements (already configured)
  - Admin-only endpoints for create, update, delete operations
  - Public read access for published announcements
  - Filtering by published status and date ranges
  - Sorting by pinned status and date
- **Frontend**:
  - **Main Otogapo Page**: Display announcements list with title and preview
  - **Admin Panel**: Full CRUD interface for managing announcements
  - **Announcement Detail View**: Full content view with formatting
  - **Create/Edit Form**: Rich text editor for content, title, priority, category, scheduling
  - Pull-to-refresh for latest announcements
  - Pagination or infinite scroll for announcement history
- **Admin Interface Features**:
  - List view of all announcements (published and draft)
  - Create new announcement button
  - Edit/delete actions for existing announcements
  - Publish/unpublish toggle
  - Pin/unpin toggle
  - Preview before publishing
  - Status indicators (draft, published, scheduled, expired)
- **Member Interface Features**:
  - Announcement cards on main page
  - Visual indicators for priority (colors, icons)
  - Pinned announcements at the top
  - Expandable content or tap to view full details
  - Timestamp display (e.g., "Posted 2 hours ago")
- **Additional Features**:
  - Rich text formatting (bold, italic, lists, links)
  - Optional: Attach images or files to announcements
  - Optional: Push notifications for urgent announcements
  - Optional: Mark announcements as read
  - Optional: Comment or react to announcements
- **Dependencies**:
  - PocketBase collection for announcements (already exists)
  - Rich text editor package (e.g., `flutter_quill`, `html_editor_enhanced`)
  - Admin authentication and authorization
  - Local storage for caching (already available)
- **Estimated Effort**: Small-Medium

**Implementation Checklist**:

- [ ] Review and update existing PocketBase announcements collection schema
- [ ] Configure collection permissions (admin write, all read)
- [ ] Create announcements repository with CRUD operations
- [ ] Implement admin panel UI for announcement management
- [ ] Create announcement list widget for Otogapo main page
- [ ] Build announcement detail screen
- [ ] Implement rich text editor for content
- [ ] Add filtering and sorting logic (pinned, priority, date)
- [ ] Implement publish/unpublish functionality
- [ ] Add pin/unpin functionality
- [ ] Create priority and category selection
- [ ] Implement scheduling for future publication
- [ ] Add expiration logic for temporary announcements
- [ ] Implement pull-to-refresh for announcements list
- [ ] Add pagination or infinite scroll
- [ ] Create status indicators for admin view
- [ ] Add preview functionality before publishing
- [ ] Implement local caching for announcements
- [ ] Add error handling and offline support
- [ ] Write tests for announcements repository
- [ ] Test admin CRUD operations
- [ ] Test member view and filtering
- [ ] Update documentation with announcement management guide
- [ ] Create admin guide for creating effective announcements

**Prerequisites**:

- PocketBase backend operational
- Admin authentication and role management
- Main Otogapo page structure implemented

**Use Cases**:

- Weekly meeting announcements
- Special event notifications
- Policy updates and reminders
- Emergency or urgent communications
- Community news and updates
- Holiday greetings and celebrations

---

**Feature Name**: Vehicle Awards & Trophies
**Priority**: P2
**Status**: Planned
**Target Release**: TBD
**Description**: Implement a vehicle awards system to showcase achievements and trophies won at oto shows. Members can display their vehicle's accolades on their profile, with each award represented by a trophy icon. Clicking the trophy display opens a detailed list of all awards won by that vehicle.

**User Stories**:

- As a member, I want to display the awards my vehicle has won so I can showcase my achievements
- As a member, I want to see the number of trophies/awards at a glance on my vehicle profile
- As a member, I want to click on the trophy display to view detailed information about each award
- As a member with multiple awards, I want the trophy display to wrap properly to show all my achievements
- As an admin, I want to add, edit, or remove awards for vehicles so I can maintain accurate records
- As a visitor viewing a profile, I want to see what awards a vehicle has won to appreciate its accomplishments
- As a member, I want to add new awards to my vehicle when I win them at oto shows

**Technical Notes**:

- **Database Schema** (PocketBase collection):
  - **vehicle_awards** collection:
    - `id` (auto)
    - `vehicle_id` (relation to vehicles collection)
    - `award_name` (text, e.g., "Best Modified Car")
    - `event_name` (text, e.g., "Manila Auto Show 2025")
    - `event_date` (date)
    - `category` (text, e.g., "Modified", "Classic", "Best in Show")
    - `placement` (text, e.g., "1st Place", "Winner", "Champion")
    - `description` (text, optional additional details)
    - `award_image_url` (file/url, optional photo of trophy or certificate)
    - `created_at` (datetime)
    - `updated_at` (datetime)
    - `created_by` (relation to users)
- **Location**: Profile page, in the vehicle section
- **UI Components**:
  - **Trophy Display Row**:
    - Wrap layout showing trophy icons
    - Trophy count badge (e.g., "🏆 x5")
    - Tappable to navigate to awards detail page
    - Compact view showing just trophy count
  - **Awards Detail Page**:
    - List of all awards with full details
    - Each award card shows: name, event, date, placement, category
    - Optional: Award images/photos
    - Sort by date (newest first) or placement
    - Filter by year or event
- **Frontend Features**:
  - Trophy icon display with count
  - Wrapping layout for vehicles with many awards
  - Awards list screen with detailed information
  - Add/edit award form for members (with admin approval option)
  - Admin moderation for award entries
  - Empty state: "No awards yet" with encouragement message
- **Permissions**:
  - Vehicle owner can add awards to their own vehicles
  - Admins can add/edit/delete any awards
  - All users can view awards (read-only)
  - Optional: Require admin approval for new awards
- **Additional Features**:
  - Award statistics (total awards, by category, by year)
  - Leaderboard of most awarded vehicles (optional)
  - Share awards on social feed (integration with social feed feature)
  - Award verification system (photo proof requirement)
  - Export awards as PDF or share externally
- **UI/UX Considerations**:
  - Trophy icons should be visually appealing
  - Awards should be prominently displayed but not overwhelming
  - Smooth navigation to awards detail page
  - Mobile-friendly wrap layout for trophy row
  - Loading states while fetching awards
  - Animations for trophy display (optional shimmer or pulse effect)
- **Dependencies**:
  - Vehicles collection must exist with proper relations
  - User authentication to determine ownership
  - Admin role verification for moderation
  - Image upload for award photos (optional)
  - Navigation routing to awards detail page
- **Performance**:
  - Lazy load award details (only fetch when row is clicked)
  - Cache awards data locally
  - Paginate awards list if a vehicle has many awards
- **Validation**:
  - Prevent duplicate awards (same event, same category)
  - Date validation (event date not in future)
  - Required fields: award_name, event_name, event_date
- **Future Enhancements**:
  - Award badges and special recognition on profile
  - Push notifications when admin approves an award
  - Award timeline view (chronological history)
  - Integration with event management system
  - QR code verification for authentic awards
  - Award categories with icons (gold/silver/bronze medals)
- **Estimated Effort**: Small-Medium

**Implementation Checklist**:

- [ ] Create PocketBase vehicle_awards collection
- [ ] Set up collection permissions (owner + admin write, all read)
- [ ] Design trophy display UI for profile page
- [ ] Create awards repository with CRUD operations
- [ ] Build trophy count display component (wrapping layout)
- [ ] Implement navigation to awards detail page
- [ ] Build awards list screen with filtering/sorting
- [ ] Create add/edit award form
- [ ] Implement admin moderation interface (optional)
- [ ] Add award validation logic
- [ ] Create empty state for vehicles with no awards
- [ ] Add error handling and loading states
- [ ] Implement image upload for award photos (optional)
- [ ] Add award statistics display
- [ ] Create trophy icons or use emoji (🏆)
- [ ] Test wrapping behavior with many awards
- [ ] Test on different screen sizes (responsive)
- [ ] Write tests for awards repository
- [ ] Test permissions (owner vs admin vs viewer)
- [ ] Update documentation with awards feature guide
- [ ] Create user guide for adding awards

**Prerequisites**:

- Vehicles collection with proper schema
- User profiles and authentication
- Profile page with vehicle section implemented
- Admin role management

**Use Cases**:

- Member wins award at local car show and wants to display it
- Viewing another member's profile to see their achievements
- Admin verifying and approving award submissions
- Member with multiple awards wanting to showcase all trophies
- Sorting vehicles by most awarded in community

---

### P3 - Backlog/Ideas

<!-- Feature ideas and wishlist items -->

**Note**: Social Feed feature was completed and released in v1.0.0+10 (October 2025). See P1 section or Feature Archive for details.

---

## 🗂️ Feature Archive

Completed features are moved here for historical reference.

### Completed Features

---

**Feature Name**: Attendance Management  
**Priority**: P1  
**Status**: ✅ Complete  
**Target Release**: v1.2.0  
**Completed**: January 2025

**Summary**: Complete attendance management system with QR check-in, meeting management, and reporting.

**Key Features Implemented**:

- Meeting creation, editing, and deletion (admin)
- QR code generation for meetings
- Manual attendance marking by admins
- Member QR check-in
- Attendance history and statistics
- CSV export for reports
- Personal attendance history for users

**Documentation**:

- [Attendance Implementation Guide](./ATTENDANCE_IMPLEMENTATION.md)
- [Attendance Schema](./ATTENDANCE_SCHEMA.md)

---

**Feature Name**: Social Feed (Instagram/Facebook-like Member Posts)  
**Priority**: P1  
**Status**: ✅ Complete (Released in v1.0.0+10)  
**Target Release**: v1.0.0+10  
**Started**: January 2025  
**Completed**: October 2025  
**Progress**: 75-80% complete (Phases 1-7 done, testing pending)

**Summary**: A comprehensive social media wall where members can create posts with images, react with multiple emotions, comment with @mentions and #hashtags, and admins can fully moderate content.

**Key Features Implemented**:

- Post creation with image upload and compression
- 6 reaction types (like, love, wow, haha, sad, angry)
- Comments with @mentions and #hashtags
- User posts grid and hashtag filtering
- Admin moderation dashboard
- Content reporting and banning system
- Real-time feed updates with pull-to-refresh

**Documentation**:

- [Implementation Guide](./SOCIAL_FEED_IMPLEMENTATION.md)
- [Schema Documentation](./SOCIAL_FEED_SCHEMA.md)
- [Moderation Guide](./SOCIAL_FEED_MODERATION_GUIDE.md)
- [Implementation Progress](./SOCIAL_FEED_IMPLEMENTATION_PROGRESS.md)

---

### Historical Planning Notes for Social Feed

**Previous Planning Notes** (Feature has been completed as of October 2025):

**Technical Notes** (Implemented):

- **Database Schema** (PocketBase collections):
  - **posts** collection:
    - `id` (auto)
    - `user_id` (relation to users)
    - `caption` (text, optional)
    - `image_url` (file/url)
    - `image_thumbnail_url` (file/url, for performance)
    - `likes_count` (number, cached)
    - `comments_count` (number, cached)
    - `created_at` (datetime)
    - `updated_at` (datetime)
    - `is_active` (boolean, for soft delete)
  - **post_likes** collection:
    - `id` (auto)
    - `post_id` (relation to posts)
    - `user_id` (relation to users)
    - `created_at` (datetime)
  - **post_comments** collection:
    - `id` (auto)
    - `post_id` (relation to posts)
    - `user_id` (relation to users)
    - `comment_text` (text)
    - `created_at` (datetime)
    - `updated_at` (datetime)
    - `is_active` (boolean)
- **Frontend Features**:
  - **Feed Screen**: Infinite scroll list of posts with images, captions, like/comment counts
  - **Create Post Screen**: Image picker, caption input, preview, post button
  - **Post Detail Screen**: Full post view with comments section
  - **Profile Screen**: Grid view of user's posts
  - **Image Viewer**: Full-screen image viewing with swipe gestures
- **Core Functionality**:
  - Image upload with compression and optimization
  - Thumbnail generation for performance
  - Pull-to-refresh for feed updates
  - Infinite scroll/pagination
  - Real-time like and comment updates
  - Optimistic UI updates for instant feedback
- **Interactions**:
  - Double-tap or button to like posts
  - Comment with text input
  - Edit own comments (within time limit)
  - Delete own posts and comments
  - Report inappropriate content (admin moderation)
- **UI/UX Inspiration**:
  - Card-based feed layout similar to Instagram
  - Image aspect ratio handling
  - Like animation (heart pop effect)
  - Bottom sheet for comments
  - User avatar and name on each post
  - Timestamp display (e.g., "2 hours ago")
- **Performance Optimizations**:
  - Image caching with `cached_network_image`
  - Lazy loading images in feed
  - Pagination (20-30 posts per page)
  - Debouncing for like/unlike actions
  - Background upload queue for new posts
- **Dependencies**:
  - `image_picker` - for selecting images from gallery/camera
  - `cached_network_image` - for efficient image loading
  - `flutter_cache_manager` - for image caching
  - `image` package - for image compression
  - `timeago` - for relative timestamps
  - PocketBase file storage for images
  - Optional: `photo_view` - for pinch-to-zoom on images
  - Optional: `video_player` - if video support is added later
- **Security & Moderation**:
  - Content moderation tools for admins
  - Report post functionality
  - Block/hide users (optional)
  - Rate limiting on post creation
  - Image scanning for inappropriate content (optional)
- **Notifications**:
  - Push notification when someone likes your post
  - Push notification when someone comments on your post
  - In-app notification badge
- **Future Enhancements** (Phase 2):
  - Multiple images per post (carousel)
  - Video support
  - Stories (24-hour temporary posts)
  - Direct messaging
  - Hashtags and mentions
  - Search and discovery
  - Follow/unfollow users
  - Personalized feed algorithm
- **Estimated Effort**: Large (4-6 weeks)

**Implementation Checklist**:

- [ ] Design UI/UX mockups for feed, create post, and post detail screens
- [ ] Create PocketBase collections (posts, post_likes, post_comments)
- [ ] Set up file storage and image upload in PocketBase
- [ ] Configure collection permissions and rules
- [ ] Create posts repository with CRUD operations
- [ ] Implement image picker and compression logic
- [ ] Create thumbnail generation service
- [ ] Build feed screen with infinite scroll
- [ ] Build create post screen with image upload
- [ ] Build post detail screen with comments
- [ ] Implement like/unlike functionality with optimistic updates
- [ ] Implement comments functionality
- [ ] Add profile screen with user's posts grid
- [ ] Create post widget component (reusable card)
- [ ] Implement pull-to-refresh
- [ ] Add image caching and optimization
- [ ] Create like animation effect
- [ ] Implement edit and delete post functionality
- [ ] Add report/moderation functionality
- [ ] Create admin moderation UI
- [ ] Implement push notifications for likes and comments
- [ ] Add pagination for feed and comments
- [ ] Implement real-time updates (optional)
- [ ] Write tests for posts repository and business logic
- [ ] Performance testing with large datasets
- [ ] Content moderation policy documentation
- [ ] User documentation and guidelines

**Prerequisites**:

- File upload functionality working in PocketBase
- User authentication and profiles
- Push notifications system (for engagement alerts)
- Image compression and optimization strategy
- Content moderation policy

**Risks & Considerations**:

- Storage costs for images (consider limits or paid storage)
- Moderation overhead for inappropriate content
- User privacy and data protection
- Performance with high volume of posts
- Engagement and adoption by community

---

## 📝 Feature Template

Use this template when adding new features:

**Feature Name**:
**Priority**: P0 | P1 | P2 | P3
**Status**: Planned | In Progress | Testing | Complete
**Target Release**:
**Description**:
**User Stories**:

- As a [user type], I want [feature] so that [benefit]

**Technical Notes**:

- **Dependencies**:

- **Estimated Effort**: Small | Medium | Large

---

_Last Updated: October 2025_
