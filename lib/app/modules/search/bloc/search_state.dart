import 'package:equatable/equatable.dart';
import 'package:otogapo/models/post.dart';
import 'package:pocketbase/pocketbase.dart';

/// Status of search operation
enum SearchStatus {
  initial,
  loading,
  loaded,
  error,
}

/// Search filters for posts
class SearchFilters extends Equatable {
  const SearchFilters({
    this.dateFrom,
    this.dateTo,
    this.authorId,
    this.hashtags = const [],
  });

  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? authorId;
  final List<String> hashtags;

  bool get hasFilters => dateFrom != null || dateTo != null || authorId != null || hashtags.isNotEmpty;

  SearchFilters copyWith({
    DateTime? dateFrom,
    DateTime? dateTo,
    String? authorId,
    List<String>? hashtags,
  }) {
    return SearchFilters(
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      authorId: authorId ?? this.authorId,
      hashtags: hashtags ?? this.hashtags,
    );
  }

  SearchFilters clearFilters() {
    return const SearchFilters();
  }

  @override
  List<Object?> get props => [dateFrom, dateTo, authorId, hashtags];
}

/// State for search functionality
class SearchState extends Equatable {
  const SearchState({
    this.status = SearchStatus.initial,
    this.query = '',
    this.postResults = const [],
    this.userResults = const [],
    this.recentSearches = const [],
    this.filters = const SearchFilters(),
    this.errorMessage,
  });

  final SearchStatus status;
  final String query;
  final List<Post> postResults;
  final List<RecordModel> userResults;
  final List<String> recentSearches;
  final SearchFilters filters;
  final String? errorMessage;

  bool get isLoading => status == SearchStatus.loading;
  bool get hasResults => postResults.isNotEmpty || userResults.isNotEmpty;
  bool get hasQuery => query.isNotEmpty;

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    List<Post>? postResults,
    List<RecordModel>? userResults,
    List<String>? recentSearches,
    SearchFilters? filters,
    String? errorMessage,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      postResults: postResults ?? this.postResults,
      userResults: userResults ?? this.userResults,
      recentSearches: recentSearches ?? this.recentSearches,
      filters: filters ?? this.filters,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        query,
        postResults,
        userResults,
        recentSearches,
        filters,
        errorMessage,
      ];
}
