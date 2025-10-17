import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class OpstechExtendedImageNetwork extends StatelessWidget {
  ///
  const OpstechExtendedImageNetwork({
    required this.img,
    required this.width,
    required this.height,
    this.borderrRadius = 10,
    this.border, // Optional border
    super.key,
  });

  ///
  final String img;

  ///
  final double width;

  ///
  final double height;

  ///
  final double borderrRadius;

  ///
  final Border? border; // Optional border parameter

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLightbox(context), // Opens lightbox on tap
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderrRadius),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderrRadius),
            border: border, // Apply optional border
          ),
          child: ExtendedImage.network(
            img,
            width: width,
            height: height,
            fit: BoxFit.cover,
            enableMemoryCache: false,
            clearMemoryCacheWhenDispose: true,
            loadStateChanged: (ExtendedImageState state) {
              switch (state.extendedImageLoadState) {
                case LoadState.loading:
                  return const Center(
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  );

                case LoadState.completed:
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(borderrRadius),
                    child: ExtendedRawImage(
                      image: state.extendedImageInfo?.image,
                      fit: BoxFit.cover,
                    ),
                  );

                case LoadState.failed:
                  return GestureDetector(
                    onTap: () {
                      state.reLoadImage();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.grey.shade200,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Tap to reload', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
              }
            },
          ),
        ),
      ),
    );
  }

  /// **Opens the Lightbox Dialog with Scroll & Tap Outside to Close**
  void _showLightbox(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(), // Tap outside to close
          child: Scaffold(
            backgroundColor: Colors.black.withOpacity(0.9),
            body: Center(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 3,
                child: GestureDetector(
                  onTap: () {}, // Prevents accidental closing when tapping the image
                  child: SingleChildScrollView(
                    child: ExtendedImage.network(
                      img,
                      fit: BoxFit.contain,
                      mode: ExtendedImageMode.gesture, // Enables pinch-to-zoom
                      initGestureConfigHandler: (state) {
                        return GestureConfig(
                          minScale: 1,
                          maxScale: 3,
                          animationMinScale: 0.8,
                          animationMaxScale: 3.5,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

///
class OpstechExtendedImageAsset extends StatelessWidget {
  ///
  const OpstechExtendedImageAsset({
    required this.img,
    required this.width,
    required this.height,
    this.borderrRadius = 10,
    super.key,
  });

  ///
  final String img;

  ///
  final double width;

  ///
  final double height;

  ///
  final double borderrRadius;

  @override
  Widget build(BuildContext context) {
    return ExtendedImage.asset(
      img,
      borderRadius: BorderRadius.circular(borderrRadius),
      width: width,
      height: height,
      fit: BoxFit.fitHeight,
      enableMemoryCache: false,
      clearMemoryCacheWhenDispose: true,
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return const Center(
              child: Text('Loading'),
            );

          case LoadState.completed:
            return ExtendedRawImage(
              image: state.extendedImageInfo?.image,
            );

          case LoadState.failed:
            return GestureDetector(
              onTap: () {
                state.reLoadImage();
              },
              child: Container(
                alignment: Alignment.center,
                color: Colors.grey.shade200,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap to reload',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
        }
      },
    );
  }
}
