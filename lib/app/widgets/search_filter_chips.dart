import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/search/bloc/search_state.dart';

/// Filter chips for search functionality
class SearchFilterChips extends StatelessWidget {
  const SearchFilterChips({
    required this.filters,
    required this.onDateRangeSelected,
    required this.onAuthorSelected,
    required this.onHashtagsSelected,
    required this.onClearFilters,
    super.key,
  });

  final SearchFilters filters;
  final VoidCallback onDateRangeSelected;
  final VoidCallback onAuthorSelected;
  final VoidCallback onHashtagsSelected;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (filters.hasFilters) ...[
              ActionChip(
                avatar: const Icon(Icons.clear, size: 18),
                label: const Text('Clear All'),
                onPressed: onClearFilters,
                backgroundColor: Colors.red.shade50,
                labelStyle: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 8.w),
            ],
            FilterChip(
              label: Text(_getDateRangeLabel()),
              selected: filters.dateFrom != null || filters.dateTo != null,
              onSelected: (_) => onDateRangeSelected(),
              avatar: const Icon(Icons.date_range, size: 18),
              selectedColor: Colors.blue.shade100,
            ),
            SizedBox(width: 8.w),
            FilterChip(
              label: Text(_getAuthorLabel()),
              selected: filters.authorId != null,
              onSelected: (_) => onAuthorSelected(),
              avatar: const Icon(Icons.person, size: 18),
              selectedColor: Colors.green.shade100,
            ),
            SizedBox(width: 8.w),
            FilterChip(
              label: Text(_getHashtagsLabel()),
              selected: filters.hashtags.isNotEmpty,
              onSelected: (_) => onHashtagsSelected(),
              avatar: const Icon(Icons.tag, size: 18),
              selectedColor: Colors.purple.shade100,
            ),
          ],
        ),
      ),
    );
  }

  String _getDateRangeLabel() {
    if (filters.dateFrom != null && filters.dateTo != null) {
      return 'Date Range Active';
    }
    return 'Date Range';
  }

  String _getAuthorLabel() {
    if (filters.authorId != null) {
      return 'Author Selected';
    }
    return 'Author';
  }

  String _getHashtagsLabel() {
    if (filters.hashtags.isNotEmpty) {
      return '${filters.hashtags.length} Tags';
    }
    return 'Hashtags';
  }
}

/// Hashtag chip for selection
class HashtagChip extends StatelessWidget {
  const HashtagChip({
    required this.hashtag,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final String hashtag;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade600 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tag,
              size: 16.sp,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
            SizedBox(width: 4.w),
            Text(
              '#$hashtag',
              style: TextStyle(
                fontSize: 14.sp,
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
