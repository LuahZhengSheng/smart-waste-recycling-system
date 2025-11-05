import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fyp/features/community/models/post_model.dart';
import 'package:fyp/features/community/models/post_enums.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fyp/data/repositories/community/post_repository.dart';
import 'package:fyp/data/repositories/authentication/authentication_repository.dart';
import 'package:fyp/utils/popups/loaders.dart';
import 'package:http/http.dart' as http;
import '../../screens/create_post/widgets/custom_camera_screen.dart';

class MediaFile {
  final String id;
  final File file;
  final MediaType type;
  final String? storagePath; // 存储路径名称 (例如: "8d44fc0e.webp")
  final bool isExistingMedia; // 标记是否为已存在的媒体（编辑模式）
  VideoPlayerController? videoController;

  MediaFile({
    required this.id,
    required this.file,
    required this.type,
    this.storagePath,
    this.isExistingMedia = false,
    this.videoController,
  });

  Future<void> dispose() async {
    await videoController?.dispose();
  }
}

class CreatePostController extends GetxController {
  final PostRepository _postRepository = Get.put(PostRepository());
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  // Form controllers
  final contentController = TextEditingController();

  // Observable variables
  final _selectedPostType = PostType.tip.obs;
  final _mediaFiles = <MediaFile>[].obs;
  final _isPosting = false.obs;
  final _isCompressing = false.obs;
  final _isEditMode = false.obs;
  final _editingPost = Rx<PostModel?>(null);
  final _isLoadingMedia = false.obs;
  final _originalMediaPaths = <String>[].obs; // 存储原始的 storage path
  final _removedMediaPaths = <String>[].obs; // 存储被删除的媒体路径

  // Constants
  static const int maxContentLength = 2000;
  static const int maxMediaCount = 10;
  static const int maxImageSizeMB = 10;
  static const int maxVideoSizeMB = 100;
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png', 'webp', 'heic'];
  static const List<String> allowedVideoFormats = ['mp4', 'mov', 'avi'];
  static const int imageQuality = 85;

  // Getters
  PostType get selectedPostType => _selectedPostType.value;
  List<MediaFile> get mediaFiles => _mediaFiles;
  bool get isPosting => _isPosting.value;
  bool get isCompressing => _isCompressing.value;
  bool get isEditMode => _isEditMode.value;
  PostModel? get editingPost => _editingPost.value;
  bool get isLoadingMedia => _isLoadingMedia.value;

