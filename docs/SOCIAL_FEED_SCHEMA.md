# Social Feed - PocketBase Collections Schema

This document describes the PocketBase collections required for the social feed feature.

## Collections Overview

The social feed feature uses 5 PocketBase collections:

1. **posts** - User posts with images and captions
2. **post_reactions** - User reactions to posts (like, love, wow, etc.)
3. **post_comments** - Comments on posts
4. **post_reports** - Reports of inappropriate posts or comments
5. **user_bans** - Admin bans for users who violate community guidelines

---

## Collection: `posts`

Stores user posts with images and captions.

### Fields

| Field                | Type            | Required | Description                              |
| -------------------- | --------------- | -------- | ---------------------------------------- |
| `id`                 | auto            | ✓        | Auto-generated unique ID                 |
| `user_id`            | relation(users) | ✓        | User who created the post                |
| `caption`            | text            | ✗        | Post caption (max 2000 chars)            |
| `image`              | file            | ✓        | Post image (max 1MB, JPEG/PNG/WebP)      |
| `image_width`        | number          | ✗        | Image width in pixels                    |
| `image_height`       | number          | ✗        | Image height in pixels                   |
| `hashtags`           | json            | ✗        | Array of hashtags extracted from caption |
| `mentions`           | json            | ✗        | Array of mentioned user IDs from caption |
| `likes_count`        | number          | ✗        | Cached count of reactions (default: 0)   |
| `comments_count`     | number          | ✗        | Cached count of comments (default: 0)    |
| `is_active`          | bool            | ✗        | Soft delete flag (default: true)         |
| `is_hidden_by_admin` | bool            | ✗        | Admin hide flag (default: false)         |
| `created`            | auto            | ✓        | Creation timestamp                       |
| `updated`            | auto            | ✓        | Last update timestamp                    |

### Indexes

- `idx_posts_user` - Index on `user_id` for fast user post queries
- `idx_posts_created` - Index on `created` for chronological sorting
- `idx_posts_active` - Composite index on `is_active, is_hidden_by_admin` for visibility queries

### API Rules

- **List/View**: Authenticated users can see active, non-hidden posts
  - `@request.auth.id != '' && is_active = true && is_hidden_by_admin = false`
- **Create**: Authenticated users can create posts for themselves
  - `@request.auth.id != '' && @request.auth.id = user_id`
- **Update**: Post owner can update their own posts
  - `@request.auth.id = user_id`
- **Delete**: Post owner or admins can delete posts
  - `@request.auth.id = user_id || (@request.auth.membership_type = 1 || @request.auth.membership_type = 2)`

---

## Collection: `post_reactions`

Stores user reactions to posts (like, love, wow, haha, sad, angry).

### Fields

| Field           | Type            | Required | Description                                          |
| --------------- | --------------- | -------- | ---------------------------------------------------- |
| `id`            | auto            | ✓        | Auto-generated unique ID                             |
| `post_id`       | relation(posts) | ✓        | Post being reacted to (cascade delete)               |
| `user_id`       | relation(users) | ✓        | User who reacted                                     |
| `reaction_type` | select          | ✓        | Type of reaction (like, love, wow, haha, sad, angry) |
| `created`       | auto            | ✓        | Creation timestamp                                   |

### Indexes

- `idx_post_reactions_unique` - UNIQUE index on `(post_id, user_id)` - one reaction per user per post
- `idx_post_reactions_post` - Index on `post_id` for fast post reaction queries
- `idx_post_reactions_user` - Index on `user_id` for user reaction history

### API Rules

- **List/View**: All authenticated users can see reactions
  - `@request.auth.id != ''`
- **Create**: Authenticated users can react to posts
  - `@request.auth.id != '' && @request.auth.id = user_id`
- **Update**: Users can update their own reactions
  - `@request.auth.id = user_id`
- **Delete**: Users can remove their own reactions
  - `@request.auth.id = user_id`

---

## Collection: `post_comments`

Stores comments on posts with mention and hashtag support.

### Fields

| Field                | Type            | Required | Description                              |
| -------------------- | --------------- | -------- | ---------------------------------------- |
| `id`                 | auto            | ✓        | Auto-generated unique ID                 |
| `post_id`            | relation(posts) | ✓        | Post being commented on (cascade delete) |
| `user_id`            | relation(users) | ✓        | User who commented                       |
| `comment_text`       | text            | ✓        | Comment content (1-500 chars)            |
| `mentions`           | json            | ✗        | Array of mentioned user IDs              |
| `hashtags`           | json            | ✗        | Array of hashtags                        |
| `is_active`          | bool            | ✗        | Soft delete flag (default: true)         |
| `is_hidden_by_admin` | bool            | ✗        | Admin hide flag (default: false)         |
| `created`            | auto            | ✓        | Creation timestamp                       |
| `updated`            | auto            | ✓        | Last update timestamp                    |

### Indexes

- `idx_post_comments_post` - Index on `post_id` for fast post comment queries
- `idx_post_comments_user` - Index on `user_id` for user comment history
- `idx_post_comments_active` - Composite index on `is_active, is_hidden_by_admin` for visibility

### API Rules

- **List/View**: Authenticated users can see active, non-hidden comments
  - `@request.auth.id != '' && is_active = true && is_hidden_by_admin = false`
- **Create**: Authenticated users can comment
  - `@request.auth.id != '' && @request.auth.id = user_id`
- **Update**: Comment owner can update their own comments (within 5 minutes)
  - `@request.auth.id = user_id`
- **Delete**: Comment owner or admins can delete comments
  - `@request.auth.id = user_id || (@request.auth.membership_type = 1 || @request.auth.membership_type = 2)`

---

## Collection: `post_reports`

Stores user reports of inappropriate content.

### Fields

