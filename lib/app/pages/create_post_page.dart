import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:otogapo/app/modules/social_feed/bloc/feed_cubit.dart';
import 'package:otogapo/services/pocketbase_service.dart';
import 'package:otogapo/utils/text_parsing_utils.dart';

@RoutePage(name: 'CreatePostPageRouter')
class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _captionController = TextEditingController();
  final _imagePicker = ImagePicker();
  File? _selectedImage;
  bool _isUploading = false;
  List<String> _detectedHashtags = [];
  List<String> _detectedMentions = [];

  @override
  void initState() {
    super.initState();
    _captionController.addListener(_onCaptionChanged);
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _onCaptionChanged() {
    final caption = _captionController.text;
    final hashtags = TextParsingUtils.extractHashtags(caption);
    final mentions = TextParsingUtils.extractMentions(caption);

    if (hashtags.join(',') != _detectedHashtags.join(',') ||
        mentions.join(',') != _detectedMentions.join(',')) {
      setState(() {
        _detectedHashtags = hashtags;
        _detectedMentions = mentions;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _createPost() async {
    final caption = _captionController.text.trim();

    if (_selectedImage == null && caption.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add an image or caption')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final authState = context.read<AuthBloc>().state;
      final currentUserId = authState.user?.id ?? '';

      // Create a temporary FeedCubit for this operation
      final feedCubit = FeedCubit(
        pocketBaseService: PocketBaseService(),
        currentUserId: currentUserId,
      );

      await feedCubit.createPost(
        _captionController.text,
        _selectedImage!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully!')),
        );
        context.router.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating post: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _showImageSourceSelector() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text('Take Photo', style: TextStyle(fontSize: 14.sp)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text('Choose from Gallery',
                    style: TextStyle(fontSize: 14.sp)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        centerTitle: true,
        actions: [
          if (!_isUploading)
            TextButton(
              onPressed: _createPost,
              child: Text(
                'Post',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
        ],
      ),
      body: _isUploading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Creating post...'),
                  Text('Compressing image and uploading...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image preview or picker
                  if (_selectedImage == null)
                    GestureDetector(
                      onTap: _showImageSourceSelector,
                      child: Container(
                        height: 300.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: Colors.grey[400]!,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 64.sp,
                              color: Colors.grey[600],
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'Tap to select an image',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.file(
                            _selectedImage!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black54,
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedImage = null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                  SizedBox(height: 24.h),

                  // Caption input
                  Text(
                    'Caption',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: _captionController,
                    maxLines: 5,
                    maxLength: 2000,
                    decoration: const InputDecoration(
                      hintText: 'Write a caption... Use @mention and #hashtags',
                      border: OutlineInputBorder(),
                    ),
                    style: TextStyle(fontSize: 14.sp),
                  ),

                  // Detected hashtags and mentions
                  if (_detectedHashtags.isNotEmpty ||
                      _detectedMentions.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(top: 12.h),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_detectedHashtags.isNotEmpty) ...[
                            Text(
                              'Hashtags:',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Wrap(
                              spacing: 8.w,
                              children: _detectedHashtags.map((tag) {
                                return Chip(
                                  label: Text('#$tag'),
                                  labelStyle: TextStyle(fontSize: 11.sp),
                                );
                              }).toList(),
                            ),
                          ],
                          if (_detectedMentions.isNotEmpty) ...[
                            SizedBox(height: 8.h),
                            Text(
                              'Mentions:',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Wrap(
                              spacing: 8.w,
                              children: _detectedMentions.map((mention) {
                                return Chip(
                                  label: Text('@$mention'),
                                  labelStyle: TextStyle(fontSize: 11.sp),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),

                  SizedBox(height: 24.h),

                  // Info text
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 16.sp),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            _selectedImage != null
                                ? 'Images will be compressed to <1MB for faster loading'
                                : 'You can post text-only or add an image',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[700],
                            ),
                          ),
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
