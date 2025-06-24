import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/profile/bloc/profile_cubit.dart';
import 'package:otogapo_core/otogapo_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CarWidget extends StatelessWidget {
  const CarWidget({
    required this.state,
    super.key,
  });
  final ProfileState state;

  Future<List<String>> _getCarImageUrls() async {
    try {
      final userId = state.user.uid;
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
      final userId = state.user.uid;
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

    final userId = state.user.uid;
    final mainImageFuture = (userId != null && userId.isNotEmpty)
        ? FirebaseStorage.instance.ref().child('users/$userId/images/cars/main.png').getDownloadURL()
        : Future.value(null);

    return SizedBox(
      width: double.infinity,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 6,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[300],
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
                  // Vehicle information (left)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${state.user.vehicle.isNotEmpty ? state.user.vehicle.first.make : 'No Vehicle'} '
                          '${state.user.vehicle.isNotEmpty ? state.user.vehicle.first.model : ''}',
                          style: OpstechTextTheme.heading2.copyWith(
                            color: Colors.black87,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        if (state.user.vehicle.isNotEmpty) ...[
                          Text(
                            'Plate Number: ${state.user.vehicle.first.plateNumber}',
                            style: OpstechTextTheme.regular.copyWith(
                              color: Colors.black54,
                              fontSize: 14.sp,
                            ),
                          ),
                          Text(
                            'Color: ${state.user.vehicle.first.color}',
                            style: OpstechTextTheme.regular.copyWith(
                              color: Colors.black54,
                              fontSize: 14.sp,
                            ),
                          ),
                          Text(
                            'Year: ${state.user.vehicle.first.year}',
                            style: OpstechTextTheme.regular.copyWith(
                              color: Colors.black54,
                              fontSize: 14.sp,
                            ),
                          ),
                        ] else ...[
                          Text(
                            'No vehicle information available',
                            style: OpstechTextTheme.regular.copyWith(
                              color: Colors.black54,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Main car image (right, bigger)
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
                          );
                        }
                        if (snapshot.hasData && snapshot.data != null) {
                          return OpstechExtendedImageNetwork(
                            img: snapshot.data!,
                            width: 140,
                            height: 140,
                            borderrRadius: 10,
                          );
                        }
                        // Fallback to default image if no main image exists
                        return Image.asset(
                          'assets/images/vios.jpg',
                          width: 140,
                          height: 140,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Car images grid
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
                    );
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
                    );
                  }

                  // Display car images in a 2x2 grid
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
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
