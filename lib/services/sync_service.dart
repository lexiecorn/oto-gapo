import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:otogapo/models/cached_data.dart';
import 'package:otogapo/services/connectivity_service.dart';
import 'package:otogapo/services/pocketbase_service.dart';
import 'package:uuid/uuid.dart';

/// Service for managing offline data synchronization.
///
/// Queues actions when offline and syncs them when connectivity is restored.
/// Uses Hive for persistent storage of pending actions.
///
/// Example:
/// ```dart
/// final syncService = SyncService();
/// await syncService.queueAction(
///   type: OfflineActionType.createPost,
///   data: {'content': 'Hello offline!'},
/// );
/// ```
class SyncService {
  factory SyncService() => _instance;
  SyncService._internal();
  static final SyncService _instance = SyncService._internal();

  final ConnectivityService _connectivityService = ConnectivityService();
  final PocketBaseService _pocketBaseService = PocketBaseService();
  final Uuid _uuid = const Uuid();

  Box<OfflineAction>? _actionsBox;
  Box<CachedPost>? _postsBox;
  Box<CachedMeeting>? _meetingsBox;
  Box<CachedUserProfile>? _profilesBox;
  Box<CachedAnnouncement>? _announcementsBox;
  Box<dynamic>? _cacheMetadataBox;

  final StreamController<SyncStatus> _syncStatusController = StreamController<SyncStatus>.broadcast();
  StreamSubscription<ConnectivityStatus>? _connectivitySubscription;

  bool _isSyncing = false;
  SyncStatus _currentStatus = SyncStatus.idle;

  // Cache TTL constants
  static const Duration postsCacheTTL = Duration(minutes: 5);
  static const Duration meetingsCacheTTL = Duration(minutes: 15);
  static const Duration profilesCacheTTL = Duration(minutes: 30);
  static const Duration announcementsCacheTTL = Duration(minutes: 10);

  // Cache timestamp tracking
  DateTime? _postsLastCached;
  DateTime? _meetingsLastCached;
  DateTime? _profilesLastCached;
  DateTime? _announcementsLastCached;

  /// Stream of sync status changes
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  /// Current sync status
  SyncStatus get currentStatus => _currentStatus;

  /// Number of pending actions
  int get pendingActionsCount => _actionsBox?.length ?? 0;

  /// Check if currently syncing
  bool get isSyncing => _isSyncing;

  /// Initialize the sync service
  Future<void> init() async {
    // Open Hive boxes
    _actionsBox = await Hive.openBox<OfflineAction>('offline_actions');
    _postsBox = await Hive.openBox<CachedPost>('cached_posts');
    _meetingsBox = await Hive.openBox<CachedMeeting>('cached_meetings');
    _profilesBox = await Hive.openBox<CachedUserProfile>('cached_profiles');
    _announcementsBox = await Hive.openBox<CachedAnnouncement>('cached_announcements');
    _cacheMetadataBox = await Hive.openBox<dynamic>('cache_metadata');

    // Load cached timestamps
    _loadCacheTimestamps();

    // Listen to connectivity changes
    _connectivitySubscription = _connectivityService.connectivityStream.listen(_onConnectivityChanged);

    // Sync if already online
    if (_connectivityService.isOnline && pendingActionsCount > 0) {
      await syncPendingActions();
    }
  }

  /// Load cache timestamps from persistent storage
  void _loadCacheTimestamps() {
    try {
      final postsTimeStr = _cacheMetadataBox?.get('posts_cache_time') as String?;
      if (postsTimeStr != null) {
        _postsLastCached = DateTime.tryParse(postsTimeStr);
      }

      final meetingsTimeStr = _cacheMetadataBox?.get('meetings_cache_time') as String?;
      if (meetingsTimeStr != null) {
        _meetingsLastCached = DateTime.tryParse(meetingsTimeStr);
      }

      final profilesTimeStr = _cacheMetadataBox?.get('profiles_cache_time') as String?;
      if (profilesTimeStr != null) {
        _profilesLastCached = DateTime.tryParse(profilesTimeStr);
      }

      final announcementsTimeStr = _cacheMetadataBox?.get('announcements_cache_time') as String?;
      if (announcementsTimeStr != null) {
        _announcementsLastCached = DateTime.tryParse(announcementsTimeStr);
      }
    } catch (e) {
      print('SyncService - Error loading cache timestamps: $e');
    }
  }

  /// Check if cache is valid based on TTL
  bool isCacheValid(DateTime? lastCached, Duration ttl) {
    if (lastCached == null) return false;
    return DateTime.now().difference(lastCached) < ttl;
  }

