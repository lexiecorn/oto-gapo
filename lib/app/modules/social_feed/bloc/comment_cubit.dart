import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:otogapo/models/post_comment.dart';
import 'package:otogapo/services/pocketbase_service.dart';
import 'package:otogapo/utils/text_parsing_utils.dart';

part 'comment_state.dart';

/// Cubit for managing comments state
class CommentCubit extends Cubit<CommentState> {
  CommentCubit({
    required this.pocketBaseService,
    required this.currentUserId,
  }) : super(const CommentState());

  final PocketBaseService pocketBaseService;
  final String currentUserId;

  /// Load comments for a post
  Future<void> loadComments(String postId, {int page = 1}) async {
    try {
      if (page == 1) {
        emit(
          state.copyWith(
            status: CommentStatus.loading,
            postId: postId,
          ),
        );
      } else {
        emit(state.copyWith(status: CommentStatus.loadingMore));
      }

      final result = await pocketBaseService.getComments(
        postId: postId,
        page: page,
      );

      final comments =
          result.items.map(PostComment.fromRecord).toList();

      if (page == 1) {
        emit(
          state.copyWith(
            status: CommentStatus.loaded,
            comments: comments,
            currentPage: page,
            hasMore: result.page < result.totalPages,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: CommentStatus.loaded,
            comments: [...state.comments, ...comments],
            currentPage: page,
            hasMore: result.page < result.totalPages,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: CommentStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Load more comments (pagination)
  Future<void> loadMore() async {
    if (!state.hasMore ||
        state.status == CommentStatus.loadingMore ||
        state.postId == null) {
      return;
    }

    await loadComments(state.postId!, page: state.currentPage + 1);
  }

  /// Add a comment
  Future<void> addComment(String postId, String commentText) async {
    try {
      // Check if user is banned
      final ban = await pocketBaseService.checkUserBan(currentUserId,
          banType: 'comment',);
      if (ban != null) {
        throw Exception('You are banned from commenting');
      }

      // Extract mentions and hashtags
      final mentions = TextParsingUtils.extractMentions(commentText);
      final hashtags = TextParsingUtils.extractHashtags(commentText);

      // Add comment
      final record = await pocketBaseService.addComment(
        postId: postId,
        userId: currentUserId,
        commentText: commentText,
        mentions: mentions,
        hashtags: hashtags,
      );

      final newComment = PostComment.fromRecord(record);

      // Add to top of list
      emit(
        state.copyWith(
          comments: [newComment, ...state.comments],
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CommentStatus.error,
          errorMessage: e.toString(),
        ),
      );
      rethrow;
    }
  }

  /// Update a comment (within 5 minutes)
  Future<void> updateComment(String commentId, String newText) async {
    try {
      // Find the comment
      final commentIndex = state.comments.indexWhere((c) => c.id == commentId);
      if (commentIndex == -1) {
        throw Exception('Comment not found');
      }

      final comment = state.comments[commentIndex];

      // Check if can edit
      if (!comment.canEdit) {
        throw Exception('Comment can no longer be edited (5 minute limit)');
      }

      // Extract mentions and hashtags
      final mentions = TextParsingUtils.extractMentions(newText);
      final hashtags = TextParsingUtils.extractHashtags(newText);

      // Update comment
      final record = await pocketBaseService.updateComment(
        commentId: commentId,
        commentText: newText,
        mentions: mentions,
        hashtags: hashtags,
      );

      final updatedComment = PostComment.fromRecord(record);

      // Update in list
      final updatedComments = List<PostComment>.from(state.comments);
      updatedComments[commentIndex] = updatedComment;

      emit(state.copyWith(comments: updatedComments));
    } catch (e) {
      emit(
        state.copyWith(
          status: CommentStatus.error,
          errorMessage: e.toString(),
        ),
      );
      rethrow;
    }
  }

  /// Delete a comment
  Future<void> deleteComment(String commentId) async {
    try {
      await pocketBaseService.deleteComment(commentId);

      // Remove from list
      final updatedComments =
          state.comments.where((c) => c.id != commentId).toList();
      emit(state.copyWith(comments: updatedComments));
    } catch (e) {
      emit(
        state.copyWith(
          status: CommentStatus.error,
          errorMessage: e.toString(),
        ),
      );
      rethrow;
    }
  }

  /// Refresh comments
  Future<void> refresh() async {
    if (state.postId != null) {
      await loadComments(state.postId!);
    }
  }

  /// Clear state
  void clear() {
    emit(const CommentState());
  }
}
