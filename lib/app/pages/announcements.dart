import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:otogapo/services/pocketbase_service.dart';
import 'package:otogapo/utils/announcement_type_helper.dart';

class AnnouncementsWidget extends StatefulWidget {
  const AnnouncementsWidget({super.key});

  @override
  State<AnnouncementsWidget> createState() => _AnnouncementsWidgetState();
}

class _AnnouncementsWidgetState extends State<AnnouncementsWidget>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _announcements = [];
  bool _isLoading = true;
  bool _hasTriedFetching = false;
  String _errorMessage = '';
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Don't fetch immediately - wait for authentication
  }

  void _checkAuthAndFetch() {
    final authState = context.read<AuthBloc>().state;

    // Only fetch if user is authenticated and we haven't tried yet
    if (authState.authStatus == AuthStatus.authenticated &&
        authState.user != null &&
        !_hasTriedFetching) {
      _hasTriedFetching = true;
      _fetchAnnouncements();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchAnnouncements() async {
    try {
      final pocketBaseService = PocketBaseService();
      final announcements = await pocketBaseService.getAnnouncements();

      if (announcements.isNotEmpty) {
        _announcements =
            announcements.map((announcement) => announcement.data).toList();
        // Sort by date (newest first)
        _announcements.sort((a, b) {
          final dateA = DateTime.parse(a['created'] as String);
          final dateB = DateTime.parse(b['created'] as String);
          return dateB.compareTo(dateA);
        });
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
      if (_announcements.isNotEmpty) {
        _fadeController.forward();
        _slideController.forward();
      }
    }
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
    // Check authentication status and fetch data if ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndFetch();
    });

    // If user is not authenticated yet, show loading
    final authState = context.read<AuthBloc>().state;
    if (authState.authStatus != AuthStatus.authenticated ||
        authState.user == null) {
      return Container(
        height: 200.sp,
        padding: EdgeInsets.all(16.sp),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.sp),
          color: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).colorScheme.surface
              : Colors.white,
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).colorScheme.outline.withOpacity(0.2)
                : Colors.grey.shade200,
          ),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Container(
        height: 200.sp,
        padding: EdgeInsets.all(16.sp),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.sp),
          color: isDark ? colorScheme.surface : Colors.white,
          border: Border.all(
            color: isDark
                ? colorScheme.outline.withOpacity(0.2)
                : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 32.sp,
                height: 32.sp,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? colorScheme.primary : colorScheme.primary,
                  ),
                ),
              ),
              SizedBox(height: 16.sp),
              Text(
                'Loading announcements...',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark
                      ? colorScheme.onSurface.withOpacity(0.7)
                      : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Container(
        height: 120.sp,
        padding: EdgeInsets.all(16.sp),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.sp),
          color: isDark ? colorScheme.surface : Colors.white,
          border: Border.all(
            color: isDark
                ? colorScheme.outline.withOpacity(0.2)
                : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.announcement_outlined,
                size: 32.sp,
                color: isDark
                    ? colorScheme.onSurface.withOpacity(0.5)
                    : Colors.grey[400],
              ),
              SizedBox(height: 8.sp),
              Text(
                _errorMessage,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark
                      ? colorScheme.onSurface.withOpacity(0.7)
                      : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          constraints: BoxConstraints(maxHeight: 400.sp),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.sp),
            color: isDark ? colorScheme.surface : Colors.white,
            border: Border.all(
              color: isDark
                  ? colorScheme.outline.withOpacity(0.2)
                  : Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(16.sp),
                decoration: BoxDecoration(
                  color: isDark
                      ? colorScheme.primary.withOpacity(0.1)
                      : colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.sp),
                    topRight: Radius.circular(16.sp),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.sp),
                      decoration: BoxDecoration(
                        color:
                            isDark ? colorScheme.primary : colorScheme.primary,
                        borderRadius: BorderRadius.circular(8.sp),
                      ),
                      child: Icon(
                        Icons.announcement_rounded,
                        size: 20.sp,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 12.sp),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Announcements',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? colorScheme.onSurface
                                  : Colors.black87,
                            ),
                          ),
                          Text(
                            '${_announcements.length} announcement${_announcements.length != 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: isDark
                                  ? colorScheme.onSurface.withOpacity(0.7)
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_announcements.isNotEmpty)
                      IconButton(
                        onPressed: _fetchAnnouncements,
                        icon: Icon(
                          Icons.refresh_rounded,
                          size: 20.sp,
                          color: isDark
                              ? colorScheme.onSurface.withOpacity(0.7)
                              : Colors.grey[600],
                        ),
                        tooltip: 'Refresh',
                      ),
                  ],
                ),
              ),

              // Announcements List
              Expanded(
                child: _announcements.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.announcement_outlined,
                              size: 48.sp,
                              color: isDark
                                  ? colorScheme.onSurface.withOpacity(0.3)
                                  : Colors.grey[300],
                            ),
                            SizedBox(height: 16.sp),
                            Text(
                              'No announcements',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? colorScheme.onSurface.withOpacity(0.5)
                                    : Colors.grey[500],
                              ),
                            ),
                            SizedBox(height: 8.sp),
                            Text(
                              'Check back later for updates',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: isDark
                                    ? colorScheme.onSurface.withOpacity(0.4)
                                    : Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      )
                    : Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        trackVisibility: true,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.zero,
                          itemCount: _announcements.length,
                          itemBuilder: (context, index) {
                            final announcement = _announcements[index];
                            final isLast = index == _announcements.length - 1;

                            return _buildAnnouncementCard(
                              announcement: announcement,
                              isDark: isDark,
                              colorScheme: colorScheme,
                              isLast: isLast,
                              index: index,
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard({
    required Map<String, dynamic> announcement,
    required bool isDark,
    required ColorScheme colorScheme,
    required bool isLast,
    required int index,
  }) {
    final type = announcement['type'] as String? ?? 'general';
    final title = announcement['title'] as String? ?? 'No Title';
    final content = announcement['content'] as String? ?? 'No content';
    final dateString = announcement['created'] as String?;
    final date = dateString != null ? DateTime.parse(dateString) : null;
    final imageField = announcement['img'] as String?;

    return Container(
      margin: EdgeInsets.only(
        left: 16.sp,
        right: 16.sp,
        top: 12.sp,
        bottom: isLast ? 16.sp : 0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.sp),
        color: isDark ? colorScheme.surface : Colors.white,
        border: Border.all(
          color: isDark
              ? colorScheme.outline.withOpacity(0.1)
              : Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.sp),
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
                  width: 50.sp,
                  height: 50.sp,
                  decoration: BoxDecoration(
                    color: _getTypeColor(type, isDark).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.sp),
                  ),
                  child: imageField != null && imageField.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10.sp),
                          child: CachedNetworkImage(
                            imageUrl: _buildImageUrl(announcement, '100x100t'),
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Icon(
                              _getTypeIcon(type),
                              size: 20.sp,
                              color: _getTypeColor(type, isDark),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              _getTypeIcon(type),
                              size: 20.sp,
                              color: _getTypeColor(type, isDark),
                            ),
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.all(10.sp),
                          child: Icon(
                            _getTypeIcon(type),
                            size: 20.sp,
                            color: _getTypeColor(type, isDark),
                          ),
                        ),
                ),

                SizedBox(width: 16.sp),

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
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? colorScheme.onSurface
                                    : Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.sp, vertical: 4.sp,),
                            decoration: BoxDecoration(
                              color:
                                  _getTypeColor(type, isDark).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.sp),
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
                      SizedBox(height: 8.sp),
                      Text(
                        content,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isDark
                              ? colorScheme.onSurface.withOpacity(0.8)
                              : Colors.grey[700],
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 12.sp),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 14.sp,
                            color: isDark
                                ? colorScheme.onSurface.withOpacity(0.5)
                                : Colors.grey[500],
                          ),
                          SizedBox(width: 4.sp),
                          Text(
                            date != null
                                ? DateFormat('MMM dd, yyyy • h:mm a')
                                    .format(date)
                                : 'No date',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: isDark
                                  ? colorScheme.onSurface.withOpacity(0.5)
                                  : Colors.grey[500],
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12.sp,
                            color: isDark
                                ? colorScheme.onSurface.withOpacity(0.3)
                                : Colors.grey[400],
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
      ),
    );
  }

  void _showAnnouncementDetails(
      Map<String, dynamic> announcement, bool isDark, ColorScheme colorScheme,) {
    final type = announcement['type'] as String? ?? 'general';
    final title = announcement['title'] as String? ?? 'No Title';
    final content = announcement['content'] as String? ?? 'No content';
    final dateString = announcement['created'] as String?;
    final date = dateString != null ? DateTime.parse(dateString) : null;
    final imageField = announcement['img'] as String?;
    final imageUrl = imageField != null && imageField.isNotEmpty
        ? _buildImageUrl(announcement, '300x300t')
        : null;

    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: isDark ? colorScheme.surface : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.sp),
        ),
        child: Container(
          padding: EdgeInsets.all(24.sp),
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
                      borderRadius: BorderRadius.circular(12.sp),
                    ),
                    child: Icon(
                      _getTypeIcon(type),
                      size: 24.sp,
                      color: _getTypeColor(type, isDark),
                    ),
                  ),
                  SizedBox(width: 16.sp),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                            color:
                                isDark ? colorScheme.onSurface : Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4.sp),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.sp, vertical: 4.sp,),
                          decoration: BoxDecoration(
                            color: _getTypeColor(type, isDark).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.sp),
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
                      color: isDark
                          ? colorScheme.onSurface.withOpacity(0.7)
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.sp),

              // Image if present
              if (imageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.sp),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => Container(
                      height: 150.sp,
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
                      height: 150.sp,
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      child: const Icon(Icons.broken_image, size: 48),
                    ),
                  ),
                ),
                SizedBox(height: 20.sp),
              ],

              // Content
              Text(
                content,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: isDark
                      ? colorScheme.onSurface.withOpacity(0.9)
                      : Colors.grey[800],
                  height: 1.5,
                ),
              ),

              SizedBox(height: 20.sp),

              // Date
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 16.sp,
                    color: isDark
                        ? colorScheme.onSurface.withOpacity(0.5)
                        : Colors.grey[500],
                  ),
                  SizedBox(width: 8.sp),
                  Text(
                    date != null
                        ? DateFormat('EEEE, MMMM dd, yyyy • h:mm a')
                            .format(date)
                        : 'No date available',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDark
                          ? colorScheme.onSurface.withOpacity(0.6)
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.sp),

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDark ? colorScheme.primary : colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.sp),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.sp),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
