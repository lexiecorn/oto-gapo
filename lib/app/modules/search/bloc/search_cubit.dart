import 'package:bloc/bloc.dart';
import 'package:local_storage/local_storage.dart';
import 'package:otogapo/app/modules/search/bloc/search_state.dart';
import 'package:otogapo/models/post.dart';
import 'package:otogapo/services/pocketbase_service.dart';

/// Cubit for managing search functionality
class SearchCubit extends Cubit<SearchState> {
  SearchCubit({
    required PocketBaseService pocketBaseService,
    required LocalStorage localStorage,
  })  : _pocketBaseService = pocketBaseService,
        _localStorage = localStorage,
        super(const SearchState()) {
    _loadRecentSearches();
  }

  final PocketBaseService _pocketBaseService;
  final LocalStorage _localStorage;

  static const _recentSearchesKey = 'recent_searches';
  static const _maxRecentSearches = 10;

  Future<void> _loadRecentSearches() async {
    try {
      final searches = await _localStorage.read<List<dynamic>>(_recentSearchesKey);
      if (searches != null) {
        emit(
          state.copyWith(
            recentSearches: searches.cast<String>(),
          ),
        );
      }
    } catch (e) {
      print('SearchCubit - Error loading recent searches: $e');
    }
  }

  /// Search for posts with optional filters
  Future<void> searchPosts(String query, {int page = 1}) async {
    if (query.trim().isEmpty) {
      emit(state.copyWith(query: '', postResults: [], status: SearchStatus.initial));
      return;
    }

    if (page == 1) {
      emit(state.copyWith(status: SearchStatus.loading, query: query));
    }

    try {
      final results = await _pocketBaseService.searchPosts(
        query: query,
        filters: _buildFilterMap(state.filters),
        page: page,
      );

      final posts = results.items.map((record) => Post.fromRecord(record)).toList();

      emit(
        state.copyWith(
          status: SearchStatus.loaded,
          postResults: page == 1 ? posts : [...state.postResults, ...posts],
        ),
      );

      // Save to recent searches
      await _addToRecentSearches(query);
    } catch (e) {
      emit(
        state.copyWith(
          status: SearchStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Search for users
  Future<void> searchUsers(String query, {int page = 1}) async {
    if (query.trim().isEmpty) {
      emit(state.copyWith(query: '', userResults: [], status: SearchStatus.initial));
      return;
    }

    if (page == 1) {
      emit(state.copyWith(status: SearchStatus.loading, query: query));
    }

    try {
      final results = await _pocketBaseService.searchUsers(
        query: query,
        page: page,
      );

      emit(
        state.copyWith(
          status: SearchStatus.loaded,
          userResults: page == 1 ? results.items : [...state.userResults, ...results.items],
        ),
      );

      await _addToRecentSearches(query);
    } catch (e) {
      emit(
        state.copyWith(
          status: SearchStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Update search filters
  void updateFilters(SearchFilters filters) {
    emit(state.copyWith(filters: filters));

    // Re-search if there's an active query
    if (state.hasQuery) {
      searchPosts(state.query);
    }
  }

  /// Clear search filters
  void clearFilters() {
    emit(state.copyWith(filters: const SearchFilters()));

    if (state.hasQuery) {
      searchPosts(state.query);
    }
  }

  /// Clear search results
  void clearSearch() {
    emit(
      state.copyWith(
        query: '',
        postResults: [],
        userResults: [],
        status: SearchStatus.initial,
      ),
    );
  }

  /// Add search query to recent searches
  Future<void> _addToRecentSearches(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return;

    final searches = List<String>.from(state.recentSearches);

    // Remove if already exists
    searches.remove(trimmedQuery);

    // Add to front
    searches.insert(0, trimmedQuery);

    // Limit size
    if (searches.length > _maxRecentSearches) {
      searches.removeRange(_maxRecentSearches, searches.length);
    }

    emit(state.copyWith(recentSearches: searches));

    // Save to storage
    try {
      await _localStorage.write(_recentSearchesKey, searches);
    } catch (e) {
      print('SearchCubit - Error saving recent searches: $e');
    }
  }

  /// Clear recent searches
  Future<void> clearRecentSearches() async {
    emit(state.copyWith(recentSearches: []));

    try {
      await _localStorage.delete(_recentSearchesKey);
    } catch (e) {
      print('SearchCubit - Error clearing recent searches: $e');
    }
  }

  /// Remove a specific recent search
  Future<void> removeRecentSearch(String query) async {
    final searches = List<String>.from(state.recentSearches);
    searches.remove(query);

    emit(state.copyWith(recentSearches: searches));

    try {
      await _localStorage.write(_recentSearchesKey, searches);
    } catch (e) {
      print('SearchCubit - Error removing recent search: $e');
    }
  }

  Map<String, dynamic> _buildFilterMap(SearchFilters filters) {
    final filterMap = <String, dynamic>{};

    if (filters.dateFrom != null) {
      filterMap['dateFrom'] = filters.dateFrom!.toIso8601String();
    }

    if (filters.dateTo != null) {
      filterMap['dateTo'] = filters.dateTo!.toIso8601String();
    }

    if (filters.authorId != null) {
      filterMap['authorId'] = filters.authorId;
    }

    if (filters.hashtags.isNotEmpty) {
      filterMap['hashtags'] = filters.hashtags;
    }

    return filterMap;
  }
}
