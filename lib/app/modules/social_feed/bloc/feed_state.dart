part of 'feed_cubit.dart';

/// Status of the feed
enum FeedStatus {
  initial,
  loading,
  loaded,
  error,
  loadingMore,
}

/// State for the feed
class FeedState extends Equatable {
  const FeedState({
    this.status = FeedStatus.initial,
    this.posts = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.errorMessage,
    this.selectedPost,
    this.userReactions = const {},
  });

  final FeedStatus status;
  final List<Post> posts;
  final int currentPage;
  final bool hasMore;
  final String? errorMessage;
  final Post? selectedPost;
  final Map<String, PostReaction?> userReactions; // postId -> reaction

  FeedState copyWith({
    FeedStatus? status,
    List<Post>? posts,
    int? currentPage,
    bool? hasMore,
    String? errorMessage,
    Post? selectedPost,
    Map<String, PostReaction?>? userReactions,
  }) {
    return FeedState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedPost: selectedPost ?? this.selectedPost,
      userReactions: userReactions ?? this.userReactions,
    );
  }

  @override
  List<Object?> get props => [
        status,
        posts.length,
        posts.map((p) => '${p.id}-${p.likesCount}-${p.commentsCount}').join(','),
        currentPage,
        hasMore,
        errorMessage,
        selectedPost,
        userReactions.toString(), // Convert to string to force comparison
      ];
}
