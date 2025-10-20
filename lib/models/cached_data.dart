import 'package:hive/hive.dart';

part 'cached_data.g.dart';

/// Base class for cached data with sync metadata
abstract class CachedData {
  DateTime get cachedAt;
  bool get needsSync;
  String get syncId;
}

/// Cached post data for offline support
@HiveType(typeId: 0)
class CachedPost extends HiveObject implements CachedData {
  CachedPost({
    required this.id,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    required this.cachedAt,
    this.imageUrls = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    this.needsSync = false,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final String authorId;

  @HiveField(3)
  final String authorName;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  @override
  final DateTime cachedAt;

  @HiveField(6)
  final List<String> imageUrls;

  @HiveField(7)
  final int likesCount;

  @HiveField(8)
  final int commentsCount;

  @HiveField(9)
  @override
  final bool needsSync;

  @override
  String get syncId => id;
}

/// Cached meeting data for offline support
@HiveType(typeId: 1)
class CachedMeeting extends HiveObject implements CachedData {
  CachedMeeting({
    required this.id,
    required this.title,
    required this.meetingDate,
    required this.location,
    required this.status,
    required this.cachedAt,
    this.description,
    this.presentCount = 0,
    this.absentCount = 0,
    this.needsSync = false,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime meetingDate;

  @HiveField(3)
  final String location;

  @HiveField(4)
  final String status;

  @HiveField(5)
  final String? description;

  @HiveField(6)
  final int presentCount;

  @HiveField(7)
  final int absentCount;

  @HiveField(8)
  @override
  final DateTime cachedAt;

  @HiveField(9)
  @override
  final bool needsSync;

  @override
  String get syncId => id;
}

/// Cached user profile for offline support
@HiveType(typeId: 2)
class CachedUserProfile extends HiveObject implements CachedData {
  CachedUserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.cachedAt,
    this.memberNumber,
    this.profileImage,
    this.membershipType = 3,
    this.needsSync = false,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String firstName;

  @HiveField(2)
  final String lastName;

  @HiveField(3)
  final String email;

  @HiveField(4)
  final String? memberNumber;

  @HiveField(5)
  final String? profileImage;

  @HiveField(6)
  final int membershipType;

  @HiveField(7)
  @override
  final DateTime cachedAt;

  @HiveField(8)
  @override
  final bool needsSync;

  @override
  String get syncId => id;

  String get fullName => '$firstName $lastName';
}

/// Offline action to be synced later
@HiveType(typeId: 3)
class OfflineAction extends HiveObject {
  OfflineAction({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
    this.attempts = 0,
    this.lastAttempt,
    this.error,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final OfflineActionType type;

  @HiveField(2)
  final Map<String, dynamic> data;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  int attempts;

  @HiveField(5)
  DateTime? lastAttempt;

  @HiveField(6)
  String? error;

  /// Maximum number of retry attempts
  static const maxAttempts = 3;

  /// Check if action should be retried
  bool get shouldRetry => attempts < maxAttempts;

  /// Check if action has failed permanently
  bool get hasFailed => attempts >= maxAttempts;
}

/// Types of offline actions
@HiveType(typeId: 4)
enum OfflineActionType {
  @HiveField(0)
  createPost,

  @HiveField(1)
  updateProfile,

  @HiveField(2)
  markAttendance,

  @HiveField(3)
  addReaction,

  @HiveField(4)
  addComment,

  @HiveField(5)
  deletePost,

  @HiveField(6)
  updatePost,
}
