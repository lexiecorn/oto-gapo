import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/search/bloc/search_cubit.dart';
import 'package:otogapo/app/modules/search/bloc/search_state.dart';
import 'package:otogapo/app/widgets/post_card_widget.dart';
import 'package:otogapo/app/widgets/search_filter_chips.dart';
import 'package:otogapo/app/widgets/skeleton_loader.dart';

@RoutePage(name: 'SearchPageRouter')
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Auto-focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Debounce search by 300ms
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (query.trim().isNotEmpty) {
        context.read<SearchCubit>().searchPosts(query);
      } else {
        context.read<SearchCubit>().clearSearch();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchBar(),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          return Column(
            children: [
              // Filter Chips
              if (state.hasQuery) _buildFilterChips(state),

              // Results or Empty State
              Expanded(
                child: _buildContent(state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Hero(
      tag: 'search_bar',
      child: Material(
        color: Colors.transparent,
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search posts...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      _searchController.clear();
                      context.read<SearchCubit>().clearSearch();
                    },
                  )
                : null,
          ),
          onChanged: _onSearchChanged,
        ),
      ),
    );
  }

  Widget _buildFilterChips(SearchState state) {
    return SearchFilterChips(
      filters: state.filters,
      onDateRangeSelected: () => _showDateRangePicker(context),
      onAuthorSelected: () => _showAuthorPicker(context),
      onHashtagsSelected: () => _showHashtagPicker(context),
      onClearFilters: () => context.read<SearchCubit>().clearFilters(),
    );
  }

  Future<void> _showAuthorPicker(BuildContext context) async {
    // TODO: Show user selection dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Author filter coming soon')),
    );
  }

  Future<void> _showHashtagPicker(BuildContext context) async {
    // TODO: Show hashtag selection dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Hashtag filter coming soon')),
    );
  }

  Widget _buildContent(SearchState state) {
    if (!state.hasQuery) {
      return _buildEmptySearchState(state);
    }

    if (state.isLoading) {
      return ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => const SkeletonPostCard(),
      );
    }

    if (state.status == SearchStatus.error) {
      return _buildErrorState(state.errorMessage ?? 'Search failed');
    }

    if (!state.hasResults) {
      return _buildNoResultsState(state.query);
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemCount: state.postResults.length,
      itemBuilder: (context, index) {
        final post = state.postResults[index];
        return PostCardWidget(
          post: post,
          currentUserId: '', // Will be provided by AuthBloc
        )
            .animate()
            .fadeIn(
              duration: 300.ms,
              delay: Duration(milliseconds: index * 50),
            )
            .slideY(
              begin: 0.2,
              end: 0,
              duration: 400.ms,
            );
      },
    );
  }

  Widget _buildEmptySearchState(SearchState state) {
    return Padding(
      padding: EdgeInsets.all(24.sp),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80.sp,
            color: Colors.grey[300],
          ),
          SizedBox(height: 24.h),
          Text(
            'Search Posts',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start typing to search for posts',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          if (state.recentSearches.isNotEmpty) ...[
            SizedBox(height: 32.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Searches',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<SearchCubit>().clearRecentSearches();
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            ...state.recentSearches.map(
              (query) => ListTile(
                leading: const Icon(Icons.history),
                title: Text(query),
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    context.read<SearchCubit>().removeRecentSearch(query);
                  },
                ),
                onTap: () {
                  _searchController.text = query;
                  context.read<SearchCubit>().searchPosts(query);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoResultsState(String query) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.sp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80.sp,
              color: Colors.grey[300],
            ),
            SizedBox(height: 24.h),
            Text(
              'No Results Found',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'No posts found for "$query"',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            TextButton(
              onPressed: () {
                _searchController.clear();
                context.read<SearchCubit>().clearSearch();
              },
              child: const Text('Clear Search'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.sp,
            color: Colors.red,
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(fontSize: 16.sp),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade600,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final currentFilters = context.read<SearchCubit>().state.filters;
      context.read<SearchCubit>().updateFilters(
            currentFilters.copyWith(
              dateFrom: picked.start,
              dateTo: picked.end,
            ),
          );
    }
  }
}
