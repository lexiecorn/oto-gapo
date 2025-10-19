# Social Feed Implementation Guide

## Overview

The Social Feed feature is a comprehensive social media wall similar to Instagram/Facebook, allowing members to:

- Share posts with images and captions
- React with 6 different emotions (like, love, wow, haha, sad, angry)
- Comment on posts with @mentions and #hashtags
- Browse posts by user or hashtag
- Report inappropriate content
- Moderate content (admins only)

## Architecture

### Data Layer

**PocketBase Collections** (5 collections):

1. `posts` - User posts with images
2. `post_reactions` - User reactions to posts
3. `post_comments` - Comments on posts
4. `post_reports` - Content reports for moderation
5. `user_bans` - Admin bans for users

See [SOCIAL_FEED_SCHEMA.md](./SOCIAL_FEED_SCHEMA.md) for complete schema details.

### Models

**Location**: `lib/models/`

- `Post` - Represents a social post
- `PostReaction` - Represents a reaction with ReactionType enum
- `PostComment` - Represents a comment
- `PostReport` - Represents a content report
- `UserBan` - Represents a user ban

All models include:

- `fromRecord()` factory for PocketBase integration
- `copyWith()` for immutable updates
- Computed properties for business logic

### Services

**Location**: `lib/services/pocketbase_service.dart`

Added 30+ methods for social feed operations:

**Posts**:

- `createPost()` - Upload image and create post
- `updatePost()` - Update caption/tags
- `deletePost()` - Soft delete
- `hidePost()` - Admin hide/unhide
- `getPosts()` - Paginated feed
- `getUserPosts()` - User's posts
- `getPost()` - Single post

**Reactions**:

- `addReaction()` - Add or change reaction
- `removeReaction()` - Remove reaction
- `getReactions()` - All reactions for a post
- `getUserReaction()` - Check user's reaction

**Comments**:

- `addComment()` - Add comment
- `updateComment()` - Edit comment
- `deleteComment()` - Soft delete
- `hideComment()` - Admin hide/unhide
- `getComments()` - Paginated comments

**Moderation**:

- `reportPost()` / `reportComment()` - Submit reports
- `getReports()` - View reports (admin)
- `updateReportStatus()` - Review reports (admin)
- `banUser()` / `unbanUser()` - Manage bans (admin)
- `checkUserBan()` - Check if user is banned
- `getAllBans()` - View all bans (admin)

### State Management

**Location**: `lib/app/modules/social_feed/bloc/`

**FeedCubit** (`feed_cubit.dart`):

- Manages post feed state
- Handles pagination and infinite scroll
- Manages user reactions
- Creates/deletes posts
- Validates bans before posting

**CommentCubit** (`comment_cubit.dart`):

- Manages comments state
- Handles comment pagination
- Add/edit/delete comments (5-minute edit window)
- Validates bans before commenting

**ModerationCubit** (`moderation_cubit.dart`):

- Admin-only state management
- Loads and reviews reports
- Manages bans (create, view, deactivate)
- Hides/unhides content

### Utilities

**ImageCompressionUtils** (`lib/utils/image_compression_utils.dart`):

- Compresses images to <1MB
- Max resolution: 720p (1280x720)
- JPEG quality: 80%
- Progressive quality reduction if needed
- Maintains aspect ratio

**TextParsingUtils** (`lib/utils/text_parsing_utils.dart`):

- Extracts @mentions and #hashtags using regex
- Creates tappable RichText spans
- Real-time parsing support
- Validation methods

### UI Components

**Pages**:

1. `SocialFeedPage` - Main feed with tabs (Feed, My Posts)
2. `CreatePostPage` - Image picker and caption input
3. `PostDetailPage` - Full post view with comments
4. `UserPostsPage` - Grid view of user's posts
5. `HashtagPostsPage` - Posts filtered by hashtag
6. `SocialFeedModerationPage` - Admin dashboard (3 tabs)

**Widgets**:

1. `PostCardWidget` - Reusable post card for feed
2. `ReactionPickerWidget` - Bottom sheet for selecting reactions
3. `ReportDialogWidget` - Dialog for reporting content

### Routing

**Routes added** to `lib/app/routes/app_router.dart`:

- `/social-feed` - Main feed page
- `/social-feed/create` - Create post page
- `/social-feed/post/:postId` - Post detail
- `/social-feed/user/:userId` - User posts grid
- `/social-feed/hashtag/:hashtag` - Hashtag posts
- `/social-feed/moderation` - Admin moderation

