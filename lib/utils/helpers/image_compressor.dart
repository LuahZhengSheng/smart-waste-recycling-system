import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageCompressor {
  static final Uuid _uuid = const Uuid();

  static const int imageQuality = 85;
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png', 'webp', 'heic'];

  /// Compress image and convert to WebP format
  static Future<File> compressAndConvertToWebP(File imageFile) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath = '${tempDir.path}/${_uuid.v4()}.webp';

      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        format: CompressFormat.webp,
        quality: imageQuality,
        minWidth: 1080,
        minHeight: 1080,
        autoCorrectionAngle: true,
      );

      if (result == null) {
        throw 'Failed to compress image';
      }

      return File(result.path);
    } catch (e) {
      print('Image compression failed: $e, using original file');
      return imageFile;
    }
  }

  /// Check if file is a valid image format
  static bool isValidImageFormat(File file) {
    final path = file.path.toLowerCase();
    final extension = path.split('.').last;
    return allowedImageFormats.contains(extension);
  }
}