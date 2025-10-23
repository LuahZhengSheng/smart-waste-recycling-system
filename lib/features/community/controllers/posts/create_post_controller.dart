import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fyp/features/community/models/post_model.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../data/repositories/community/post_repository.dart';
import '../../screens/create_post/widgets/custom_camera_screen.dart';

class MediaFile {
  final String id;
  final File file;
  final MediaType type;
  VideoPlayerController? videoController;

  MediaFile({
    required this.id,
    required this.file,
    required this.type,
    this.videoController,
  });

  Future<void> dispose() async {
    await videoController?.dispose();
  }
}

enum MediaType { image, video }

class CreatePostController extends GetxController {
  final PostRepository _postRepository = Get.put(PostRepository());
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  // Form controllers
  final contentController = TextEditingController();

  // Observable variables
  final _selectedPostType = 'tip'.obs;
  final _mediaFiles = <MediaFile>[].obs;
  final _isPosting = false.obs;
  final _isCompressing = false.obs;

  // Constants
  static const int maxContentLength = 2000;
  static const int maxMediaCount = 10;
  static const int maxImageSizeMB = 10;
  static const int maxVideoSizeMB = 100;
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png', 'webp', 'heic'];
  static const List<String> allowedVideoFormats = ['mp4', 'mov', 'avi'];
  static const int imageQuality = 85; // WebP quality (0-100)

  // Getters
  String get selectedPostType => _selectedPostType.value;
  List<MediaFile> get mediaFiles => _mediaFiles;
  bool get isPosting => _isPosting.value;
  bool get isCompressing => _isCompressing.value;
  bool get canPost =>
      contentController.text.trim().isNotEmpty &&
          contentController.text.length <= maxContentLength &&
          !_isPosting.value &&
          !_isCompressing.value;

  @override
  void onClose() {
    contentController.dispose();
    for (var media in _mediaFiles) {
      media.dispose();
    }
    super.onClose();
  }

  /// Set community type
  void setPostType(String type) {
    _selectedPostType.value = type;
  }

