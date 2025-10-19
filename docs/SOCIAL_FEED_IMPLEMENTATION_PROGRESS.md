# Social Feed Implementation Progress

This document tracks the implementation progress of the social media wall feature for OtoGapo.

## Implementation Status

### ✅ Completed

#### Phase 1: Backend Setup

- ✅ PocketBase schema JSON created (`pocketbase/social_feed_collections_schema.json`)
- ✅ Schema documentation created (`docs/SOCIAL_FEED_SCHEMA.md`)
- ⏳ Collections created in PocketBase (needs manual import by admin)

#### Phase 2: Data Models

- ✅ `Post` model (`lib/models/post.dart`)
- ✅ `PostReaction` model with `ReactionType` enum (`lib/models/post_reaction.dart`)
- ✅ `PostComment` model (`lib/models/post_comment.dart`)
- ✅ `PostReport` model with enums (`lib/models/post_report.dart`)
- ✅ `UserBan` model with `BanType` enum (`lib/models/user_ban.dart`)

#### Phase 3: Repository Layer

- ✅ Image compression utility (`lib/utils/image_compression_utils.dart`)
- ✅ Text parsing utility for mentions/hashtags (`lib/utils/text_parsing_utils.dart`)
- ✅ Extended `PocketBaseService` with 30+ social feed methods
- ✅ Dependencies added to `pubspec.yaml`
- ✅ Dependencies installed via `flutter pub get`

### ✅ Completed

#### Phase 4: State Management (BLoC/Cubit)

- ✅ FeedCubit with FeedState - Post feed state management
- ✅ CommentCubit with CommentState - Comment state management
- ✅ ModerationCubit with ModerationState - Admin moderation state management

### 🚧 In Progress

### 📋 TODO

#### Phase 5: UI Implementation

- ⏳ Social Feed Page - Main feed with infinite scroll
- ⏳ Create Post Page - Image picker and caption input
- ⏳ Post Detail Page - Full post view with reactions and comments
- ⏳ Comments Section Widget - Display and add comments
- ⏳ Reaction Picker Widget - Select reaction type
- ⏳ User Posts Page - Grid view of user's posts
- ⏳ Hashtag Posts Page - Posts filtered by hashtag
- ⏳ Admin Moderation Dashboard - Manage reports, bans, content
- ⏳ Report Dialog Widget - Report inappropriate content

#### Phase 6: Routing

- ⏳ Add social feed routes to `app_router.dart`
- ⏳ Generate route files with `auto_route_generator`
- ⏳ Add Social Feed entry point in main navigation

#### Phase 7: Admin Panel Integration

- ⏳ Add "Social Feed Moderation" card to `AdminPage`
- ⏳ Wire up navigation to moderation dashboard

#### Phase 8: Testing

- ⏳ Unit tests for utilities (image compression, text parsing)
- ⏳ Widget tests for UI components
- ⏳ Integration tests for key flows

#### Phase 9: Documentation

- ⏳ Implementation guide (`docs/SOCIAL_FEED_IMPLEMENTATION.md`)
- ⏳ Moderation guide (`docs/SOCIAL_FEED_MODERATION_GUIDE.md`)
- ⏳ Update API documentation
- ⏳ Update roadmap (move from P3 to P1)

---

## Key Files Created/Modified

### New Files

1. `pocketbase/social_feed_collections_schema.json` - PocketBase schema
2. `docs/SOCIAL_FEED_SCHEMA.md` - Schema documentation
3. `lib/models/post.dart` - Post model
4. `lib/models/post_reaction.dart` - Reaction model
5. `lib/models/post_comment.dart` - Comment model
6. `lib/models/post_report.dart` - Report model
7. `lib/models/user_ban.dart` - Ban model
8. `lib/utils/image_compression_utils.dart` - Image compression
9. `lib/utils/text_parsing_utils.dart` - Text parsing

### Modified Files

1. `pubspec.yaml` - Added 6 new dependencies
2. `lib/services/pocketbase_service.dart` - Added 30+ social feed methods (700+ lines)

### Cubit Files Created

