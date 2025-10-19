import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// Utility class for compressing images for social feed
class ImageCompressionUtils {
  /// Maximum file size in bytes (1MB)
  static const int maxFileSizeBytes = 1024 * 1024; // 1MB

  /// Maximum width for images (720p)
  static const int maxWidth = 1280;

  /// Maximum height for images (720p)
  static const int maxHeight = 720;

  /// JPEG quality (0-100)
  static const int jpegQuality = 80;

  /// Compress image file to meet social feed requirements
  /// Target: <1MB file size, max 1280x720 resolution
  static Future<File> compressForSocialFeed(File imageFile) async {
    try {
      print('ImageCompression - Starting compression for: ${imageFile.path}');

      // Get image dimensions first
      final dimensions = await getImageDimensions(imageFile);
      print('ImageCompression - Original dimensions: ${dimensions['width']}x${dimensions['height']}');

      // Calculate target dimensions maintaining aspect ratio
      final targetDimensions = _calculateTargetDimensions(
        dimensions['width']!,
        dimensions['height']!,
      );
      print('ImageCompression - Target dimensions: ${targetDimensions['width']}x${targetDimensions['height']}');

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final targetPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Compress image
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: jpegQuality,
        minWidth: targetDimensions['width']!,
        minHeight: targetDimensions['height']!,
        format: CompressFormat.jpeg,
      );

      if (compressedFile == null) {
        throw Exception('Failed to compress image');
      }

      // Check file size
      final fileSize = await compressedFile.length();
      print('ImageCompression - Compressed file size: ${fileSize / 1024} KB');

      // If still too large, reduce quality further
      if (fileSize > maxFileSizeBytes) {
        print('ImageCompression - File still too large, reducing quality further');
        final furtherCompressed = await _compressWithReducedQuality(
          File(compressedFile.path),
          targetPath,
        );
        return furtherCompressed;
      }

      print('ImageCompression - Compression successful');
      return File(compressedFile.path);
    } catch (e) {
      print('ImageCompression - Error: $e');
      rethrow;
    }
  }

  /// Compress image bytes (alternative method)
  static Future<Uint8List> compressImageBytes(Uint8List bytes) async {
    try {
      // Decode image
      final image = img.decodeImage(bytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Calculate target dimensions
      final targetDimensions = _calculateTargetDimensions(
        image.width,
        image.height,
      );

      // Resize image
      final resized = img.copyResize(
        image,
        width: targetDimensions['width'],
        height: targetDimensions['height'],
      );

      // Encode as JPEG
      final compressed = img.encodeJpg(resized, quality: jpegQuality);

      return Uint8List.fromList(compressed);
    } catch (e) {
      print('ImageCompression - Error compressing bytes: $e');
      rethrow;
    }
  }

  /// Get image dimensions from file
  static Future<Map<String, int>> getImageDimensions(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      return {
        'width': image.width,
        'height': image.height,
      };
    } catch (e) {
      print('ImageCompression - Error getting dimensions: $e');
      rethrow;
    }
  }

  /// Calculate target dimensions maintaining aspect ratio
  static Map<String, int> _calculateTargetDimensions(int width, int height) {
    // If already within limits, return original dimensions
    if (width <= maxWidth && height <= maxHeight) {
      return {'width': width, 'height': height};
    }

    // Calculate aspect ratio
    final aspectRatio = width / height;

    int targetWidth;
    int targetHeight;

    if (aspectRatio > 1) {
      // Landscape orientation
      targetWidth = maxWidth;
      targetHeight = (maxWidth / aspectRatio).round();
    } else {
      // Portrait or square orientation
      targetHeight = maxHeight;
      targetWidth = (maxHeight * aspectRatio).round();
    }

    return {'width': targetWidth, 'height': targetHeight};
  }

  /// Compress with progressively reduced quality until under size limit
  static Future<File> _compressWithReducedQuality(
    File imageFile,
    String targetPath,
  ) async {
    int quality = 70; // Start with 70% quality
    const int qualityStep = 10;
    const int minQuality = 40;

    while (quality >= minQuality) {
      final compressed = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        '${targetPath}_q$quality.jpg',
        quality: quality,
        format: CompressFormat.jpeg,
      );

      if (compressed == null) {
        throw Exception('Failed to compress image');
      }

      final fileSize = await compressed.length();
      print('ImageCompression - Trying quality $quality: ${fileSize / 1024} KB');

      if (fileSize <= maxFileSizeBytes) {
        print('ImageCompression - Success with quality $quality');
        return File(compressed.path);
      }

      quality -= qualityStep;
    }

    // If still too large at minimum quality, use that anyway
    print('ImageCompression - Using minimum quality $minQuality');
    final finalCompressed = await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path,
      '${targetPath}_final.jpg',
      quality: minQuality,
      format: CompressFormat.jpeg,
    );

    if (finalCompressed == null) {
      throw Exception('Failed to compress image');
    }

    return File(finalCompressed.path);
  }

  /// Validate image file
  static Future<bool> validateImageFile(File file) async {
    try {
      // Check if file exists
      if (!await file.exists()) {
        return false;
      }

      // Check file size
      final fileSize = await file.length();
      if (fileSize == 0) {
        return false;
      }

      // Try to decode image
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      return image != null;
    } catch (e) {
      print('ImageCompression - Validation error: $e');
      return false;
    }
  }
}