**Navigation**:

- Home page has prominent "Social Feed" button
- Admin panel has "Social Feed Moderation" card
- Deep linking support for posts and hashtags

## Key Features

### 1. Image Compression

All uploaded images are automatically compressed:

- **Target size**: <1MB
- **Max resolution**: 720p (1280x720 pixels)
- **Quality**: 80% JPEG
- **Process**: Automatic on post creation
- **Benefits**: Faster loading, reduced storage costs

### 2. Multiple Reactions

Users can react to posts with 6 emotion types:

- 👍 Like
- ❤️ Love
- 😮 Wow
- 😂 Haha
- 😢 Sad
- 😠 Angry

**Behavior**:

- One reaction per user per post
- Can change reaction type
- Optimistic UI (instant feedback)
- Cached counts on posts

### 3. Comments with Tags

Comments support:

- @mentions - Tag other users
- #hashtags - Categorize content
- 500 character limit
- 5-minute edit window
- Tappable mentions and hashtags

### 4. Moderation System

**Admin Features**:

- Review user reports
- Hide/unhide posts and comments
- Delete inappropriate content
- Ban users (temporary or permanent)
- Ban types: post, comment, or all
- Unban users
- View ban history

**User Features**:

- Report posts or comments
- Choose reason (spam, inappropriate, harassment, other)
- Add optional details
- Track report status

### 5. Security

**Ban Enforcement**:

- Checked before post creation
- Checked before commenting
- Auto-expiry for temporary bans
- Ban types prevent specific actions

**Content Moderation**:

- Soft deletes (recoverable)
- Admin hide flag (separate from user delete)
- Report tracking and audit trail
- Admin notes for transparency

**Permissions**:

- PocketBase rules enforce access control
- Admin checks: `membership_type = 1 or 2`
- Owner checks for updates/deletes
- Public read for active content only

## Usage

### For Users

**Creating a Post**:

1. Navigate to Social Feed
2. Tap "Create Post" button
3. Select image from camera or gallery
4. Write caption (optional)
5. Use @username for mentions, #tag for hashtags
6. Tap "Post" to upload

**Reacting to Posts**:

1. Tap the reaction button on any post
2. Select from 6 reaction types
3. Tap again to change or remove

**Commenting**:

1. Tap on a post to view details
2. Write comment in the input field
3. Use @mentions and #hashtags
4. Tap send icon
5. Edit within 5 minutes if needed

**Reporting Content**:

1. Tap "..." menu on post/comment
2. Select "Report"
3. Choose reason and add details
4. Submit report to admins

### For Admins

**Accessing Moderation**:

1. Navigate to Admin Panel
2. Tap "Social Feed Moderation"
3. View 3 tabs: Reports, Hidden Content, Bans

**Reviewing Reports**:

1. View pending reports
2. Review content and reason
3. Choose action:
   - Hide content
   - Delete content
   - Dismiss report
   - Ban user

**Managing Bans**:

1. Go to Bans tab
2. View active and expired bans
3. Unban users as needed
4. Review ban history

## Installation & Setup

### 1. Import PocketBase Collections

```bash
# Login to PocketBase admin panel
https://pb.lexserver.org/_/

# Navigate to Settings → Import collections
# Upload: pocketbase/social_feed_collections_schema.json
# Click Import
```

### 2. Verify Collections

Ensure these collections exist:

- posts
- post_reactions
- post_comments
- post_reports
- user_bans

### 3. Test Permissions

Test with both admin and regular user accounts to verify:

- Users can create posts and comments
- Users can see only visible content
- Admins can access moderation features
- Bans prevent posting/commenting

### 4. Configure File Storage

Ensure PocketBase file storage is configured:

- Max file size: 1MB (enforced in app)
- Allowed types: JPEG, PNG, WebP
- Storage location configured
- Backups enabled

## Performance Considerations

### Pagination

- Posts: 20 per page
- Comments: 20 per page
- Infinite scroll with loading indicator
- Pull-to-refresh support

### Image Optimization

- Compression on upload (client-side)
- Thumbnail generation (PocketBase)
- Lazy loading in feed
- Cached with `cached_network_image`
- Full-screen zoom with `photo_view`

### Caching

- Reaction counts cached on posts
- Comment counts cached on posts
- User info denormalized in posts/comments
- Image caching with cache_network_image

### Database Indexes

All foreign keys and frequently queried fields are indexed:

