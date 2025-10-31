import 'package:pocketbase/pocketbase.dart';

/// Enum for different reaction types
enum ReactionType {
  like('like', '👍'),
  love('love', '❤️'),
  wow('wow', '😮'),
  haha('haha', '😂'),
  sad('sad', '😢'),
  angry('angry', '😠');

  const ReactionType(this.value, this.emoji);

  final String value;
  final String emoji;

  /// Get ReactionType from string value
  static ReactionType fromValue(String value) {
    return ReactionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ReactionType.like,
    );
  }

  /// Display name for the reaction
  String get displayName {
    switch (this) {
      case ReactionType.like:
        return 'Like';
      case ReactionType.love:
        return 'Love';
      case ReactionType.wow:
        return 'Wow';
      case ReactionType.haha:
        return 'Haha';
      case ReactionType.sad:
        return 'Sad';
      case ReactionType.angry:
        return 'Angry';
    }
  }
}

/// Represents a user's reaction to a post
class PostReaction {
  const PostReaction({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.reactionType,
    required this.createdAt,
  });

  /// Factory constructor to create a PostReaction from PocketBase RecordModel
  factory PostReaction.fromRecord(RecordModel record) {
    final data = record.data;

    // Extract user info from expanded relation
    var userName = 'Unknown User';

    try {
      final userRecord = record.get<RecordModel?>('expand.user_id');
      if (userRecord != null) {
        final firstName = userRecord.data['firstName'] as String? ?? '';
        final lastName = userRecord.data['lastName'] as String? ?? '';
        userName = '$firstName $lastName'.trim();
      }
    } catch (e) {
      // Expand not available, use default values
    }

    final reactionTypeValue = data['reaction_type'] as String? ?? 'like';

    return PostReaction(
      id: record.id,
      postId: data['post_id'] as String? ?? '',
      userId: data['user_id'] as String? ?? '',
      userName: userName,
      reactionType: ReactionType.fromValue(reactionTypeValue),
      createdAt: DateTime.parse(record.get<String>('created')),
    );
  }

  final String id;
  final String postId;
  final String userId;
  final String userName;
  final ReactionType reactionType;
  final DateTime createdAt;

  /// Copy with method for creating modified copies
  PostReaction copyWith({
    String? id,
    String? postId,
    String? userId,
    String? userName,
    ReactionType? reactionType,
    DateTime? createdAt,
  }) {
    return PostReaction(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      reactionType: reactionType ?? this.reactionType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PostReaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PostReaction(id: $id, postId: $postId, userId: $userId, reactionType: ${reactionType.value})';
  }
}
