import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:otogapo/services/pocketbase_service.dart';
import 'package:otogapo/utils/image_compression_helper.dart';
import 'package:pocketbase/pocketbase.dart';

class AnnouncementManagementPage extends StatefulWidget {
  const AnnouncementManagementPage({super.key});

  @override
  State<AnnouncementManagementPage> createState() =>
      _AnnouncementManagementPageState();
}

class _AnnouncementManagementPageState
    extends State<AnnouncementManagementPage> {
  final PocketBaseService _pbService = PocketBaseService();
  List<RecordModel> _announcements = [];
  bool _isLoading = true;
  bool _isAdmin = false;
  String _searchQuery = '';
  String? _filterType;

  final List<String> _announcementTypes = [
    'general',
    'important',
    'urgent',
    'event',
    'reminder',
    'success',
  ];

  @override
  void initState() {
    super.initState();
    _checkAdminAndLoadAnnouncements();
  }

  Future<void> _checkAdminAndLoadAnnouncements() async {
    try {
      final authState = context.read<AuthBloc>().state;

      if (authState.user != null) {
        final userRecord = await _pbService.getUser(authState.user!.id);

        if (userRecord != null) {
          final userData = userRecord.data;
          setState(() {
            _isAdmin = userData['membership_type'] == 1 ||
                userData['membership_type'] == 2;
          });
        }

        if (_isAdmin) {
          await _loadAnnouncements();
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error checking admin status: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAnnouncements() async {
    try {
      final announcements = await _pbService.getAnnouncements();
      setState(() {
        _announcements = announcements;
      });
    } catch (e) {
      debugPrint('Error loading announcements: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading announcements: $e')),
        );
      }
    }
  }

  List<RecordModel> get _filteredAnnouncements {
    return _announcements.where((announcement) {
      final title = announcement.data['title'] as String? ?? '';
      final content = announcement.data['content'] as String? ?? '';
      final type = announcement.data['type'] as String? ?? '';

      final matchesSearch = _searchQuery.isEmpty ||
          title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          content.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesType = _filterType == null || type == _filterType;

      return matchesSearch && matchesType;
    }).toList();
  }

  Future<void> _createAnnouncement() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _AnnouncementDialog(),
    );

    if (result == null) return;

    try {
      // Show loading
      if (!mounted) return;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      var imagePath = result['imagePath'] as String?;

      // Compress image if provided
      if (imagePath != null && imagePath.isNotEmpty) {
        imagePath = await ImageCompressionHelper.compressImageIfNeeded(
          imagePath,
        );
      }

      await _pbService.createAnnouncement(
        title: result['title'] as String,
        content: result['content'] as String,
        type: result['type'] as String?,
        imageFilePath: imagePath,
        showOnLogin: result['showOnLogin'] as bool? ?? false,
        isActive: result['isActive'] as bool? ?? true,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      await _loadAnnouncements();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement created successfully')),
      );
    } catch (e) {
      debugPrint('Error creating announcement: $e');
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating announcement: $e')),
      );
    }
  }

  Future<void> _editAnnouncement(RecordModel announcement) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AnnouncementDialog(
        initialTitle: announcement.data['title'] as String?,
        initialContent: announcement.data['content'] as String?,
        initialType: announcement.data['type'] as String?,
        initialShowOnLogin: announcement.data['showOnLogin'] as bool? ?? false,
        initialIsActive: announcement.data['isActive'] as bool? ?? true,
        existingImageUrl: _pbService.getAnnouncementImageUrl(
          announcement,
          thumb: '300x300t',
        ),
      ),
    );

    if (result == null) return;

    try {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      var imagePath = result['imagePath'] as String?;

      // Compress image if provided
      if (imagePath != null && imagePath.isNotEmpty) {
        imagePath = await ImageCompressionHelper.compressImageIfNeeded(
          imagePath,
        );
      }

      await _pbService.updateAnnouncement(
        announcementId: announcement.id,
        title: result['title'] as String,
        content: result['content'] as String,
        type: result['type'] as String?,
        imageFilePath: imagePath,
        showOnLogin: result['showOnLogin'] as bool?,
        isActive: result['isActive'] as bool?,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      await _loadAnnouncements();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement updated successfully')),
      );
    } catch (e) {
      debugPrint('Error updating announcement: $e');
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating announcement: $e')),
      );
    }
  }

  Future<void> _deleteAnnouncement(RecordModel announcement) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Announcement', style: TextStyle(fontSize: 16.sp)),
        content: Text(
          'Are you sure you want to delete this announcement? This action cannot be undone.',
          style: TextStyle(fontSize: 13.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: TextStyle(fontSize: 13.sp)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(fontSize: 13.sp)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await _pbService.deleteAnnouncement(announcement.id);

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      await _loadAnnouncements();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement deleted successfully')),
      );
    } catch (e) {
      debugPrint('Error deleting announcement: $e');
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting announcement: $e')),
      );
    }
  }

  Future<void> _toggleActive(RecordModel announcement) async {
    try {
      await _pbService.toggleAnnouncementActive(announcement.id);
      await _loadAnnouncements();

      if (!mounted) return;
      final isActive = announcement.data['isActive'] as bool? ?? true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isActive ? 'Announcement hidden' : 'Announcement visible',
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error toggling active status: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Color _getTypeColor(String type, bool isDark) {
    switch (type) {
      case 'general':
        return isDark ? Colors.blue[300]! : Colors.blue[600]!;
      case 'important':
        return isDark ? Colors.orange[300]! : Colors.orange[600]!;
      case 'urgent':
        return isDark ? Colors.red[300]! : Colors.red[600]!;
      case 'event':
        return isDark ? Colors.purple[300]! : Colors.purple[600]!;
      case 'reminder':
        return isDark ? Colors.teal[300]! : Colors.teal[600]!;
      case 'success':
        return isDark ? Colors.green[300]! : Colors.green[600]!;
      default:
        return isDark ? Colors.grey[400]! : Colors.grey[600]!;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'general':
        return Icons.info;
      case 'important':
        return Icons.priority_high;
      case 'urgent':
        return Icons.warning;
      case 'event':
        return Icons.event;
      case 'reminder':
        return Icons.notifications;
      case 'success':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Announcement Management'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.security, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Access Denied',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'You need admin privileges to access this page.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredAnnouncements = _filteredAnnouncements;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcement Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnnouncements,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter
          Padding(
            padding: EdgeInsets.all(16.sp),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  style: TextStyle(fontSize: 13.sp),
                  decoration: InputDecoration(
                    hintText: 'Search announcements...',
                    hintStyle: TextStyle(fontSize: 13.sp),
                    prefixIcon: Icon(Icons.search, size: 20.sp),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  ),
                ),

                SizedBox(height: 12.h),

                // Type Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: Text('All', style: TextStyle(fontSize: 11.sp)),
                        selected: _filterType == null,
                        onSelected: (selected) {
                          setState(() {
                            _filterType = null;
                          });
                        },
                      ),
                      SizedBox(width: 8.w),
                      ..._announcementTypes.map((type) {
                        return Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: FilterChip(
                            label: Text(type.toUpperCase(),
                                style: TextStyle(fontSize: 11.sp),),
                            selected: _filterType == type,
                            onSelected: (selected) {
                              setState(() {
                                _filterType = selected ? type : null;
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Announcements List
          Expanded(
            child: filteredAnnouncements.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.campaign_outlined,
                          size: 64.sp,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          _announcements.isEmpty
                              ? 'No announcements yet'
                              : 'No matching announcements',
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          _announcements.isEmpty
                              ? 'Tap the + button to create your first announcement'
                              : 'Try adjusting your search or filters',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16.sp),
                    itemCount: filteredAnnouncements.length,
                    itemBuilder: (context, index) {
                      final announcement = filteredAnnouncements[index];
                      return _buildAnnouncementCard(announcement, isDark);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createAnnouncement,
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
    );
  }

  Widget _buildAnnouncementCard(RecordModel announcement, bool isDark) {
    final type = announcement.data['type'] as String? ?? 'general';
    final title = announcement.data['title'] as String? ?? 'Untitled';
    final content = announcement.data['content'] as String? ?? '';
    final isActive = announcement.data['isActive'] as bool? ?? true;
    final showOnLogin = announcement.data['showOnLogin'] as bool? ?? false;
    final dateString = announcement.data['created'] as String?;
    final date = dateString != null ? DateTime.tryParse(dateString) : null;
    final imageUrl = _pbService.getAnnouncementImageUrl(
      announcement,
      thumb: '100x100t',
    );

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: isActive ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.sp),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image or Icon
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: _getTypeColor(type, isDark).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          _getTypeIcon(type),
                          size: 32.sp,
                          color: _getTypeColor(type, isDark),
                        ),
                      ),
                    )
                  : Icon(
                      _getTypeIcon(type),
                      size: 32.sp,
                      color: _getTypeColor(type, isDark),
                    ),
            ),

            SizedBox(width: 12.w),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Type Badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
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
                          color: _getTypeColor(type, isDark).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8.r),
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

                  SizedBox(height: 4.h),

                  // Content Preview
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 8.h),

                  // Badges and Date
                  Row(
                    children: [
                      if (showOnLogin)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.login,
                                size: 10.sp,
                                color: Colors.purple,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'LOGIN',
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.purple,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (showOnLogin) SizedBox(width: 6.w),
                      if (date != null)
                        Text(
                          DateFormat('MMM dd, yyyy').format(date),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[500],
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          isActive ? Icons.visibility : Icons.visibility_off,
                          size: 18.sp,
                        ),
                        onPressed: () => _toggleActive(announcement),
                        tooltip: isActive ? 'Hide' : 'Show',
                        color: isActive ? Colors.green : Colors.orange,
                        padding: EdgeInsets.all(4.sp),
                        constraints: const BoxConstraints(),
                      ),
                      SizedBox(width: 4.w),
                      IconButton(
                        icon: Icon(Icons.edit, size: 18.sp),
                        onPressed: () => _editAnnouncement(announcement),
                        tooltip: 'Edit',
                        color: Colors.blue,
                        padding: EdgeInsets.all(4.sp),
                        constraints: const BoxConstraints(),
                      ),
                      SizedBox(width: 4.w),
                      IconButton(
                        icon: Icon(Icons.delete, size: 18.sp),
                        onPressed: () => _deleteAnnouncement(announcement),
                        tooltip: 'Delete',
                        color: Colors.red,
                        padding: EdgeInsets.all(4.sp),
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Dialog for creating/editing announcements
class _AnnouncementDialog extends StatefulWidget {
  const _AnnouncementDialog({
    this.initialTitle,
    this.initialContent,
    this.initialType,
    this.initialShowOnLogin,
    this.initialIsActive,
    this.existingImageUrl,
  });

  final String? initialTitle;
  final String? initialContent;
  final String? initialType;
  final bool? initialShowOnLogin;
  final bool? initialIsActive;
  final String? existingImageUrl;

  @override
  State<_AnnouncementDialog> createState() => _AnnouncementDialogState();
}

class _AnnouncementDialogState extends State<_AnnouncementDialog> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String? _selectedType;
  bool _showOnLogin = false;
  bool _isActive = true;
  String? _selectedImagePath;

  final List<String> _types = [
    'general',
    'important',
    'urgent',
    'event',
    'reminder',
    'success',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _contentController =
        TextEditingController(text: widget.initialContent ?? '');

    // Ensure the selected type is valid, default to 'general' if not in list
    final initialType = widget.initialType ?? 'general';
    _selectedType = _types.contains(initialType) ? initialType : 'general';

    _showOnLogin = widget.initialShowOnLogin ?? false;
    _isActive = widget.initialIsActive ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImagePath = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialTitle == null
            ? 'Create Announcement'
            : 'Edit Announcement',
        style: TextStyle(fontSize: 16.sp),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextField(
                controller: _titleController,
                style: TextStyle(fontSize: 13.sp),
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(fontSize: 12.sp),
                  border: const OutlineInputBorder(),
                ),
                maxLength: 200,
              ),

              SizedBox(height: 16.h),

              // Content
              TextField(
                controller: _contentController,
                style: TextStyle(fontSize: 13.sp),
                decoration: InputDecoration(
                  labelText: 'Content',
                  labelStyle: TextStyle(fontSize: 12.sp),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 5,
                maxLength: 1000,
              ),

              SizedBox(height: 16.h),

              // Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedType,
                style: TextStyle(
                    fontSize: 13.sp,
                    color: Theme.of(context).textTheme.bodyLarge?.color,),
                decoration: InputDecoration(
                  labelText: 'Type',
                  labelStyle: TextStyle(fontSize: 12.sp),
                  border: const OutlineInputBorder(),
                ),
                items: _types.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toUpperCase(),
                        style: TextStyle(fontSize: 12.sp),),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
              ),

              SizedBox(height: 16.h),

              // Image Picker
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Image (Optional)',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  if (_selectedImagePath != null ||
                      widget.existingImageUrl != null)
                    Container(
                      height: 120.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: _selectedImagePath != null
                            ? Image.file(
                                File(_selectedImagePath!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image),
                              )
                            : CachedNetworkImage(
                                imageUrl: widget.existingImageUrl!,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.broken_image),
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                      ),
                    ),
                  SizedBox(height: 8.h),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(Icons.image, size: 16.sp),
                    label: Text(
                      _selectedImagePath != null ||
                              widget.existingImageUrl != null
                          ? 'Change Image'
                          : 'Add Image',
                      style: TextStyle(fontSize: 12.sp),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Show on Login
              SwitchListTile(
                title: Text('Show on Login', style: TextStyle(fontSize: 13.sp)),
                subtitle: Text(
                  'Display this announcement when users log in',
                  style: TextStyle(fontSize: 11.sp),
                ),
                value: _showOnLogin,
                onChanged: (value) {
                  setState(() {
                    _showOnLogin = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),

              // Is Active
              SwitchListTile(
                title: Text('Active', style: TextStyle(fontSize: 13.sp)),
                subtitle: Text(
                  'Make this announcement visible to users',
                  style: TextStyle(fontSize: 11.sp),
                ),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(fontSize: 13.sp)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a title')),
              );
              return;
            }

            if (_contentController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter content')),
              );
              return;
            }

            Navigator.of(context).pop({
              'title': _titleController.text.trim(),
              'content': _contentController.text.trim(),
              'type': _selectedType,
              'showOnLogin': _showOnLogin,
              'isActive': _isActive,
              'imagePath': _selectedImagePath,
            });
          },
          child: Text('Save', style: TextStyle(fontSize: 13.sp)),
        ),
      ],
    );
  }
}
