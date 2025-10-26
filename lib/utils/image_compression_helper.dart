import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// Helper class for compressing images before upload to PocketBase
class ImageCompressionHelper {
  /// Maximum file size in bytes (3MB to match PocketBase settings)
  static const int maxFileSizeBytes = 3242880;

  /// Maximum image width in pixels
  static const int maxImageWidth = 1920;

  /// Target quality for compression (0-100)
  static const int compressionQuality = 85;

  /// Compresses an image file if it exceeds the maximum file size
  ///
  /// Returns the path to the compressed image, or the original path if
  /// compression was not needed.
  static Future<String> compressImageIfNeeded(String imagePath) async {
    try {
      final file = File(imagePath);
      final fileSize = await file.length();

      debugPrint('Original image size: ${fileSize / 1024 / 1024} MB');

      // If file is already within limit, return original
      if (fileSize <= maxFileSizeBytes) {
        debugPrint('Image is within size limit, no compression needed');
        return imagePath;
      }

      debugPrint('Compressing image...');

      // Get temporary directory for compressed image
      final tempDir = await getTemporaryDirectory();
      final targetPath =
          '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // First, check if we need to resize
      final originalImage = img.decodeImage(await file.readAsBytes());
      if (originalImage == null) {
        debugPrint('Failed to decode image');
        return imagePath;
      }

      int targetWidth = originalImage.width;
      int targetHeight = originalImage.height;

      // Resize if width exceeds maximum
      if (originalImage.width > maxImageWidth) {
        targetWidth = maxImageWidth;
        targetHeight =
            (originalImage.height * maxImageWidth / originalImage.width)
                .round();
        debugPrint(
            'Resizing from ${originalImage.width}x${originalImage.height} '
            'to ${targetWidth}x$targetHeight');
      }

      // Compress the image
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: compressionQuality,
        minWidth: targetWidth,
        minHeight: targetHeight,
        format: CompressFormat.jpeg,
      );

      if (result == null) {
        debugPrint('Compression failed');
        return imagePath;
      }

      final compressedSize = await result.length();
      debugPrint('Compressed image size: ${compressedSize / 1024 / 1024} MB');

      // If still too large, compress more aggressively
      if (compressedSize > maxFileSizeBytes) {
        debugPrint('Still too large, compressing more aggressively...');
        return await _compressAggressively(imagePath, targetPath);
      }

      return result.path;
    } catch (e, st) {
      debugPrint('Error compressing image: $e');
      debugPrint('Stack trace: $st');
      // Return original path if compression fails
      return imagePath;
    }
  }

  /// Compresses an image more aggressively by reducing quality further
  static Future<String> _compressAggressively(
    String originalPath,
    String targetPath,
  ) async {
    try {
      final file = File(originalPath);
      final tempDir = await getTemporaryDirectory();
      final aggressivePath =
          '${tempDir.path}/aggressive_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Try with lower quality
      var quality = 75;
      XFile? result;

      while (quality >= 50) {
        result = await FlutterImageCompress.compressAndGetFile(
          file.absolute.path,
          aggressivePath,
          quality: quality,
          minWidth: maxImageWidth,
          format: CompressFormat.jpeg,
        );

        if (result != null) {
          final size = await result.length();
          debugPrint(
              'Compressed at quality $quality: ${size / 1024 / 1024} MB');

          if (size <= maxFileSizeBytes) {
            return result.path;
          }
        }

        quality -= 10;
      }

      // If we still can't compress enough, return what we have
      return result?.path ?? originalPath;
    } catch (e) {
      debugPrint('Error in aggressive compression: $e');
      return originalPath;
    }
  }

  /// Gets the file size of an image in megabytes
  static Future<double> getFileSizeMB(String imagePath) async {
    try {
      final file = File(imagePath);
      final size = await file.length();
      return size / 1024 / 1024;
    } catch (e) {
      debugPrint('Error getting file size: $e');
      return 0;
    }
  }

  /// Checks if an image needs compression
  static Future<bool> needsCompression(String imagePath) async {
    try {
      final file = File(imagePath);
      final size = await file.length();
      return size > maxFileSizeBytes;
    } catch (e) {
      debugPrint('Error checking if compression needed: $e');
      return false;
    }
  }
}