  /// Open custom camera
  Future<void> openCustomCamera() async {
    if (_mediaFiles.length >= maxMediaCount) {
      Get.snackbar(
        'Limit Reached',
        'You can only add up to $maxMediaCount media files',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final result = await Get.to(() => const CustomCameraScreen());
    if (result != null && result is File) {
      // 检测文件类型而不是硬编码为图片
      final mediaType = _detectMediaType(result);
      await _addMediaFile(result, mediaType);
    }
  }

  /// 检测文件类型
  MediaType _detectMediaType(File file) {
    final path = file.path.toLowerCase();
    if (path.endsWith('.mp4') ||
        path.endsWith('.mov') ||
        path.endsWith('.avi')) {
      return MediaType.video;
    }
    return MediaType.image;
  }

  /// Pick images/videos from gallery
  Future<void> pickFromGallery() async {
    if (_mediaFiles.length >= maxMediaCount) {
      Get.snackbar(
        'Limit Reached',
        'You can only add up to $maxMediaCount media files',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      // Show options: Image or Video
      final choice = await Get.dialog<String>(
        AlertDialog(
          title: const Text('Select Media Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Images'),
                onTap: () => Get.back(result: 'image'),
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Video'),
                onTap: () => Get.back(result: 'video'),
              ),
            ],
          ),
        ),
      );

      if (choice == null) return;

      if (choice == 'image') {
        final List<XFile> images = await _picker.pickMultiImage();
        for (var image in images) {
          if (_mediaFiles.length >= maxMediaCount) break;
          await _addMediaFile(File(image.path), MediaType.image);
        }
      } else {
        final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
        if (video != null) {
          await _addMediaFile(File(video.path), MediaType.video);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick media: $e');
    }
  }

  /// Add media file with validation
  Future<void> _addMediaFile(File file, MediaType type) async {
    try {
      // Validate file size
      final fileSizeInMB = await file.length() / (1024 * 1024);

      if (type == MediaType.image && fileSizeInMB > maxImageSizeMB) {
        Get.snackbar(
          'File Too Large',
          'Image size should not exceed ${maxImageSizeMB}MB',
        );
        return;
      }

      if (type == MediaType.video && fileSizeInMB > maxVideoSizeMB) {
        Get.snackbar(
          'File Too Large',
          'Video size should not exceed ${maxVideoSizeMB}MB',
        );
        return;
      }

      // Validate format
      final extension = file.path.split('.').last.toLowerCase();
      if (type == MediaType.image && !allowedImageFormats.contains(extension)) {
        Get.snackbar(
          'Invalid Format',
          'Allowed image formats: ${allowedImageFormats.join(", ")}',
        );
        return;
      }

      if (type == MediaType.video && !allowedVideoFormats.contains(extension)) {
        Get.snackbar(
          'Invalid Format',
          'Allowed video formats: ${allowedVideoFormats.join(", ")}',
        );
        return;
      }

      // For images, compress and convert to WebP
      File processedFile = file;
      if (type == MediaType.image) {
        processedFile = await _compressAndConvertToWebP(file);
      }

      // Create media file object
      VideoPlayerController? videoController;
      if (type == MediaType.video) {
        videoController = VideoPlayerController.file(processedFile);
        await videoController.initialize();
      }

      final mediaFile = MediaFile(
        id: _uuid.v4(),
        file: processedFile,
        type: type,
        videoController: videoController,
      );

      _mediaFiles.add(mediaFile);
    } catch (e) {
      Get.snackbar('Error', 'Failed to add media: $e');
    }
  }

  /// Compress image and convert to WebP format
  Future<File> _compressAndConvertToWebP(File imageFile) async {
    try {
      _isCompressing.value = true;

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final targetPath = '${tempDir.path}/${_uuid.v4()}.webp';

      // Compress and convert to WebP
      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        format: CompressFormat.webp,
        quality: imageQuality,
        minWidth: 1080, // Maximum width
        minHeight: 1080, // Maximum height
        autoCorrectionAngle: true,
      );

      if (result == null) {
        throw 'Failed to compress image';
      }

      _isCompressing.value = false;
      return File(result.path);
    } catch (e) {
      _isCompressing.value = false;
      // If compression fails, return original file
      print('Image compression failed: $e, using original file');
      return imageFile;
    }
  }

  /// Remove media file
  void removeMediaFile(String id) {
    final index = _mediaFiles.indexWhere((m) => m.id == id);
    if (index != -1) {
      _mediaFiles[index].dispose();
      _mediaFiles.removeAt(index);
    }
  }

  /// Create community
  Future<void> createPost() async {
    if (!canPost) return;

    try {
      _isPosting.value = true;

      // Get current user ID (from auth service)
      final userId = _getCurrentUserId();

      // Upload media files
      List<String> mediaUrls = [];
      if (_mediaFiles.isNotEmpty) {
        mediaUrls = await _uploadMediaFiles(userId);
      }

      // Create community model
      final post = PostModel(
        postId: _uuid.v4(),
        userId: userId,
        postType: _selectedPostType.value,
        content: contentController.text.trim(),
        media: mediaUrls,
        likes: [],
        commentCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDisabled: false,
      );

      // Save community to Firestore
      await _postRepository.savePost(post);

      // Success feedback
      Get.back();
      Get.snackbar(
        'Success',
        'Post created successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Clear form
      _clearForm();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create community: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isPosting.value = false;
    }
  }

  /// Upload media files to Firebase Storage
  Future<List<String>> _uploadMediaFiles(String userId) async {
    try {
      List<String> uploadedUrls = [];

      for (var mediaFile in _mediaFiles) {
        String? url;

        if (mediaFile.type == MediaType.image) {
          url = await _uploadImage(mediaFile.file, userId);
        } else if (mediaFile.type == MediaType.video) {
          url = await _uploadVideo(mediaFile.file, userId);
        }

        if (url != null) {
          uploadedUrls.add(url);
        }
      }

      return uploadedUrls;
    } catch (e) {
      throw 'Failed to upload media files: $e';
    }
  }

  /// Upload image to Firebase Storage
  Future<String?> _uploadImage(File imageFile, String userId) async {
    try {
      final fileName = '${_uuid.v4()}.webp';
      final path = 'posts/$userId/images/$fileName';
      final ref = _postRepository.storage.ref().child(path);

      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/webp',
          customMetadata: {
            'uploadedBy': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw 'Failed to upload image: $e';
    }
  }

  /// Upload video to Firebase Storage
  Future<String?> _uploadVideo(File videoFile, String userId) async {
    try {
      final fileName = '${_uuid.v4()}.mp4';
      final path = 'posts/$userId/videos/$fileName';
      final ref = _postRepository.storage.ref().child(path);

      final uploadTask = ref.putFile(
        videoFile,
        SettableMetadata(
          contentType: 'video/mp4',
          customMetadata: {
            'uploadedBy': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw 'Failed to upload video: $e';
    }
  }

  /// Clear form
  void _clearForm() {
    contentController.clear();
    for (var media in _mediaFiles) {
      media.dispose();
    }
    _mediaFiles.clear();
    _selectedPostType.value = 'tip';
  }

  /// Get current user ID (placeholder - implement with your auth service)
  String _getCurrentUserId() {
    // TODO: Implement with your authentication service
    return 'current_user_id';
  }

  /// Validate content length
  bool validateContentLength() {
    return contentController.text.length <= maxContentLength;
  }
}