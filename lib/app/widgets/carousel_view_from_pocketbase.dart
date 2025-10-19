import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:otogapo/services/pocketbase_service.dart';
import 'package:otogapo_core/otogapo_core.dart';
import 'package:pocketbase/pocketbase.dart';

class CarouselViewFromPocketbase extends StatefulWidget {
  const CarouselViewFromPocketbase({super.key});

  @override
  State<CarouselViewFromPocketbase> createState() => _CarouselViewFromPocketbaseState();
}

class _CarouselViewFromPocketbaseState extends State<CarouselViewFromPocketbase> {
  List<RecordModel> _galleryImages = [];
  bool _isLoading = true;
  bool _hasTriedFetching = false;
  String? _errorMessage;
  final PocketBaseService _pbService = PocketBaseService();

  @override
  void initState() {
    super.initState();
    // Don't fetch immediately - wait for authentication
  }

  void _checkAuthAndFetch() {
    final authState = context.read<AuthBloc>().state;

    // Only fetch if user is authenticated and we haven't tried yet
    if (authState.authStatus == AuthStatus.authenticated && authState.user != null && !_hasTriedFetching) {
      _hasTriedFetching = true;
      _fetchImagesFromPocketBase();
    }
  }

  Future<void> _fetchImagesFromPocketBase() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final images = await _pbService.getActiveGalleryImages();

      setState(() {
        _galleryImages = images;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching gallery images: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load gallery images';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check authentication status and fetch data if ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndFetch();
    });

    // If user is not authenticated yet, show loading
    final authState = context.read<AuthBloc>().state;
    if (authState.authStatus != AuthStatus.authenticated || authState.user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _fetchImagesFromPocketBase,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_galleryImages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'No gallery images available',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: 250,
        autoPlay: true,
        enlargeCenterPage: true,
        aspectRatio: 1 / 1,
        autoPlayInterval: const Duration(seconds: 5),
      ),
      items: _galleryImages.map((imageRecord) {
        final imageUrl = _pbService.getGalleryImageUrl(imageRecord);
        final title = imageRecord.data['title'] as String?;

        return Builder(
          builder: (BuildContext context) {
            return Stack(
              children: [
                OpstechExtendedImageNetwork(
                  img: imageUrl,
                  width: 90.sw,
                  height: 300.h,
                  borderrRadius: 15.r,
                  border: Border.all(
                    color: Colors.white.withOpacity(.1),
                    width: 3,
                  ),
                ),
                if (title != null && title.isNotEmpty)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15.r),
                          bottomRight: Radius.circular(15.r),
                        ),
                      ),
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      }).toList(),
    );
  }
}
