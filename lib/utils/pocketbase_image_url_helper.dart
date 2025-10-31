import 'package:otogapo/services/pocketbase_service.dart';

/// Helper utilities for constructing PocketBase file URLs consistently.
class PocketBaseImageUrlHelper {
  PocketBaseImageUrlHelper._();

  static final PocketBaseService _pb = PocketBaseService();

  /// Builds a URL for a file stored under a specific collection and record.
  /// When [thumb] is provided, appends the PocketBase thumbnail query.
  static String buildCollectionFileUrl({
    required String collectionId,
    required String recordId,
    required String filename,
    String? thumb,
  }) {
    if (filename.isEmpty || collectionId.isEmpty || recordId.isEmpty) {
      return '';
    }
    final baseUrl = _pb.baseUrl;
    final thumbSuffix = (thumb != null && thumb.isNotEmpty) ? '?thumb=$thumb' : '';
    return '$baseUrl/api/files/$collectionId/$recordId/$filename$thumbSuffix';
  }

  /// Builds a URL for a user file stored in the `users` collection.
  static String buildUserFileUrl({
    required String userId,
    required String filename,
    String? thumb,
  }) {
    if (filename.isEmpty || userId.isEmpty) return '';
    final baseUrl = _pb.baseUrl;
    final thumbSuffix = (thumb != null && thumb.isNotEmpty) ? '?thumb=$thumb' : '';
    return '$baseUrl/api/files/users/$userId/$filename$thumbSuffix';
  }

  /// Builds a URL for a post image stored in the `posts` collection.
  static String buildPostFileUrl({
    required String postId,
    required String filename,
    String? thumb,
  }) {
    if (filename.isEmpty || postId.isEmpty) return '';
    final baseUrl = _pb.baseUrl;
    final thumbSuffix = (thumb != null && thumb.isNotEmpty) ? '?thumb=$thumb' : '';
    return '$baseUrl/api/files/posts/$postId/$filename$thumbSuffix';
  }

  /// If [value] is already a full URL (starts with http), returns it as-is.
  /// Otherwise constructs a user file URL using [userId].
  static String resolveUserImageUrlOrFull({
    required String value,
    required String userId,
    String? thumb,
  }) {
    if (value.startsWith('http')) return value;
    return buildUserFileUrl(userId: userId, filename: value, thumb: thumb);
  }
}


