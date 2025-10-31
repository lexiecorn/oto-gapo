import 'package:pocketbase/pocketbase.dart';

/// Represents a comment on a post
class PostComment {
  const PostComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.commentText, required this.mentions, required this.hashtags, required this.isActive, required this.isHiddenByAdmin, required this.createdAt, required this.updatedAt, this.userProfileImage,
  });

  /// Factory constructor to create a PostComment from PocketBase RecordModel
  factory PostComment.fromRecord(RecordModel record) {
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
    }

    // Parse mentions and hashtags from JSON
    var mentions = <String>[];
    if (data['mentions'] != null) {
      if (data['mentions'] is List) {
        mentions = (data['mentions'] as List).map((e) => e.toString()).toList();
      }
    }

    var hashtags = <String>[];
    if (data['hashtags'] != null) {
      if (data['hashtags'] is List) {
        hashtags = (data['hashtags'] as List).map((e) => e.toString()).toList();
      }
    }

    return PostComment(
      id: record.id,
      postId: data['post_id'] as String? ?? '',
      userId: data['user_id'] as String? ?? '',
      userName: userName,
      userProfileImage: userProfileImage,
      commentText: data['comment_text'] as String? ?? '',
      mentions: mentions,
      hashtags: hashtags,
      isActive: data['is_active'] as bool? ?? true,
      isHiddenByAdmin: data['is_hidden_by_admin'] as bool? ?? false,
      createdAt: DateTime.parse(record.get<String>('created')),
      updatedAt: DateTime.parse(record.get<String>('updated')),
    );
  }

  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String? userProfileImage;
  final String commentText;
  final List<String> mentions;
  final List<String> hashtags;
  final bool isActive;
  final bool isHiddenByAdmin;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Whether the comment is visible to users
  bool get isVisible => isActive && !isHiddenByAdmin;

  /// Whether the comment can still be edited (within 5 minutes)
  bool get canEdit => DateTime.now().difference(createdAt).inMinutes <= 5;

  /// Copy with method for creating modified copies
  PostComment copyWith({
    String? id,
    String? postId,
    String? userId,
    String? userName,
    String? userProfileImage,
    String? commentText,
    List<String>? mentions,
    List<String>? hashtags,
    bool? isActive,
    bool? isHiddenByAdmin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostComment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      commentText: commentText ?? this.commentText,
      mentions: mentions ?? this.mentions,
      hashtags: hashtags ?? this.hashtags,
      isActive: isActive ?? this.isActive,
      isHiddenByAdmin: isHiddenByAdmin ?? this.isHiddenByAdmin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PostComment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PostComment(id: $id, postId: $postId, userId: $userId, commentText: $commentText)';
  }
}
