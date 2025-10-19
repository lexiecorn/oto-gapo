part of 'comment_cubit.dart';

/// Status of comments
enum CommentStatus {
  initial,
  loading,
  loaded,
  error,
  loadingMore,
}

/// State for comments
class CommentState extends Equatable {
  const CommentState({
    this.status = CommentStatus.initial,
    this.comments = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.errorMessage,
    this.postId,
  });

  final CommentStatus status;
  final List<PostComment> comments;
  final int currentPage;
  final bool hasMore;
  final String? errorMessage;
  final String? postId;

  CommentState copyWith({
    CommentStatus? status,
    List<PostComment>? comments,
    int? currentPage,
    bool? hasMore,
    String? errorMessage,
    String? postId,
  }) {
    return CommentState(
      status: status ?? this.status,
      comments: comments ?? this.comments,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage ?? this.errorMessage,
      postId: postId ?? this.postId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        comments,
        currentPage,
        hasMore,
        errorMessage,
        postId,
      ];
}
