import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:otogapo/services/pocketbase_service.dart';
import 'package:otogapo/utils/announcement_type_helper.dart';

@RoutePage(name: 'AnnouncementsListPageRouter')
class AnnouncementsListPage extends StatefulWidget {
  const AnnouncementsListPage({super.key});

  @override
  State<AnnouncementsListPage> createState() => _AnnouncementsListPageState();
}

class _AnnouncementsListPageState extends State<AnnouncementsListPage> {
  List<Map<String, dynamic>> _announcements = [];
  List<Map<String, dynamic>> _filteredAnnouncements = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';
  String? _selectedType;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _announcementTypes = [
    'All',
    ...AnnouncementTypeHelper.allTypes,
  ];

  @override
  void initState() {
    super.initState();
    _fetchAnnouncements();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAnnouncements() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final pocketBaseService = PocketBaseService();
      final announcements = await pocketBaseService.getAnnouncements();

      if (announcements.isNotEmpty) {
        _announcements = announcements.map((announcement) => announcement.data).toList();
        // Sort by date (newest first)
        _announcements.sort((a, b) {
          final dateA = DateTime.parse(a['created'] as String);
          final dateB = DateTime.parse(b['created'] as String);
          return dateB.compareTo(dateA);
        });
        _applyFilters();
      } else {
        _errorMessage = 'No announcements available';
      }
    } catch (e) {
      _errorMessage = 'Failed to load announcements';
      debugPrint('Error fetching announcements: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredAnnouncements = _announcements.where((announcement) {
        // Filter by type
        final matchesType = _selectedType == null || _selectedType == 'All' || announcement['type'] == _selectedType;

        // Filter by search query
        final matchesSearch = _searchQuery.isEmpty ||
            (announcement['title'] as String?)?.toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
            (announcement['content'] as String?)?.toLowerCase().contains(_searchQuery.toLowerCase()) == true;

        return matchesType && matchesSearch;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();
  }

  void _onTypeSelected(String? type) {
    setState(() {
      _selectedType = type;
    });
    _applyFilters();
  }

  Color _getTypeColor(String type, bool isDark) {
    return AnnouncementTypeHelper.getTypeColor(type, isDark);
  }

  IconData _getTypeIcon(String type) {
    return AnnouncementTypeHelper.getTypeIcon(type);
  }

  String _buildImageUrl(Map<String, dynamic> announcement, String? thumb) {
    final imgField = announcement['img'] as String?;
    if (imgField == null || imgField.isEmpty) return '';

    final baseUrl = PocketBaseService().pb.baseUrl;
    final collectionId = announcement['collectionId'] as String?;
    final recordId = announcement['id'] as String?;

    if (collectionId == null || recordId == null) return '';

    if (thumb != null && thumb.isNotEmpty) {
      return '$baseUrl/api/files/$collectionId/$recordId/$imgField?thumb=$thumb';
    }

    return '$baseUrl/api/files/$collectionId/$recordId/$imgField';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
        actions: [
          IconButton(
            onPressed: _fetchAnnouncements,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(16.sp),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: TextStyle(fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: 'Search announcements...',
                hintStyle: TextStyle(fontSize: 14.sp),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                filled: true,
                fillColor: isDark ? colorScheme.surface : Colors.grey[100],
              ),
            ),
          ),

          // Type Filter
          SizedBox(
            height: 40.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.sp),
              itemCount: _announcementTypes.length,
              itemBuilder: (context, index) {
                final type = _announcementTypes[index];
                final isSelected = _selectedType == type || (_selectedType == null && type == 'All');

                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: FilterChip(
                    label: Text(
                      type == 'All' ? 'All' : type.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isSelected ? colorScheme.primary : (isDark ? colorScheme.onSurface : Colors.grey[700]),
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      _onTypeSelected(type == 'All' ? null : type);
                    },
                    selectedColor: colorScheme.primary.withOpacity(0.2),
                    checkmarkColor: colorScheme.primary,
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 0),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 8.h),

          // Content
          Expanded(
            child: _buildContent(isDark, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark, ColorScheme colorScheme) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
            SizedBox(height: 16.h),
            Text(
              'Loading announcements...',
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark ? colorScheme.onSurface.withOpacity(0.7) : Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.announcement_outlined,
              size: 64.sp,
              color: isDark ? colorScheme.onSurface.withOpacity(0.3) : Colors.grey[300],
            ),
            SizedBox(height: 16.h),
            Text(
              _errorMessage,
              style: TextStyle(
                fontSize: 15.sp,
                color: isDark ? colorScheme.onSurface.withOpacity(0.5) : Colors.grey[500],
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: _fetchAnnouncements,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredAnnouncements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64.sp,
              color: isDark ? colorScheme.onSurface.withOpacity(0.3) : Colors.grey[300],
            ),
            SizedBox(height: 16.h),
            Text(
              _announcements.isEmpty ? 'No announcements yet' : 'No matching announcements',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: isDark ? colorScheme.onSurface.withOpacity(0.5) : Colors.grey[500],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              _announcements.isEmpty ? 'Check back later for updates' : 'Try adjusting your filters',
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark ? colorScheme.onSurface.withOpacity(0.4) : Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchAnnouncements,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.h),
        itemCount: _filteredAnnouncements.length,
        itemBuilder: (context, index) {
          final announcement = _filteredAnnouncements[index];
          return _buildAnnouncementCard(
            announcement: announcement,
            isDark: isDark,
            colorScheme: colorScheme,
            index: index,
          )
              .animate()
              .fadeIn(
                duration: 300.ms,
                delay: (50 * index).ms,
              )
              .slideX(
                begin: 0.2,
                end: 0,
                duration: 300.ms,
                delay: (50 * index).ms,
              );
        },
      ),
    );
  }

  Widget _buildAnnouncementCard({
    required Map<String, dynamic> announcement,
    required bool isDark,
    required ColorScheme colorScheme,
    required int index,
  }) {
    final type = announcement['type'] as String? ?? 'general';
    final title = announcement['title'] as String? ?? 'No Title';
    final content = announcement['content'] as String? ?? 'No content';
    final dateString = announcement['created'] as String?;
    final date = dateString != null ? DateTime.parse(dateString) : null;
    final imageField = announcement['img'] as String?;

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () {
          _showAnnouncementDetails(announcement, isDark, colorScheme);
        },
        child: Padding(
          padding: EdgeInsets.all(16.sp),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon or Image
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: _getTypeColor(type, isDark).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: imageField != null && imageField.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: CachedNetworkImage(
                          imageUrl: _buildImageUrl(announcement, '100x100t'),
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Icon(
                            _getTypeIcon(type),
                            size: 24.sp,
                            color: _getTypeColor(type, isDark),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            _getTypeIcon(type),
                            size: 24.sp,
                            color: _getTypeColor(type, isDark),
                          ),
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.all(10.sp),
                        child: Icon(
                          _getTypeIcon(type),
                          size: 24.sp,
                          color: _getTypeColor(type, isDark),
                        ),
                      ),
              ),

              SizedBox(width: 16.w),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: isDark ? colorScheme.onSurface : Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor(type, isDark).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            type.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: _getTypeColor(type, isDark),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: isDark ? colorScheme.onSurface.withOpacity(0.8) : Colors.grey[700],
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14.sp,
                          color: isDark ? colorScheme.onSurface.withOpacity(0.5) : Colors.grey[500],
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          date != null ? DateFormat('MMM dd, yyyy • h:mm a').format(date) : 'No date',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isDark ? colorScheme.onSurface.withOpacity(0.5) : Colors.grey[500],
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12.sp,
                          color: isDark ? colorScheme.onSurface.withOpacity(0.3) : Colors.grey[400],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAnnouncementDetails(
    Map<String, dynamic> announcement,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final type = announcement['type'] as String? ?? 'general';
    final title = announcement['title'] as String? ?? 'No Title';
    final content = announcement['content'] as String? ?? 'No content';
    final dateString = announcement['created'] as String?;
    final date = dateString != null ? DateTime.parse(dateString) : null;
    final imageField = announcement['img'] as String?;
    final imageUrl = imageField != null && imageField.isNotEmpty ? _buildImageUrl(announcement, '600x400t') : null;

    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: isDark ? colorScheme.surface : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: EdgeInsets.all(24.sp),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.sp),
                      decoration: BoxDecoration(
                        color: _getTypeColor(type, isDark).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        _getTypeIcon(type),
                        size: 24.sp,
                        color: _getTypeColor(type, isDark),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: isDark ? colorScheme.onSurface : Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: _getTypeColor(type, isDark).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              type.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: _getTypeColor(type, isDark),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close_rounded,
                        color: isDark ? colorScheme.onSurface.withOpacity(0.7) : Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // Image if present
                if (imageUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Container(
                        height: 200.h,
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 200.h,
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                        child: const Icon(Icons.broken_image, size: 48),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],

                // Content
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isDark ? colorScheme.onSurface.withOpacity(0.9) : Colors.grey[800],
                    height: 1.5,
                  ),
                ),

                SizedBox(height: 20.h),

                // Date
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 16.sp,
                      color: isDark ? colorScheme.onSurface.withOpacity(0.5) : Colors.grey[500],
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      date != null ? DateFormat('EEEE, MMMM dd, yyyy • h:mm a').format(date) : 'No date available',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: isDark ? colorScheme.onSurface.withOpacity(0.6) : Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                // Close button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
