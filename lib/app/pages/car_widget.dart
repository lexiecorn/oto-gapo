import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/profile/bloc/profile_cubit.dart';
import 'package:otogapo/utils/car_logo_helper.dart';
import 'package:otogapo_core/otogapo_core.dart';

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
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _carAnimationController,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _carAnimationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _carAnimationController,
        curve: const Interval(0.3, 1, curve: Curves.easeOutBack),
      ),
    );

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

  String _capitalizeCarName(String carName) {
    return carName.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Builds the car manufacturer logo widget with fallback handling
  Widget _buildCarLogo(String make) {
    final logoUrl = CarLogoHelper.getCarLogoSource(make);

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          logoUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to car icon if logo fails to load
            return Icon(
              Icons.directions_car,
              size: 20,
              color: Colors.grey[600],
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 300.ms, duration: 600.ms)
        .scale(delay: 350.ms, duration: 400.ms, curve: Curves.easeOutBack);
  }

  Future<List<String>> _getCarImageUrls() async {
    try {
      if (widget.state.vehicles.isEmpty) return [];
      final vehicle = widget.state.vehicles.first;
      final photos = vehicle.photos ?? <String>[];

      // Convert PocketBase filenames to full URLs
      final pocketbaseUrl = FlavorConfig.instance.variables['pocketbaseUrl'] as String;
      final vehicleId = vehicle.id;

      return photos.where((p) => p.isNotEmpty).map((filename) {
        if (filename.startsWith('http')) {
          return filename; // Already a full URL
        }
        return '$pocketbaseUrl/api/files/vehicles/$vehicleId/$filename';
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    // No Firebase listing; images come from PocketBase vehicle.photos

    Future<String?> _resolvePrimaryPhotoUrl() async {
      try {
        if (widget.state.vehicles.isEmpty) return null;
        final vehicle = widget.state.vehicles.first;
        final primary = vehicle.primaryPhoto;
        if (primary == null || primary.isEmpty) return null;

        // Convert PocketBase filename to full URL
        if (primary.startsWith('http')) {
          return primary; // Already a full URL
        }

        final pocketbaseUrl = FlavorConfig.instance.variables['pocketbaseUrl'] as String;
        return '$pocketbaseUrl/api/files/vehicles/${vehicle.id}/$primary';
      } catch (_) {
        return null;
      }
    }

    final mainImageFuture = _resolvePrimaryPhotoUrl();

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
                child: SingleChildScrollView(
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
                                // Car name with manufacturer logo
                                Row(
                                  children: [
                                    // Manufacturer logo
                                    if (widget.state.vehicles.isNotEmpty)
                                      _buildCarLogo(widget.state.vehicles.first.make),
                                    if (widget.state.vehicles.isNotEmpty) const SizedBox(width: 8),
                                    // Car name
                                    Expanded(
                                      child: Text(
                                        widget.state.vehicles.isNotEmpty
                                            ? _capitalizeCarName(
                                                '${widget.state.vehicles.first.make} ${widget.state.vehicles.first.model}')
                                            : 'No Vehicle',
                                        style: OpstechTextTheme.heading2.copyWith(
                                          color: Colors.black87,
                                          fontSize: 22.sp,
                                          fontWeight: FontWeight.w900,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      )
                                          .animate()
                                          .fadeIn(delay: 400.ms, duration: 600.ms)
                                          .slideX(begin: -0.3, duration: 600.ms),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                if (widget.state.vehicles.isNotEmpty) ...[
                                  Text(
                                    'Plate Number: ${widget.state.vehicles.first.plateNumber}',
                                    style: OpstechTextTheme.regular.copyWith(
                                      color: Colors.black54,
                                      fontSize: 14.sp,
                                    ),
                                  )
                                      .animate()
                                      .fadeIn(delay: 500.ms, duration: 600.ms)
                                      .slideX(begin: -0.3, duration: 600.ms),
                                  Text(
                                    'Color: ${widget.state.vehicles.first.color}',
                                    style: OpstechTextTheme.regular.copyWith(
                                      color: Colors.black54,
                                      fontSize: 14.sp,
                                    ),
                                  )
                                      .animate()
                                      .fadeIn(delay: 600.ms, duration: 600.ms)
                                      .slideX(begin: -0.3, duration: 600.ms),
                                  Text(
                                    'Year: ${widget.state.vehicles.first.year}',
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
                                  )
                                      .animate()
                                      .fadeIn(delay: 800.ms, duration: 800.ms)
                                      .scale(delay: 900.ms, duration: 600.ms, curve: Curves.easeOutBack);
                                }
                                // Fallback to placeholder icon if no main image exists
                                return Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.directions_car,
                                    size: 60,
                                    color: Colors.grey[600],
                                  ),
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
                            // Show placeholder if no car images exist
                            return Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.photo_library_outlined,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No vehicle photos',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
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
      ),
    );
  }
}
