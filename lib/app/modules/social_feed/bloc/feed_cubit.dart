import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:otogapo/models/cached_data.dart';
import 'package:otogapo/models/post.dart';
import 'package:otogapo/models/post_reaction.dart';
import 'package:otogapo/services/pocketbase_service.dart';
import 'package:otogapo/services/sync_service.dart';
import 'package:otogapo/utils/image_compression_utils.dart';
import 'package:otogapo/utils/text_parsing_utils.dart';

part 'feed_state.dart';

/// Cubit for managing social feed state
class FeedCubit extends Cubit<FeedState> {
  FeedCubit({
    required this.pocketBaseService,
    required this.currentUserId,
    required this.syncService,
  }) : super(const FeedState());

  final PocketBaseService pocketBaseService;
  final String currentUserId;
  final SyncService syncService;

  /// Load feed posts with pagination
  Future<void> loadFeed({
    int page = 1,
    bool refresh = false,
  }) async {
    try {
      // For first page, try loading from cache first
      if (page == 1 && !refresh) {
        final cachedPosts = await syncService.getCachedPostsIfValid();
        if (cachedPosts != null && cachedPosts.isNotEmpty) {
          // Emit cached data immediately for instant UI
          final posts = cachedPosts
              .map((cached) => Post(
                    id: cached.id,
                    userId: cached.authorId,
                    userName: cached.authorName,
                    caption: cached.content,
                    imageUrl: cached.imageUrls.isNotEmpty ? cached.imageUrls.first : '',
                    imageWidth: 0,
                    imageHeight: 0,
                    hashtags: const [],
                    mentions: const [],
                    likesCount: cached.likesCount,
                    commentsCount: cached.commentsCount,
                    isActive: true,
                    isHiddenByAdmin: false,
                    createdAt: cached.createdAt,
                    updatedAt: cached.createdAt,
                  ))
              .toList();

          emit(
            state.copyWith(
              status: FeedStatus.loaded,
              posts: posts,
              currentPage: 1,
              hasMore: false, // We don't know from cache
            ),
          );

          // Load user reactions for cached posts
          await _loadUserReactions(posts.map((p) => p.id).toList());
        }
      }

      if (refresh || page == 1) {
        emit(state.copyWith(status: FeedStatus.loading));
      } else {
        emit(state.copyWith(status: FeedStatus.loadingMore));
      }

      final result = await pocketBaseService.getPosts(
        page: page,
      );

      // Check if cubit is still open after async operation
      if (isClosed) return;

      final posts = result.items.map(Post.fromRecord).toList();

      // Cache the results if it's first page
      if (page == 1) {
        final cachedPosts = result.items.map((record) {
          final userRecord = record.expand['user_id']?[0];
          return CachedPost(
            id: record.id,
            content: record.data['caption'] as String? ?? '',
            authorId: record.data['user_id'] as String,
            authorName: userRecord?.data['firstName'] as String? ?? 'Unknown',
            createdAt: DateTime.parse(record.created),
            cachedAt: DateTime.now(),
            imageUrls: (record.data['image'] as String?)?.isNotEmpty == true ? [record.data['image'] as String] : [],
            likesCount: record.data['likes_count'] as int? ?? 0,
            commentsCount: record.data['comments_count'] as int? ?? 0,
          );
        }).toList();

        await syncService.cachePosts(cachedPosts);
      }

      if (refresh || page == 1) {
        emit(
          state.copyWith(
            status: FeedStatus.loaded,
            posts: posts,
            currentPage: page,
            hasMore: result.page < result.totalPages,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: FeedStatus.loaded,
            posts: [...state.posts, ...posts],
            currentPage: page,
            hasMore: result.page < result.totalPages,
          ),
        );
      }

      // Load user reactions for these posts
      await _loadUserReactions(posts.map((p) => p.id).toList());
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: FeedStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Load more posts (pagination)
  Future<void> loadMore() async {
    if (!state.hasMore || state.status == FeedStatus.loadingMore) {
      return;
    }

    await loadFeed(page: state.currentPage + 1);
  }

  /// Load posts for a specific user
  Future<void> loadUserPosts(String userId, {int page = 1}) async {
    try {
      if (page == 1) {
        emit(state.copyWith(status: FeedStatus.loading));
      } else {
        emit(state.copyWith(status: FeedStatus.loadingMore));
      }

      final result = await pocketBaseService.getUserPosts(
        userId: userId,
        page: page,
      );

      // Check if cubit is still open after async operation
      if (isClosed) return;

      final posts = result.items.map(Post.fromRecord).toList();

      if (page == 1) {
        emit(
          state.copyWith(
            status: FeedStatus.loaded,
            posts: posts,
            currentPage: page,
            hasMore: result.page < result.totalPages,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: FeedStatus.loaded,
            posts: [...state.posts, ...posts],
            currentPage: page,
            hasMore: result.page < result.totalPages,
          ),
        );
      }

      // Load user reactions
      await _loadUserReactions(posts.map((p) => p.id).toList());
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: FeedStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Load posts by hashtag
  Future<void> loadHashtagPosts(String hashtag, {int page = 1}) async {
    try {
      if (page == 1) {
        emit(state.copyWith(status: FeedStatus.loading));
      } else {
        emit(state.copyWith(status: FeedStatus.loadingMore));
      }

      // Create filter for hashtag
      final filter = 'hashtags ~ "$hashtag"';

      final result = await pocketBaseService.getPosts(
        page: page,
        filter: filter,
      );

      // Check if cubit is still open after async operation
      if (isClosed) return;

      final posts = result.items.map(Post.fromRecord).toList();

      if (page == 1) {
        emit(
          state.copyWith(
            status: FeedStatus.loaded,
            posts: posts,
            currentPage: page,
            hasMore: result.page < result.totalPages,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: FeedStatus.loaded,
            posts: [...state.posts, ...posts],
            currentPage: page,
            hasMore: result.page < result.totalPages,
          ),
        );
      }

      // Load user reactions
      await _loadUserReactions(posts.map((p) => p.id).toList());
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: FeedStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Create a new post
  Future<void> createPost(String caption, File? imageFile) async {
    try {
      // Check if user is banned
      final ban = await pocketBaseService.checkUserBan(currentUserId, banType: 'post');
      if (ban != null) {
        throw Exception('You are banned from creating posts');
      }

      // Check if cubit is still open after async operation
      if (isClosed) return;

      File? compressedImage;
      var imageWidth = 0;
      var imageHeight = 0;

      // Compress image if provided
      if (imageFile != null) {
        compressedImage = await ImageCompressionUtils.compressForSocialFeed(imageFile);
        final dimensions = await ImageCompressionUtils.getImageDimensions(compressedImage);
        imageWidth = dimensions['width']!;
        imageHeight = dimensions['height']!;
      }

      // Check if cubit is still open after async operation
      if (isClosed) return;

      // Extract mentions and hashtags
      final mentions = TextParsingUtils.extractMentions(caption);
      final hashtags = TextParsingUtils.extractHashtags(caption);

      // Create post
      final record = await pocketBaseService.createPost(
        userId: currentUserId,
        imageFile: compressedImage,
        caption: caption.isNotEmpty ? caption : null,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        hashtags: hashtags,
        mentions: mentions,
      );

      // Check if cubit is still open after async operation
      if (isClosed) return;

      final newPost = Post.fromRecord(record);

      // Add to feed
      emit(
        state.copyWith(
          posts: [newPost, ...state.posts],
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: FeedStatus.error,
          errorMessage: e.toString(),
        ),
      );
      rethrow;
    }
  }

  /// Delete a post
  Future<void> deletePost(String postId) async {
    try {
      await pocketBaseService.deletePost(postId);

      // Check if cubit is still open after async operation
      if (isClosed) return;

      // Remove from feed
      final updatedPosts = state.posts.where((p) => p.id != postId).toList();
      emit(state.copyWith(posts: updatedPosts));
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: FeedStatus.error,
          errorMessage: e.toString(),
        ),
      );
      rethrow;
    }
  }

  /// Toggle reaction on a post
  Future<void> toggleReaction(String postId, ReactionType type) async {
    try {
      final currentReaction = state.userReactions[postId];
      print(
        'FeedCubit - Current reaction: ${currentReaction?.reactionType.value}',
      );
      print('FeedCubit - New reaction type: ${type.value}');

      if (currentReaction?.reactionType == type) {
        // Same reaction, remove it
        print('FeedCubit - Removing reaction');
        await pocketBaseService.removeReaction(
          postId: postId,
          userId: currentUserId,
        );

        // Check if cubit is still open after async operation
        if (isClosed) return;

        // Update local state - remove reaction
        final updatedReactions = Map<String, PostReaction?>.from(state.userReactions);
        updatedReactions[postId] = null;

        // Decrement count
        final postIndex = state.posts.indexWhere((p) => p.id == postId);
        final updatedPosts = List<Post>.from(state.posts);
        if (postIndex != -1) {
          updatedPosts[postIndex] = updatedPosts[postIndex].copyWith(
            likesCount: updatedPosts[postIndex].likesCount - 1,
          );
        }

        print('FeedCubit - Emitting state with no reaction');

        // Force a complete state update by creating entirely new state
        emit(
          FeedState(
            status: state.status,
            posts: updatedPosts,
            currentPage: state.currentPage,
            hasMore: state.hasMore,
            errorMessage: state.errorMessage,
            selectedPost: state.selectedPost,
            userReactions: updatedReactions,
          ),
        );
      } else {
        // Different reaction or new reaction
        print('FeedCubit - Adding/updating reaction to ${type.value}');
        final record = await pocketBaseService.addReaction(
          postId: postId,
          userId: currentUserId,
          reactionType: type.value,
        );

        // Check if cubit is still open after async operation
        if (isClosed) return;

        final reaction = PostReaction.fromRecord(record);
        print(
          'FeedCubit - Got reaction from record: ${reaction.reactionType.value}',
        );

        // Update local state with new reaction
        final updatedReactions = Map<String, PostReaction?>.from(state.userReactions);
        updatedReactions[postId] = reaction;

        // Update count (only if it was a new reaction, not changing)
        final postIndex = state.posts.indexWhere((p) => p.id == postId);
        final updatedPosts = List<Post>.from(state.posts);
        if (postIndex != -1 && currentReaction == null) {
          updatedPosts[postIndex] = updatedPosts[postIndex].copyWith(
            likesCount: updatedPosts[postIndex].likesCount + 1,
          );
        }

        print(
          'FeedCubit - Emitting state with reaction: ${reaction.reactionType.value}',
        );

        // Force a complete state update by creating entirely new state
        emit(
          FeedState(
            status: state.status,
            posts: updatedPosts,
            currentPage: state.currentPage,
            hasMore: state.hasMore,
            errorMessage: state.errorMessage,
            selectedPost: state.selectedPost,
            userReactions: updatedReactions,
          ),
        );
      }

      print(
        'FeedCubit - State after toggle: ${state.userReactions[postId]?.reactionType.value}',
      );
    } catch (e) {
      print('Error toggling reaction: $e');
      rethrow;
    }
  }

  /// Load user reactions for posts
  Future<void> _loadUserReactions(List<String> postIds) async {
    try {
      final reactions = <String, PostReaction?>{};

      for (final postId in postIds) {
        // Check if cubit is still open before each async operation
        if (isClosed) return;

        final reaction = await pocketBaseService.getUserReaction(postId, currentUserId);
        if (reaction != null) {
          reactions[postId] = PostReaction.fromRecord(reaction);
        } else {
          reactions[postId] = null;
        }
      }

      // Check if cubit is still open before emitting
      if (isClosed) return;

      final updatedReactions = Map<String, PostReaction?>.from(state.userReactions);
      updatedReactions.addAll(reactions);

      emit(state.copyWith(userReactions: updatedReactions));
    } catch (e) {
      print('Error loading user reactions: $e');
    }
  }

  /// Refresh a single post
  Future<void> refreshPost(String postId) async {
    try {
      final record = await pocketBaseService.getPost(postId);

      // Check if cubit is still open before emitting
      if (isClosed) return;

      final updatedPost = Post.fromRecord(record);

      final postIndex = state.posts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        final updatedPosts = List<Post>.from(state.posts);
        updatedPosts[postIndex] = updatedPost;

        // Force a complete state update
        emit(
          FeedState(
            status: state.status,
            posts: updatedPosts,
            currentPage: state.currentPage,
            hasMore: state.hasMore,
            errorMessage: state.errorMessage,
            selectedPost: state.selectedPost,
            userReactions: state.userReactions,
          ),
        );
      }
    } catch (e) {
      print('Error refreshing post: $e');
    }
  }

  /// Load reactions for a post (for detail view)
  Future<void> loadReactions(String postId) async {
    try {
      await pocketBaseService.getReactions(postId);
      // This data can be used in the UI if needed
      // For now, we just load it to ensure it's fresh
    } catch (e) {
      print('Error loading reactions: $e');
    }
  }
}
