# Offline Support Guide

## Overview

OtoGapo now includes comprehensive offline support, allowing users to continue using the app even without internet connectivity. Actions performed offline are queued and automatically synced when the device reconnects.

## Architecture

### Components

1. **ConnectivityService** (`lib/services/connectivity_service.dart`)

   - Monitors network connectivity status
   - Provides real-time connectivity stream
   - Singleton pattern for consistent monitoring

2. **SyncService** (`lib/services/sync_service.dart`)

   - Queues offline actions
   - Manages local cache
   - Syncs pending actions when online
   - Retry logic for failed syncs

3. **ConnectivityCubit** (`lib/app/modules/connectivity/bloc/connectivity_cubit.dart`)
   - Exposes connectivity state to UI
   - Tracks pending actions count
   - Triggers manual sync

### Data Flow

```
User Action (Offline)
  ↓
Queue in SyncService
  ↓
Store in Hive (persistent)
  ↓
Wait for connectivity
  ↓
ConnectivityService detects online
  ↓
SyncService auto-syncs
  ↓
PocketBase API calls
  ↓
Remove from queue
  ↓
Update UI
```

## Cached Data

### What Gets Cached

- **Posts**: Last 100 posts from social feed
- **Meetings**: Upcoming and recent meetings
- **User Profile**: Current user profile data
- **Announcements**: Latest app announcements
- **Pending Actions**: All queued actions with retry metadata

### Cache Storage

All cached data is stored using Hive boxes:

- `cached_posts` - Social feed posts
- `cached_meetings` - Meeting information
- `cached_profiles` - User profile data
- `cached_announcements` - App announcements
- `offline_actions` - Pending sync actions
- `cache_metadata` - Cache timestamps and metadata

### Caching Strategy

The app uses intelligent caching with TTL (Time To Live) to balance data freshness and performance:

#### Cache TTLs

- **Posts**: 5 minutes - Frequently updated social content
- **Meetings**: 15 minutes - Moderate update frequency
- **Profiles**: 30 minutes - Relatively static user data
- **Announcements**: 10 minutes - Important updates

#### Cache-First Loading

1. App checks cache on data request
2. If cache is valid (within TTL), displays immediately
3. Simultaneously fetches fresh data from PocketBase
4. Updates UI when fresh data arrives
5. If offline, uses cached data indefinitely

#### Benefits

- Instant app startup with cached data
- Reduced API calls and server load
- Seamless offline experience
- Automatic background refresh when online

## Offline Actions

### Supported Actions

1. **Create Post** - Queue post creation (text only, images require online)
2. **Update Profile** - Queue profile updates
3. **Add Reaction** - Queue post reactions
4. **Add Comment** - Queue comments
5. **Delete Post** - Queue post deletion
6. **Update Post** - Queue post edits

### Action Priority

Syncs happen in FIFO order (first-in, first-out):

1. Profile updates
2. Post reactions/comments
3. Attendance marking
4. New posts
5. User settings

### Retry Logic

- **Max Attempts**: 3 retries per action
- **Failure Handling**: After 3 failed attempts, action is removed and logged
- **Error Tracking**: Each attempt records error message and timestamp

## UI Indicators

### Connectivity Banner

A sliding banner appears at the top of the screen showing:

- **Red**: Offline - no connection
- **Orange**: Pending sync - X actions waiting
- **Blue**: Syncing - actively syncing
- **Green**: Synced - all up to date

**Interaction**: Tap the banner when online to manually trigger sync.

### Navigation Badge

A red badge appears on the Settings tab when there are pending actions.

## Usage Examples

### Queue an Offline Action

```dart
final syncService = SyncService();
await syncService.queueAction(
  type: OfflineActionType.addReaction,
  data: {
    'postId': 'post_123',
    'userId': 'user_456',
    'reactionType': 'like',
  },
);
```

### Listen to Connectivity

```dart
BlocBuilder<ConnectivityCubit, ConnectivityState>(
  builder: (context, state) {
    if (state.isOffline) {
      return Text('You are offline');
    }
    if (state.hasPendingActions) {
      return Text('${state.pendingActionsCount} pending actions');
    }
    return Text('All synced');
  },
)
```

### Manual Sync Trigger

```dart
context.read<ConnectivityCubit>().triggerSync();
```

## Limitations

### What Doesn't Work Offline