1. `lib/app/modules/social_feed/bloc/feed_cubit.dart` - Feed state management
2. `lib/app/modules/social_feed/bloc/feed_state.dart` - Feed state definition
3. `lib/app/modules/social_feed/bloc/comment_cubit.dart` - Comment state management
4. `lib/app/modules/social_feed/bloc/comment_state.dart` - Comment state definition
5. `lib/app/modules/social_feed/bloc/moderation_cubit.dart` - Moderation state management
6. `lib/app/modules/social_feed/bloc/moderation_state.dart` - Moderation state definition

---

## Dependencies Added

```yaml
image: ^4.0.0 # Image manipulation
flutter_image_compress: ^2.1.0 # Image compression
cached_network_image: ^3.3.0 # Image caching
photo_view: ^0.14.0 # Full-screen image viewer
timeago: ^3.5.0 # Relative timestamps
path_provider: ^2.1.0 # File system paths
```

---

## Next Steps

1. **Create State Management** (Phase 4)

   - Implement FeedCubit for managing post feed
   - Implement CommentCubit for managing comments
   - Implement ModerationCubit for admin features

2. **Build UI Components** (Phase 5)

   - Start with main feed page
   - Create reusable widgets (post card, comment item)
   - Build create post flow

3. **Setup Routing** (Phase 6)

   - Define routes in `app_router.dart`
   - Generate route files

4. **Integrate with Admin Panel** (Phase 7)

   - Add navigation from admin page
   - Test admin moderation features

5. **Test & Document** (Phases 8-9)
   - Write comprehensive tests
   - Complete documentation

---

## PocketBase Setup Instructions

To use the social feed feature, PocketBase collections must be imported:

1. Open PocketBase admin panel: `https://pb.lexserver.org/_/`
2. Navigate to **Settings** → **Import collections**
3. Upload `pocketbase/social_feed_collections_schema.json`
4. Click **Import**
5. Verify collections are created:
   - posts
   - post_reactions
   - post_comments
   - post_reports
   - user_bans

**Note**: Backup existing data before importing.

---

## Architecture Decisions

### Image Compression

- **Target**: 720p max (1280x720 pixels)
- **File Size**: < 1MB
- **Quality**: 80% JPEG
- **Reason**: Optimized for mobile viewing, saves storage costs

### Reactions

- **6 Types**: like, love, wow, haha, sad, angry
- **One per user**: Users can change reaction type
- **Optimistic UI**: Instant feedback before server response

### Moderation

- **Soft Deletes**: Use `is_active` flag for recovery
- **Admin Hide**: Separate `is_hidden_by_admin` flag
- **Ban Types**: post, comment, all
- **Temporary Bans**: Support for expiration dates

### Text Parsing

- **Mentions**: `@username` format
- **Hashtags**: `#hashtag` format
- **Tappable**: RichText with gesture recognizers
- **Stored**: JSON arrays in PocketBase

---

## Estimated Completion

- **Backend & Models**: ✅ Completed (2 days)
- **Repository**: ✅ Completed (3 days)
- **State Management**: ✅ Completed (3 days)
- **UI Implementation**: 📋 Planned (7-10 days)
- **Testing & Documentation**: 📋 Planned (4-6 days)

**Total Estimate**: 3-4 weeks for complete implementation

---

---

## Phase 4 Completion Summary

### FeedCubit

- Load feed with pagination and infinite scroll
- Load user-specific posts
- Load posts by hashtag
- Create new posts with image compression
- Delete posts
- Toggle reactions (6 types: like, love, wow, haha, sad, angry)
- Track user reactions per post
- Refresh individual posts
- Ban checking before post creation

### CommentCubit

- Load comments with pagination
- Add comments with mention/hashtag parsing
- Update comments (within 5 minute window)
- Delete comments
- Refresh comments
- Ban checking before commenting

### ModerationCubit (Admin Only)

- Load reports filtered by status
- Review reports with admin notes
- Hide/unhide posts and comments
- Ban users (temporary or permanent)
- Unban users
- Load all bans or filter by active status
- Load user ban history
- Support for ban types: post, comment, all

---

Last Updated: 2025-01-19 (Phase 4 Completed)