  void _onConnectivityChanged(ConnectivityStatus status) {
    if (status == ConnectivityStatus.online && pendingActionsCount > 0) {
      syncPendingActions();
    }
  }

  /// Queue an action to be synced later
  Future<String> queueAction({
    required OfflineActionType type,
    required Map<String, dynamic> data,
  }) async {
    final action = OfflineAction(
      id: _uuid.v4(),
      type: type,
      data: data,
      createdAt: DateTime.now(),
    );

    await _actionsBox?.add(action);
    _updateStatus(SyncStatus.pending);

    print(
      'SyncService - Action queued: ${action.type}, pending: $pendingActionsCount',
    );

    // Try to sync immediately if online
    if (_connectivityService.isOnline) {
      syncPendingActions();
    }

    return action.id;
  }

  /// Sync all pending actions
  Future<void> syncPendingActions() async {
    if (_isSyncing || !_connectivityService.isOnline) {
      return;
    }

    if (pendingActionsCount == 0) {
      _updateStatus(SyncStatus.idle);
      return;
    }

    _isSyncing = true;
    _updateStatus(SyncStatus.syncing);

    print('SyncService - Starting sync of $pendingActionsCount actions');

    final actions = _actionsBox?.values.toList() ?? [];
    final successfulActions = <int>[];

    for (var i = 0; i < actions.length; i++) {
      final action = actions[i];

      try {
        await _processAction(action);
        successfulActions.add(i);
        print('SyncService - Action synced successfully: ${action.type}');
      } catch (e) {
        action.attempts++;
        action.lastAttempt = DateTime.now();
        action.error = e.toString();
        await action.save();

        print(
          'SyncService - Action sync failed (attempt ${action.attempts}): ${action.type}, error: $e',
        );

        if (action.hasFailed) {
          print(
            'SyncService - Action permanently failed after ${action.attempts} attempts: ${action.type}',
          );
          // Remove failed action
          successfulActions.add(i);
        }
      }
    }

    // Remove successful/failed actions
    for (final index in successfulActions.reversed) {
      await _actionsBox?.deleteAt(index);
    }

    _isSyncing = false;

    if (pendingActionsCount == 0) {
      _updateStatus(SyncStatus.synced);
      print('SyncService - All actions synced successfully');
    } else {
      _updateStatus(SyncStatus.pending);
      print(
        'SyncService - Sync complete, $pendingActionsCount actions remaining',
      );
    }
  }

  Future<void> _processAction(OfflineAction action) async {
    switch (action.type) {
      case OfflineActionType.createPost:
        await _pocketBaseService.createPost(
          userId: action.data['userId'] as String,
          caption: action.data['content'] as String?,
          imageWidth: action.data['imageWidth'] as int? ?? 0,
          imageHeight: action.data['imageHeight'] as int? ?? 0,
          hashtags: (action.data['hashtags'] as List?)?.cast<String>() ?? [],
          mentions: (action.data['mentions'] as List?)?.cast<String>() ?? [],
        );

      case OfflineActionType.updateProfile:
        await _pocketBaseService.updateUser(
          action.data['userId'] as String,
          action.data,
        );

      case OfflineActionType.markAttendance:
        // Handle attendance marking
        // Will be implemented with attendance repository integration
        break;

      case OfflineActionType.addReaction:
        await _pocketBaseService.addReaction(
          postId: action.data['postId'] as String,
          userId: action.data['userId'] as String,
          reactionType: action.data['reactionType'] as String,
        );

      case OfflineActionType.addComment:
        await _pocketBaseService.addComment(
          postId: action.data['postId'] as String,
          userId: action.data['userId'] as String,
          commentText: action.data['content'] as String,
          mentions: (action.data['mentions'] as List?)?.cast<String>() ?? [],
          hashtags: (action.data['hashtags'] as List?)?.cast<String>() ?? [],
        );

      case OfflineActionType.deletePost:
        await _pocketBaseService.deletePost(action.data['postId'] as String);

      case OfflineActionType.updatePost:
        await _pocketBaseService.updatePost(
          postId: action.data['postId'] as String,
          caption: action.data['content'] as String,
        );
    }
  }

  /// Cache posts for offline viewing
  Future<void> cachePosts(List<CachedPost> posts) async {
    await _postsBox?.clear();
    for (final post in posts) {
      await _postsBox?.add(post);
    }
    _postsLastCached = DateTime.now();
    // Store timestamp in Hive for persistence
    await _cacheMetadataBox?.put('posts_cache_time', _postsLastCached!.toIso8601String());
    print('SyncService - Cached ${posts.length} posts');
  }