  bool get canPost =>
      contentController.text.trim().isNotEmpty &&
          contentController.text.length <= maxContentLength &&
          !_isPosting.value &&
          !_isCompressing.value &&
          !_isLoadingMedia.value;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is PostModel) {
      _initializeEditMode(Get.arguments as PostModel);
    }
  }

  @override
  void onClose() {
    contentController.dispose();
    for (var media in _mediaFiles) {
      media.dispose();
    }
    super.onClose();
  }

  /// Initialize edit mode with existing post data
  Future<void> _initializeEditMode(PostModel post) async {
    try {
      _isEditMode.value = true;
      _editingPost.value = post;
      _isLoadingMedia.value = true;

      // Preload content
      contentController.text = post.content;

      // Preload post type
      _selectedPostType.value = PostType.fromString(post.postType);

      // 需要从 Firestore 获取原始的 storage paths
      // 因为 post.media 已经被转换成了完整的 URL
      final userId = AuthenticationRepository.instance.authUser?.uid ?? '';
      final originalPost = await _postRepository.getOriginalPost(post.postId);

      if (originalPost != null && originalPost.media.isNotEmpty) {
        // 保存原始的 storage paths
        _originalMediaPaths.addAll(originalPost.media);

        // 使用 URL 来加载媒体（post.media 是 URL）
        for (int i = 0; i < post.media.length; i++) {
          final mediaUrl = post.media[i];
          final storagePath = originalPost.media[i];
          await _loadExistingMediaFromUrl(mediaUrl, storagePath);
        }
      }

      _isLoadingMedia.value = false;
    } catch (e) {
      _isLoadingMedia.value = false;
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load post data: $e',
      );
      Get.back();
    }
  }

  /// Load existing media from URL (for edit mode)
  Future<void> _loadExistingMediaFromUrl(String mediaUrl, String storagePath) async {
    try {
      // 确定媒体类型
      final isVideo = storagePath.contains('.mp4') ||
          storagePath.contains('.mov') ||
          storagePath.contains('.avi');
      final mediaType = isVideo ? MediaType.video : MediaType.image;

      // 下载文件到临时目录
      final response = await http.get(Uri.parse(mediaUrl));
      if (response.statusCode != 200) {
        throw 'Failed to download media';
      }

      final tempDir = await getTemporaryDirectory();
      final extension = storagePath.split('.').last;
      final fileName = '${_uuid.v4()}.$extension';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(response.bodyBytes);

      // 创建 VideoController (如果是视频)
      VideoPlayerController? videoController;
      if (mediaType == MediaType.video) {
        videoController = VideoPlayerController.file(file);
        await videoController.initialize();
      }

      final mediaFile = MediaFile(
        id: _uuid.v4(),
        file: file,
        type: mediaType,
        storagePath: storagePath, // 保存原始 storage path
        isExistingMedia: true, // 标记为已存在的媒体
        videoController: videoController,
      );

      _mediaFiles.add(mediaFile);
    } catch (e) {
      print('Failed to load existing media from URL: $e');
    }
  }

  /// Get full storage path from storage path name
  String _getFullStoragePath(String storagePath, String userId) {
    if (storagePath.contains('.mp4') ||
        storagePath.contains('.mov') ||
        storagePath.contains('.avi')) {
      return 'posts/$userId/videos/$storagePath';
    } else {
      return 'posts/$userId/images/$storagePath';
    }
  }

  /// Set post type
  void setPostType(PostType type) {
    _selectedPostType.value = type;
  }

  /// Open custom camera
  Future<void> openCustomCamera() async {
    if (_mediaFiles.length >= maxMediaCount) {
      FLoaders.warningSnackBar(
        title: 'Limit Reached',
        message: 'You can only add up to $maxMediaCount media files',
      );
      return;
    }

    final result = await Get.to(() => const CustomCameraScreen());
    if (result != null && result is File) {
      final mediaType = _detectMediaType(result);
      await _addMediaFile(result, mediaType);
    }
  }

  /// Pick images/videos from gallery
  Future<void> pickFromGallery() async {
    if (_mediaFiles.length >= maxMediaCount) {
      FLoaders.warningSnackBar(
        title: 'Limit Reached',
        message: 'You can only add up to $maxMediaCount media files',
      );
      return;
    }

    try {
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
      FLoaders.errorSnackBar(title: 'Error', message: 'Failed to pick media: $e');
    }
  }

  /// Detect media type from file
  MediaType _detectMediaType(File file) {
    final path = file.path.toLowerCase();
    if (path.endsWith('.mp4') || path.endsWith('.mov') || path.endsWith('.avi')) {
      return MediaType.video;
    }
    return MediaType.image;
  }

  /// Add media file with validation
  Future<void> _addMediaFile(File file, MediaType type) async {
    try {
      final fileSizeInMB = await file.length() / (1024 * 1024);

      if (type == MediaType.image && fileSizeInMB > maxImageSizeMB) {
        FLoaders.warningSnackBar(
          title: 'File Too Large',
          message: 'Image size should not exceed ${maxImageSizeMB}MB',
        );
        return;
      }

      if (type == MediaType.video && fileSizeInMB > maxVideoSizeMB) {
        FLoaders.warningSnackBar(
          title: 'File Too Large',
          message: 'Video size should not exceed ${maxVideoSizeMB}MB',
        );
        return;
      }

      final extension = file.path.split('.').last.toLowerCase();
      if (type == MediaType.image && !allowedImageFormats.contains(extension)) {
        FLoaders.warningSnackBar(
          title: 'Invalid Format',
          message: 'Allowed image formats: ${allowedImageFormats.join(", ")}',
        );
        return;
      }

      if (type == MediaType.video && !allowedVideoFormats.contains(extension)) {
        FLoaders.warningSnackBar(
          title: 'Invalid Format',
          message: 'Allowed video formats: ${allowedVideoFormats.join(", ")}',
        );
        return;
      }

      File processedFile = file;
      if (type == MediaType.image) {
        processedFile = await _compressAndConvertToWebP(file);
      }

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
      FLoaders.errorSnackBar(title: 'Error', message: 'Failed to add media: $e');
    }
  }

  /// Compress image and convert to WebP
  Future<File> _compressAndConvertToWebP(File imageFile) async {
    try {
      _isCompressing.value = true;

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

      _isCompressing.value = false;
      return File(result.path);
    } catch (e) {
      _isCompressing.value = false;
      print('Image compression failed: $e, using original file');
      return imageFile;
    }
  }

  /// Remove media file
  Future<void> removeMediaFile(String id) async {
    final index = _mediaFiles.indexWhere((m) => m.id == id);
    if (index != -1) {
      final mediaFile = _mediaFiles[index];

      // 如果是编辑模式且该媒体是已存在的媒体（有 storagePath）
      if (isEditMode && mediaFile.storagePath != null && mediaFile.isExistingMedia) {
        // 添加到删除列表，但不立即从 Storage 删除
        _removedMediaPaths.add(mediaFile.storagePath!);
        _originalMediaPaths.remove(mediaFile.storagePath);
      } else if (isEditMode && mediaFile.storagePath != null) {
        // 如果是新上传的媒体但有 storagePath（不应该发生的情况）
        try {
          final userId = AuthenticationRepository.instance.authUser?.uid ?? '';
          final fullPath = _getFullStoragePath(mediaFile.storagePath!, userId);
          await _postRepository.storage.ref(fullPath).delete();
        } catch (e) {
          print('Failed to delete media from storage: $e');
        }
      }

      await mediaFile.dispose();
      _mediaFiles.removeAt(index);
    }
  }

  /// Create or update post
  Future<void> createPost() async {
    if (!canPost) return;

    try {
      FLoaders.showLoading(isEditMode ? 'Updating post...' : 'Creating post...');
      _isPosting.value = true;

      final userId = AuthenticationRepository.instance.authUser?.uid ?? '';
      if (userId.isEmpty) {
        throw 'User not authenticated';
      }

      // Upload media files and get storage paths
      List<String> mediaPaths = [];
      for (var mediaFile in _mediaFiles) {
        if (mediaFile.storagePath != null && mediaFile.isExistingMedia) {
          // Keep existing media path
          mediaPaths.add(mediaFile.storagePath!);
        } else {
          // Upload new file and get storage path
          final storagePath = mediaFile.type == MediaType.image
              ? await _uploadImage(mediaFile.file, userId)
              : await _uploadVideo(mediaFile.file, userId);
          if (storagePath != null) mediaPaths.add(storagePath);
        }
      }

      // 如果是编辑模式，删除被移除的媒体（只有在用户确认更新时才删除）
      if (isEditMode && editingPost != null && _removedMediaPaths.isNotEmpty) {
        for (var path in _removedMediaPaths) {
          try {
            final fullPath = _getFullStoragePath(path, userId);
            await _postRepository.storage.ref(fullPath).delete();
          } catch (e) {
            print('Failed to delete removed media: $e');
          }
        }
      }

      PostModel post;
      if (isEditMode && editingPost != null) {
        // Update existing post
        post = editingPost!.copyWith(
          postType: _selectedPostType.value.value,
          content: contentController.text.trim(),
          media: mediaPaths,
          updatedAt: DateTime.now(),
        );
      } else {
        // Create new post
        post = PostModel(
          postId: _uuid.v4(),
          userId: userId,
          postType: _selectedPostType.value.value,
          content: contentController.text.trim(),
          media: mediaPaths,
          likes: [],
          commentCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isDisabled: false,
        );
      }

      await _postRepository.savePost(post);

      FLoaders.stopLoading();
      Get.back();
      FLoaders.successSnackBar(
        title: 'Success',
        message: isEditMode ? 'Post updated successfully!' : 'Post created successfully!',
      );

      _clearForm();
    } catch (e) {
      FLoaders.stopLoading();
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to ${isEditMode ? "update" : "create"} post: $e',
      );
    } finally {
      _isPosting.value = false;
    }
  }

  /// Upload image to Firebase Storage and return storage path
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

      await uploadTask;
      return fileName;
    } catch (e) {
      throw 'Failed to upload image: $e';
    }
  }

  /// Upload video to Firebase Storage and return storage path
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

      await uploadTask;
      return fileName;
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
    _selectedPostType.value = PostType.tip;
    _isEditMode.value = false;
    _editingPost.value = null;
    _originalMediaPaths.clear();
    _removedMediaPaths.clear();
  }

  /// 当用户取消编辑时，重新加载原始数据
  void reloadOriginalMedia() {
    if (isEditMode && editingPost != null) {
      // 清除当前媒体文件
      for (var media in _mediaFiles) {
        media.dispose();
      }
      _mediaFiles.clear();
      _removedMediaPaths.clear();

      // 重新加载原始媒体
      _initializeEditMode(editingPost!);
    }
  }
}