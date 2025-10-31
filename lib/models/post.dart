import 'package:pocketbase/pocketbase.dart';

/// Represents a social feed post
class Post {
  const Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.imageUrl, required this.imageWidth, required this.imageHeight, required this.hashtags, required this.mentions, required this.likesCount, required this.commentsCount, required this.isActive, required this.isHiddenByAdmin, required this.createdAt, required this.updatedAt, this.userProfileImage,
    this.caption,
  });

  /// Factory constructor to create a Post from PocketBase RecordModel
  factory Post.fromRecord(RecordModel record) {
    final data = record.data;

    // Extract user info from expanded relation
    var userName = 'Unknown User';
    String? userProfileImage;

    try {
      final userRecord = record.get<RecordModel?>('expand.user_id');
      if (userRecord != null) {
        final firstName = userRecord.data['firstName'] as String? ?? '';
        final lastName = userRecord.data['lastName'] as String? ?? '';
        userName = '$firstName $lastName'.trim();
        if (userName.isEmpty) {
          userName = 'Unknown User';
        }
        userProfileImage = userRecord.data['profileImage'] as String?;
      }
    } catch (e) {
      // Expand not available, use default values
      print('Post.fromRecord - Error getting expanded user: $e');
    }

    // Parse hashtags and mentions from JSON
    var hashtags = <String>[];
    if (data['hashtags'] != null) {
      if (data['hashtags'] is List) {
        hashtags = (data['hashtags'] as List).map((e) => e.toString()).toList();
      }
    }

    var mentions = <String>[];
    if (data['mentions'] != null) {
      if (data['mentions'] is List) {
        mentions = (data['mentions'] as List).map((e) => e.toString()).toList();
      }
    }

    return Post(
      id: record.id,
      userId: data['user_id'] as String? ?? '',
      userName: userName,
      userProfileImage: userProfileImage,
      caption: data['caption'] as String?,
      imageUrl: data['image'] as String? ?? '',
      imageWidth: (data['image_width'] as num?)?.toInt() ?? 0,
      imageHeight: (data['image_height'] as num?)?.toInt() ?? 0,
      hashtags: hashtags,
      mentions: mentions,
      likesCount: (data['likes_count'] as num?)?.toInt() ?? 0,
      commentsCount: (data['comments_count'] as num?)?.toInt() ?? 0,
      isActive: data['is_active'] as bool? ?? true,
      isHiddenByAdmin: data['is_hidden_by_admin'] as bool? ?? false,
      createdAt: DateTime.parse(record.get<String>('created')),
      updatedAt: DateTime.parse(record.get<String>('updated')),
    );
  }

  final String id;
  final String userId;
  final String userName;
  final String? userProfileImage;
  final String? caption;
  final String imageUrl;
  final int imageWidth;
  final int imageHeight;
  final List<String> hashtags;
  final List<String> mentions;
  final int likesCount;
  final int commentsCount;
  final bool isActive;
  final bool isHiddenByAdmin;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Whether the post is visible to users
  bool get isVisible => isActive && !isHiddenByAdmin;

  /// Copy with method for creating modified copies
  Post copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userProfileImage,
    String? caption,
    String? imageUrl,
    int? imageWidth,
    int? imageHeight,
    List<String>? hashtags,
    List<String>? mentions,
    int? likesCount,
    int? commentsCount,
    bool? isActive,
    bool? isHiddenByAdmin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      caption: caption ?? this.caption,
      imageUrl: imageUrl ?? this.imageUrl,
      imageWidth: imageWidth ?? this.imageWidth,
      imageHeight: imageHeight ?? this.imageHeight,
      hashtags: hashtags ?? this.hashtags,
      mentions: mentions ?? this.mentions,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isActive: isActive ?? this.isActive,
      isHiddenByAdmin: isHiddenByAdmin ?? this.isHiddenByAdmin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Post && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Post(id: $id, userId: $userId, userName: $userName, caption: $caption, likesCount: $likesCount, commentsCount: $commentsCount)';
  }
}
