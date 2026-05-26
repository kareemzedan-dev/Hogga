import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImageHelper {
  /// Compresses an image file. 
  /// Returns the compressed [File] or the original if compression fails or isn't needed.
  static Future<File> compressImage(File file, {int quality = 80}) async {
    try {
      final String filePath = file.path;
      final String extension = p.extension(filePath).toLowerCase();

      // Only compress images
      if (!['.jpg', '.jpeg', '.png', '.webp'].contains(extension)) {
        return file;
      }

      // Skip very small files
      final int sizeInBytes = await file.length();
      if (sizeInBytes < 200 * 1024) { // Less than 200KB
        return file;
      }

      final String targetPath = p.join(
        (await getTemporaryDirectory()).path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}${extension == '.png' ? '.jpg' : extension}',
      );

      final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        format: extension == '.png' ? CompressFormat.jpeg : _getFormat(extension),
      );

      if (compressedFile == null) return file;

      return File(compressedFile.path);
    } catch (e) {
      debugPrint('Image Compression Error: $e');
      return file;
    }
  }

  static CompressFormat _getFormat(String extension) {
    switch (extension) {
      case '.webp':
        return CompressFormat.webp;
      case '.heic':
        return CompressFormat.heic;
      default:
        return CompressFormat.jpeg;
    }
  }

  static bool isImage(String path) {
    final String extension = p.extension(path).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.webp', '.heic'].contains(extension);
  }

  static String sanitizeUrl(String url) {
    if (url.isEmpty) return "";
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    // Remove leading slash if present
    final cleanPath = url.startsWith('/') ? url.substring(1) : url;
    return "https://mashora.believe-agency.net/public/$cleanPath";
  }
}

// Global debugPrint helper if not imported
void debugPrint(String message) {
  print('[ImageHelper] $message');
}
