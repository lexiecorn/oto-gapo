import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:otogapo/services/pocketbase_service.dart';
import 'package:pocketbase/pocketbase.dart';

class GalleryManagementPage extends StatefulWidget {
  const GalleryManagementPage({super.key});

  @override
  State<GalleryManagementPage> createState() => _GalleryManagementPageState();
}

class _GalleryManagementPageState extends State<GalleryManagementPage> {
  final PocketBaseService _pbService = PocketBaseService();
  List<RecordModel> _galleryImages = [];
  bool _isLoading = true;
  bool _isAdmin = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _checkAdminAndLoadImages();
  }

  Future<void> _checkAdminAndLoadImages() async {
    try {
      final authState = context.read<AuthBloc>().state;

      if (authState.user != null) {
        _currentUserId = authState.user!.id;
        final userRecord = await _pbService.getUser(authState.user!.id);
        final userData = userRecord.data;

        setState(() {
          _isAdmin = userData['membership_type'] == 1 || userData['membership_type'] == 2;
        });

        if (_isAdmin) {
          await _loadGalleryImages();
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error checking admin status: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadGalleryImages() async {
    try {
      final images = await _pbService.getAllGalleryImages();
      setState(() {
        _galleryImages = images;
      });
    } catch (e) {
      print('Error loading gallery images: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading images: $e')),
        );
      }
    }
  }

  Future<void> _uploadImage() async {
    if (_currentUserId == null) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    // Show dialog to collect metadata
    if (!mounted) return;
    final metadata = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _ImageMetadataDialog(),
    );

    if (metadata == null) return;

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

      // Get next display order
      final nextOrder = _galleryImages.isEmpty
          ? 0
          : (_galleryImages
                  .map((e) => e.data['display_order'] as int?)
                  .whereType<int>()
                  .fold<int>(0, (max, val) => val > max ? val : max) +
              1);

      await _pbService.createGalleryImage(
        imageFilePath: image.path,
        uploadedBy: _currentUserId!,
        title: metadata['title'] as String?,
        description: metadata['description'] as String?,
        displayOrder: nextOrder,
        isActive: metadata['isActive'] as bool? ?? true,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      await _loadGalleryImages();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded successfully')),
      );
    } catch (e) {
      print('Error uploading image: $e');
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
    }
  }

  Future<void> _editImage(RecordModel image) async {
    final metadata = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _ImageMetadataDialog(
        initialTitle: image.data['title'] as String?,
        initialDescription: image.data['description'] as String?,
        initialIsActive: image.data['is_active'] as bool? ?? true,
        initialDisplayOrder: image.data['display_order'] as int?,
      ),
    );

    if (metadata == null) return;

    try {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await _pbService.updateGalleryImage(
        imageId: image.id,
        title: metadata['title'] as String?,
        description: metadata['description'] as String?,
        displayOrder: metadata['displayOrder'] as int?,
        isActive: metadata['isActive'] as bool?,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      await _loadGalleryImages();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image updated successfully')),
      );
    } catch (e) {
      print('Error updating image: $e');
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating image: $e')),
      );
    }
  }

  Future<void> _deleteImage(RecordModel image) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image'),
        content: const Text(
          'Are you sure you want to delete this image? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
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

      await _pbService.deleteGalleryImage(image.id);

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      await _loadGalleryImages();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image deleted successfully')),
      );
    } catch (e) {
      print('Error deleting image: $e');
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting image: $e')),
      );
    }
  }

  Future<void> _toggleActive(RecordModel image) async {
    try {
      final currentActive = image.data['is_active'] as bool? ?? true;
      await _pbService.updateGalleryImage(
        imageId: image.id,
        isActive: !currentActive,
      );

      await _loadGalleryImages();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            currentActive ? 'Image hidden from carousel' : 'Image shown in carousel',
          ),
        ),
      );
    } catch (e) {
      print('Error toggling active status: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
          title: const Text('Gallery Management'),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGalleryImages,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _galleryImages.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No gallery images yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to upload your first image',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: _galleryImages.length,
              itemBuilder: (context, index) {
                final image = _galleryImages[index];
                final imageUrl = _pbService.getGalleryImageUrl(image);
                final title = image.data['title'] as String? ?? 'Untitled';
                final displayOrder = image.data['display_order'] as int? ?? 0;
                final isActive = image.data['is_active'] as bool? ?? true;

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isActive ? Colors.green : Colors.red,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.grey.shade300,
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 48,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '#$displayOrder',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            if (!isActive)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.visibility_off,
                                      color: Colors.white,
                                      size: 48,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isActive ? Icons.visibility : Icons.visibility_off,
                                    size: 20,
                                  ),
                                  onPressed: () => _toggleActive(image),
                                  tooltip: isActive ? 'Hide' : 'Show',
                                  color: isActive ? Colors.green : Colors.orange,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () => _editImage(image),
                                  tooltip: 'Edit',
                                  color: Colors.blue,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20),
                                  onPressed: () => _deleteImage(image),
                                  tooltip: 'Delete',
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploadImage,
        icon: const Icon(Icons.add_photo_alternate),
        label: const Text('Upload'),
      ),
    );
  }
}

class _ImageMetadataDialog extends StatefulWidget {
  const _ImageMetadataDialog({
    this.initialTitle,
    this.initialDescription,
    this.initialIsActive,
    this.initialDisplayOrder,
  });

  final String? initialTitle;
  final String? initialDescription;
  final bool? initialIsActive;
  final int? initialDisplayOrder;

  @override
  State<_ImageMetadataDialog> createState() => _ImageMetadataDialogState();
}

class _ImageMetadataDialogState extends State<_ImageMetadataDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _displayOrderController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _descriptionController = TextEditingController(text: widget.initialDescription ?? '');
    _displayOrderController = TextEditingController(
      text: widget.initialDisplayOrder?.toString() ?? '',
    );
    _isActive = widget.initialIsActive ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _displayOrderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialTitle == null ? 'Upload Image' : 'Edit Image',
        style: const TextStyle(fontSize: 18),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                labelText: 'Title (optional)',
                labelStyle: TextStyle(fontSize: 12),
                border: OutlineInputBorder(),
              ),
              maxLength: 200,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                labelStyle: TextStyle(fontSize: 12),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _displayOrderController,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                labelText: 'Display Order (optional)',
                labelStyle: TextStyle(fontSize: 12),
                helperText: 'Lower numbers appear first',
                helperStyle: TextStyle(fontSize: 10),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Active', style: TextStyle(fontSize: 14)),
              subtitle: const Text('Show in carousel', style: TextStyle(fontSize: 12)),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(fontSize: 14)),
        ),
        ElevatedButton(
          onPressed: () {
            final metadata = <String, dynamic>{
              'title': _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
              'description': _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
              'isActive': _isActive,
            };

            // Only add display order if it's provided and valid
            if (_displayOrderController.text.trim().isNotEmpty) {
              final order = int.tryParse(_displayOrderController.text.trim());
              if (order != null) {
                metadata['displayOrder'] = order;
              }
            }

            Navigator.of(context).pop(metadata);
          },
          child: const Text('Save', style: TextStyle(fontSize: 14)),
        ),
      ],
    );
  }
}