| Field            | Type                    | Required | Description                                     |
| ---------------- | ----------------------- | -------- | ----------------------------------------------- |
| `id`             | auto                    | ✓        | Auto-generated unique ID                        |
| `post_id`        | relation(posts)         | ✗        | Reported post (optional, cascade delete)        |
| `comment_id`     | relation(post_comments) | ✗        | Reported comment (optional, cascade delete)     |
| `reported_by`    | relation(users)         | ✓        | User who reported                               |
| `report_reason`  | select                  | ✓        | Reason (spam, inappropriate, harassment, other) |
| `report_details` | text                    | ✗        | Additional details (max 500 chars)              |
| `status`         | select                  | ✓        | Status (pending, reviewed, resolved, dismissed) |
| `reviewed_by`    | relation(users)         | ✗        | Admin who reviewed                              |
| `reviewed_at`    | date                    | ✗        | Review timestamp                                |
| `admin_notes`    | text                    | ✗        | Admin notes (max 1000 chars)                    |
| `created`        | auto                    | ✓        | Creation timestamp                              |

### Indexes

- `idx_post_reports_status` - Index on `status` for filtering by status
- `idx_post_reports_reporter` - Index on `reported_by` for user report history

### API Rules

- **List/View**: Admins only
  - `@request.auth.membership_type = 1 || @request.auth.membership_type = 2`
- **Create**: Authenticated users can submit reports
  - `@request.auth.id != '' && @request.auth.id = reported_by`
- **Update**: Admins only (for reviewing reports)
  - `@request.auth.membership_type = 1 || @request.auth.membership_type = 2`
- **Delete**: Admins only
  - `@request.auth.membership_type = 1 || @request.auth.membership_type = 2`

---

## Collection: `user_bans`

Stores admin bans for users who violate community guidelines.

### Fields

| Field            | Type            | Required | Description                                     |
| ---------------- | --------------- | -------- | ----------------------------------------------- |
| `id`             | auto            | ✓        | Auto-generated unique ID                        |
| `user_id`        | relation(users) | ✓        | User being banned                               |
| `banned_by`      | relation(users) | ✓        | Admin who issued the ban                        |
| `ban_reason`     | text            | ✓        | Reason for ban (1-500 chars)                    |
| `ban_type`       | select          | ✓        | Type of ban (post, comment, all)                |
| `is_permanent`   | bool            | ✗        | Whether ban is permanent (default: false)       |
| `ban_expires_at` | date            | ✗        | Ban expiration date (for temporary bans)        |
| `is_active`      | bool            | ✗        | Whether ban is currently active (default: true) |
| `created`        | auto            | ✓        | Creation timestamp                              |

### Indexes

- `idx_user_bans_user` - Index on `user_id` for fast user ban checks
- `idx_user_bans_active` - Index on `is_active` for filtering active bans
- `idx_user_bans_type` - Index on `ban_type` for ban type queries

### API Rules

- **List/View**: Admins only
  - `@request.auth.membership_type = 1 || @request.auth.membership_type = 2`
- **Create**: Admins only
  - `@request.auth.membership_type = 1 || @request.auth.membership_type = 2`
- **Update**: Admins only
  - `@request.auth.membership_type = 1 || @request.auth.membership_type = 2`
- **Delete**: Admins only
  - `@request.auth.membership_type = 1 || @request.auth.membership_type = 2`

---

## Importing Collections

To import these collections into PocketBase:

1. Navigate to your PocketBase admin panel (e.g., `https://pb.lexserver.org/_/`)
2. Go to **Settings** → **Import collections**
3. Upload `pocketbase/social_feed_collections_schema.json`
4. Click **Import** to create all collections

**Note**: Make sure to back up your existing PocketBase data before importing.

---

## Data Relationships

```
users (existing)
  ↓
  ├── posts.user_id (one-to-many)
  │     ↓
  │     ├── post_reactions.post_id (one-to-many)
  │     │     ↓
  │     │     └── post_reactions.user_id → users
  │     │
  │     ├── post_comments.post_id (one-to-many)
  │     │     ↓
  │     │     └── post_comments.user_id → users
  │     │
  │     └── post_reports.post_id (one-to-many)
  │
  ├── post_comments.user_id (one-to-many)
  │     ↓
  │     └── post_reports.comment_id (one-to-many)
  │
  ├── post_reports.reported_by (one-to-many)
  ├── post_reports.reviewed_by (one-to-many)
  │
  └── user_bans.user_id (one-to-many)
        ↓
        └── user_bans.banned_by → users
```

---

## Performance Considerations

1. **Denormalized Counts**: `likes_count` and `comments_count` are cached on posts to avoid expensive COUNT queries
2. **Indexes**: All foreign keys and frequently queried fields are indexed
3. **Cascade Deletes**: Reactions and comments cascade delete when posts are deleted
4. **Soft Deletes**: Use `is_active` flag instead of hard deletes for better data integrity
5. **Pagination**: Always paginate post and comment queries (recommended: 20 items per page)

---

## Security Notes

1. **Admin Checks**: Admin permissions check `membership_type = 1 || membership_type = 2`
2. **Ban Enforcement**: Application must check `user_bans` before allowing post/comment creation
3. **Rate Limiting**: Configure PocketBase rate limiting to prevent spam
4. **File Validation**: Images are limited to 1MB and specific MIME types (JPEG, PNG, WebP)
5. **Content Validation**: Text fields have max length constraints to prevent abuse

---

## Migration Steps

If you have existing data to migrate:

1. Create collections first (without data)
2. Test permissions with sample data
3. Migrate existing data using PocketBase API or scripts
4. Verify indexes are created correctly
5. Test all CRUD operations
6. Enable in production

For new installations, simply import the schema JSON file.