  /// Get cached posts
  List<CachedPost> getCachedPosts() {
    return _postsBox?.values.toList() ?? [];
  }

  /// Get cached posts if valid (within TTL)
  Future<List<CachedPost>?> getCachedPostsIfValid() async {
    if (!isCacheValid(_postsLastCached, postsCacheTTL)) {
      print('SyncService - Posts cache expired or invalid');
      return null;
    }
    print('SyncService - Returning valid cached posts');
    return getCachedPosts();
  }

  /// Cache meetings for offline viewing
  Future<void> cacheMeetings(List<CachedMeeting> meetings) async {
    await _meetingsBox?.clear();
    for (final meeting in meetings) {
      await _meetingsBox?.add(meeting);
    }
    _meetingsLastCached = DateTime.now();
    // Store timestamp in Hive for persistence
    await _cacheMetadataBox?.put('meetings_cache_time', _meetingsLastCached!.toIso8601String());
    print('SyncService - Cached ${meetings.length} meetings');
  }

  /// Get cached meetings
  List<CachedMeeting> getCachedMeetings() {
    return _meetingsBox?.values.toList() ?? [];
  }

  /// Get cached meetings if valid (within TTL)
  Future<List<CachedMeeting>?> getCachedMeetingsIfValid() async {
    if (!isCacheValid(_meetingsLastCached, meetingsCacheTTL)) {
      print('SyncService - Meetings cache expired or invalid');
      return null;
    }
    print('SyncService - Returning valid cached meetings');
    return getCachedMeetings();
  }

  /// Cache user profile for offline viewing
  Future<void> cacheUserProfile(CachedUserProfile profile) async {
    await _profilesBox?.clear();
    await _profilesBox?.add(profile);
    _profilesLastCached = DateTime.now();
    // Store timestamp in Hive for persistence
    await _cacheMetadataBox?.put('profiles_cache_time', _profilesLastCached!.toIso8601String());
    print('SyncService - Cached user profile: ${profile.fullName}');
  }

  /// Get cached user profile
  CachedUserProfile? getCachedUserProfile() {
    final profiles = _profilesBox?.values.toList() ?? [];
    return profiles.isNotEmpty ? profiles.first : null;
  }

  /// Get cached user profile if valid (within TTL)
  Future<CachedUserProfile?> getCachedUserProfileIfValid() async {
    if (!isCacheValid(_profilesLastCached, profilesCacheTTL)) {
      print('SyncService - Profile cache expired or invalid');
      return null;
    }
    print('SyncService - Returning valid cached profile');
    return getCachedUserProfile();
  }

  /// Cache announcements for offline viewing
  Future<void> cacheAnnouncements(List<CachedAnnouncement> announcements) async {
    await _announcementsBox?.clear();
    for (final announcement in announcements) {
      await _announcementsBox?.add(announcement);
    }
    _announcementsLastCached = DateTime.now();
    // Store timestamp in Hive for persistence
    await _cacheMetadataBox?.put('announcements_cache_time', _announcementsLastCached!.toIso8601String());
    print('SyncService - Cached ${announcements.length} announcements');
  }

  /// Get cached announcements
  List<CachedAnnouncement> getCachedAnnouncements() {
    return _announcementsBox?.values.toList() ?? [];
  }

  /// Get cached announcements if valid (within TTL)
  Future<List<CachedAnnouncement>?> getCachedAnnouncementsIfValid() async {
    if (!isCacheValid(_announcementsLastCached, announcementsCacheTTL)) {
      print('SyncService - Announcements cache expired or invalid');
      return null;
    }
    print('SyncService - Returning valid cached announcements');
    return getCachedAnnouncements();
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    await _postsBox?.clear();
    await _meetingsBox?.clear();
    await _profilesBox?.clear();
    await _announcementsBox?.clear();
    print('SyncService - Cache cleared');
  }

  /// Clear all pending actions
  Future<void> clearPendingActions() async {
    await _actionsBox?.clear();
    _updateStatus(SyncStatus.idle);
    print('SyncService - Pending actions cleared');
  }

  void _updateStatus(SyncStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      _syncStatusController.add(status);
    }
  }

  /// Dispose of resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncStatusController.close();
  }
}

/// Enum representing sync status
enum SyncStatus {
  /// No pending actions
  idle,

  /// Actions pending sync
  pending,

  /// Currently syncing
  syncing,

  /// All actions synced
  synced,

  /// Sync failed
  error,
}
