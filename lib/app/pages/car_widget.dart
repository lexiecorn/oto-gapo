import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:otogapo/app/modules/profile/bloc/profile_cubit.dart';
import 'package:otogapo_core/otogapo_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CarWidget extends StatefulWidget {
  const CarWidget({
    required this.state,
    super.key,
  });
  final ProfileState state;

  @override
  State<CarWidget> createState() => _CarWidgetState();
}

class _CarWidgetState extends State<CarWidget> with TickerProviderStateMixin {
  late AnimationController _carAnimationController;
  late AnimationController _imageAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _carAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _imageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _carAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _carAnimationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _carAnimationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
    ));

    // Start animations with delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _carAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _carAnimationController.dispose();
    _imageAnimationController.dispose();
    super.dispose();
  }

  Future<List<String>> _getCarImageUrls() async {
    try {
      final userId = widget.state.user.uid;
      if (userId == null || userId.isEmpty) {
        print('CarWidget: User ID is null or empty');
        return [];
      }

      print('CarWidget: Fetching car images for user: $userId');
      final List<String> imageUrls = [];

      // Try to get 4 car images from Firebase Storage
      for (int i = 1; i <= 4; i++) {
        try {
          final imagePath = 'users/$userId/images/cars/$i.png';
          print('CarWidget: Trying to fetch image: $imagePath');
          final storageRef = FirebaseStorage.instance.ref().child(imagePath);
          final url = await storageRef.getDownloadURL();
          print('CarWidget: Successfully fetched image $i: $url');
          imageUrls.add(url);
        } catch (e) {
          print('CarWidget: Failed to fetch image $i: $e');
          // If this specific image doesn't exist, skip it
          continue;
        }
      }

      print('CarWidget: Total images found: ${imageUrls.length}');
      return imageUrls;
    } catch (e) {
      print('CarWidget: Error in _getCarImageUrls: $e');
      // If there's an error, return empty list
      return [];
    }
  }

  // Method to list all files in the cars directory (for debugging)
  Future<List<String>> _listCarImages() async {
    try {
      final userId = widget.state.user.uid;
      if (userId == null || userId.isEmpty) {
        return [];
      }

      print('CarWidget: Listing files in cars directory for user: $userId');
      final carsRef = FirebaseStorage.instance.ref().child('users/$userId/images/cars/');

      final result = await carsRef.listAll();
      final List<String> fileNames = [];

      for (var item in result.items) {
        fileNames.add(item.name);
        print('CarWidget: Found file: ${item.name}');
      }

      return fileNames;
    } catch (e) {
      print('CarWidget: Error listing car images: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debug: List available car images when widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listCarImages();
    });

    final userId = widget.state.user.uid;
    final mainImageFuture = (userId != null && userId.isNotEmpty)
        ? FirebaseStorage.instance.ref().child('users/$userId/images/cars/main.png').getDownloadURL()
        : Future.value(null);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: SizedBox(
            width: double.infinity,
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 6,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[300],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main image and vehicle info side by side
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Vehicle information (left) with staggered animation
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.state.user.vehicle.isNotEmpty ? widget.state.user.vehicle.first.make : 'No Vehicle'} '
                                '${widget.state.user.vehicle.isNotEmpty ? widget.state.user.vehicle.first.model : ''}',
                                style: OpstechTextTheme.heading2.copyWith(
                                  color: Colors.black87,
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w900,
                                ),
                              ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideX(begin: -0.3, duration: 600.ms),
                              const SizedBox(height: 5),
                              if (widget.state.user.vehicle.isNotEmpty) ...[
                                Text(
                                  'Plate Number: ${widget.state.user.vehicle.first.plateNumber}',
                                  style: OpstechTextTheme.regular.copyWith(
                                    color: Colors.black54,
                                    fontSize: 14.sp,
                                  ),
                                )
                                    .animate()
                                    .fadeIn(delay: 500.ms, duration: 600.ms)
                                    .slideX(begin: -0.3, duration: 600.ms),
                                Text(
                                  'Color: ${widget.state.user.vehicle.first.color}',
                                  style: OpstechTextTheme.regular.copyWith(
                                    color: Colors.black54,
                                    fontSize: 14.sp,
                                  ),
                                )
                                    .animate()
                                    .fadeIn(delay: 600.ms, duration: 600.ms)
                                    .slideX(begin: -0.3, duration: 600.ms),
                                Text(
                                  'Year: ${widget.state.user.vehicle.first.year}',
                                  style: OpstechTextTheme.regular.copyWith(
                                    color: Colors.black54,
                                    fontSize: 14.sp,
                                  ),
                                )
                                    .animate()
                                    .fadeIn(delay: 700.ms, duration: 600.ms)
                                    .slideX(begin: -0.3, duration: 600.ms),
                              ] else ...[
                                Text(
                                  'No vehicle information available',
                                  style: OpstechTextTheme.regular.copyWith(
                                    color: Colors.black54,
                                    fontSize: 14.sp,
                                  ),
                                )
                                    .animate()
                                    .fadeIn(delay: 500.ms, duration: 600.ms)
                                    .slideX(begin: -0.3, duration: 600.ms),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Main car image (right, bigger) with enhanced animation
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: FutureBuilder<String?>(
                            future: mainImageFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 1500.ms);
                              }
                              if (snapshot.hasData && snapshot.data != null) {
                                return OpstechExtendedImageNetwork(
                                  img: snapshot.data!,
                                  width: 140,
                                  height: 140,
                                  borderrRadius: 10,
                                )
                                    .animate()
                                    .fadeIn(delay: 800.ms, duration: 800.ms)
                                    .scale(delay: 900.ms, duration: 600.ms, curve: Curves.easeOutBack);
                              }
                              // Fallback to default image if no main image exists
                              return Image.asset(
                                'assets/images/vios.jpg',
                                width: 140,
                                height: 140,
                                fit: BoxFit.cover,
                              )
                                  .animate()
                                  .fadeIn(delay: 800.ms, duration: 800.ms)
                                  .scale(delay: 900.ms, duration: 600.ms, curve: Curves.easeOutBack);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Car images grid with enhanced animation
                    FutureBuilder<List<String>>(
                      future: _getCarImageUrls(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 1500.ms);
                        }

                        final imageUrls = snapshot.data ?? [];

                        if (imageUrls.isEmpty) {
                          // Show default image if no car images exist
                          return Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                'assets/images/vios.jpg',
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ).animate().fadeIn(delay: 1000.ms, duration: 800.ms).slideY(begin: 0.2, duration: 800.ms);
                        }

                        // Display car images in a 2x2 grid with staggered animations
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1.2,
                          ),
                          itemCount: imageUrls.length,
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: OpstechExtendedImageNetwork(
                                img: imageUrls[index],
                                width: double.infinity,
                                height: double.infinity,
                                borderrRadius: 10,
                              ),
                            )
                                .animate()
                                .fadeIn(delay: (1000 + (index * 200)).ms, duration: 600.ms)
                                .slideY(begin: 0.3, duration: 600.ms)
                                .scale(delay: (1100 + (index * 200)).ms, duration: 400.ms, curve: Curves.easeOutBack);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