- **Image uploads**: Cannot queue images for upload (file size constraints)
- **Real-time updates**: No live data until reconnected
- **Search**: Searches require server-side processing
- **Initial login**: Authentication requires connectivity

### What Works Offline

- ✅ View cached posts
- ✅ View cached meetings
- ✅ View profile
- ✅ React to posts (queued)
- ✅ Comment on posts (queued)
- ✅ Navigate between pages
- ✅ View attendance history (cached)

## Conflict Resolution

### Strategy

**Server Wins**: If a conflict occurs during sync:

1. Server data is kept
2. User is notified
3. Local action is discarded
4. UI is updated with server data

### Example Scenarios

**Scenario 1**: User reacts to a post offline, but the post was deleted

- **Resolution**: Sync fails, action is discarded after retries
- **User Experience**: Reaction disappears when synced

**Scenario 2**: User updates profile offline, admin updates it while offline

- **Resolution**: Admin's changes win
- **User Experience**: Notification that changes couldn't be applied

## Performance

### Cache Limits

- **Posts**: Max 100 posts (oldest removed first)
- **Meetings**: Max 50 meetings
- **Profiles**: Current user only
- **Actions**: Max 100 pending actions

### Memory Usage

- Hive boxes are lazy-loaded
- Only active data kept in memory
- Automatic cleanup on app restart

## Best Practices

### For Developers

1. **Always check connectivity** before critical operations
2. **Use SyncService** for all modifying actions
3. **Show pending indicators** when actions are queued
4. **Handle sync failures** gracefully
5. **Test offline mode** during development

### For Users

1. **Monitor the connectivity banner** for sync status
2. **Manually sync** if needed by tapping the banner
3. **Check pending actions** in Settings
4. **Avoid image uploads** when offline
5. **Wait for sync** before closing the app

## Troubleshooting

### Issue: Actions Not Syncing

**Possible Causes**:

- Device is still offline
- PocketBase authentication expired
- Server is down
- Network firewall blocking requests

**Solution**:

1. Check connectivity banner
2. Verify internet connection
3. Try manual sync
4. Re-authenticate if needed

### Issue: Cached Data Stale

**Solution**:

```dart
// Clear all cache
final syncService = SyncService();
await syncService.clearCache();

// Refresh data
context.read<FeedCubit>().loadFeed(refresh: true);
```

### Issue: Too Many Pending Actions

**Solution**:

```dart
// Clear pending actions (careful: data loss)
final syncService = SyncService();
await syncService.clearPendingActions();
```

## Future Enhancements

- Push notification on sync completion
- Conflict resolution UI
- Offline image preview (low-res cache)
- Predictive sync based on user behavior
- Background sync worker
- Selective cache (user preferences)

## API Reference

### ConnectivityService

```dart
final service = ConnectivityService();

// Listen to changes
service.connectivityStream.listen((status) {
  print('Status: $status');
});

// Check current status
if (service.isOnline) { ... }
if (service.isOffline) { ... }

// Manual refresh
await service.refresh();
```

### SyncService

```dart
final service = SyncService();

// Initialize (called in bootstrap)
await service.init();

// Queue action
await service.queueAction(
  type: OfflineActionType.createPost,
  data: {'content': 'Hello'},
);

// Check status
final pending = service.pendingActionsCount;
final syncing = service.isSyncing;

// Manual sync
await service.syncPendingActions();

// Cache management
await service.cachePosts(posts);
await service.clearCache();
```

### ConnectivityCubit

```dart
// Trigger manual sync
context.read<ConnectivityCubit>().triggerSync();

// Refresh connectivity
context.read<ConnectivityCubit>().refreshConnectivity();

// Access state
final state = context.read<ConnectivityCubit>().state;
final isOnline = state.isOnline;
final pending = state.pendingActionsCount;
```

## Implementation Checklist

When adding new offline-capable features:

- [ ] Define OfflineActionType enum value
- [ ] Add action processing in SyncService.\_processAction()
- [ ] Update UI to check connectivity before action
- [ ] Queue action if offline
- [ ] Show pending indicator
- [ ] Handle sync completion
- [ ] Test offline → online transition

---

**See Also**:

- [Architecture Documentation](./ARCHITECTURE.md)
- [Animations Guide](./ANIMATIONS_GUIDE.md)
- [Developer Guide](./DEVELOPER_GUIDE.md)