- `idx_posts_user` - User's posts
- `idx_posts_created` - Chronological sorting
- `idx_post_reactions_unique` - One reaction per user/post
- `idx_post_comments_post` - Post's comments
- And more...

## Troubleshooting

### Images Not Uploading

- Check file size (<1MB before compression)
- Verify PocketBase authentication
- Check file permissions in PocketBase
- Review PocketBase logs

### Comments Not Appearing

- Verify `is_active = true` and `is_hidden_by_admin = false`
- Check user ban status
- Ensure comment is within 500 character limit
- Review PocketBase collection rules

### Mentions/Hashtags Not Working

- Use correct format: @username, #hashtag
- No spaces in mentions/hashtags
- Alphanumeric and underscores only
- Parsing happens on submit, not auto-complete

### Ban Not Enforced

- Ensure ban is active (`is_active = true`)
- Check ban hasn't expired
- Verify ban type matches action (post/comment/all)
- Review checkUserBan() implementation

## Future Enhancements

### Phase 2 Features (Planned):

- Multiple images per post (carousel)
- Video support
- Stories (24-hour temporary posts)
- Direct messaging
- Follow/unfollow users
- Personalized feed algorithm
- Push notifications
- Search and discovery
- Trending hashtags widget
- Advanced analytics

### Performance Improvements:

- Real-time updates with PocketBase subscriptions
- Optimistic UI for all mutations
- Background upload queue
- Offline support with sync

### Moderation Improvements:

- Automated content filtering
- User reputation system
- Community moderators
- Appeal process for bans
- Detailed moderation logs

## Dependencies

```yaml
image: ^4.0.0 # Image manipulation
flutter_image_compress: ^2.1.0 # Efficient compression
cached_network_image: ^3.3.0 # Image caching
photo_view: ^0.14.0 # Full-screen viewer
timeago: ^3.5.0 # Relative timestamps
path_provider: ^2.1.0 # File system access
image_picker: ^1.1.2 # Image selection
pocketbase: ^0.21.0 # Backend client
```

## Testing

### Manual Testing Checklist

**User Flow**:

- [ ] Create post with image
- [ ] Create post with caption
- [ ] Create post with mentions and hashtags
- [ ] React to post (all 6 types)
- [ ] Change reaction
- [ ] Remove reaction
- [ ] Add comment
- [ ] Edit comment (within 5 min)
- [ ] Delete own comment
- [ ] Delete own post
- [ ] Report post
- [ ] View user's posts grid
- [ ] View hashtag posts
- [ ] Infinite scroll works
- [ ] Pull to refresh works

**Admin Flow**:

- [ ] Access moderation dashboard
- [ ] Review pending reports
- [ ] Hide reported content
- [ ] Delete reported content
- [ ] Dismiss report
- [ ] Ban user (temporary)
- [ ] Ban user (permanent)
- [ ] Unban user
- [ ] View ban history
- [ ] Verify banned user cannot post
- [ ] Verify banned user cannot comment

### Automated Testing

Run tests with:

```bash
flutter test
```

Test coverage includes:

- Image compression utility tests
- Text parsing utility tests
- Model serialization tests
- Cubit state management tests
- Widget component tests
- Integration flow tests

## Security Best Practices

1. **Input Validation**:

   - Enforce max lengths (captions, comments, reasons)
   - Validate file types and sizes
   - Sanitize user input

2. **Access Control**:

   - Verify permissions on all operations
   - Check bans before mutations
   - Admin-only routes protected

3. **Content Moderation**:

   - Clear community guidelines
   - Quick response to reports
   - Transparent moderation process
   - Appeal mechanism

4. **Data Privacy**:
   - Users can delete their own content
   - Soft deletes for recovery
   - Audit trail for admin actions

## Support & Maintenance

### Monitoring

- Review reports regularly
- Monitor storage usage
- Track engagement metrics
- Review ban effectiveness

### Maintenance Tasks

- Clear expired bans (automated)
- Archive old posts (if needed)
- Update content guidelines
- Review and update moderation policies

### Support Issues

Common user questions:

1. How to delete a post?
2. How long can I edit comments?
3. What happens when I'm banned?
4. How do mentions and hashtags work?

Answers in-app help or FAQ section.

---

For schema details, see [SOCIAL_FEED_SCHEMA.md](./SOCIAL_FEED_SCHEMA.md).
For moderation guide, see [SOCIAL_FEED_MODERATION_GUIDE.md](./SOCIAL_FEED_MODERATION_GUIDE.md).
