import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyp/data/repositories/community/post_repository.dart';
import 'package:get/get.dart';
import 'package:fyp/features/community/models/comment_model.dart';
import 'package:fyp/data/repositories/user/user_repository.dart';
import 'package:fyp/data/repositories/authentication/authentication_repository.dart';
import 'package:fyp/data/repositories/community/comment_repository.dart';
import 'package:fyp/features/authentication/models/user_model.dart';
import 'package:fyp/utils/popups/loaders.dart';

class CommentController extends GetxController {
  static CommentController get instance => Get.find();

  // Dependencies
  final PostRepository postRepository = Get.put(PostRepository());
  final CommentRepository commentRepository = Get.put(CommentRepository());
  final UserRepository userRepository = Get.put(UserRepository());
  final AuthenticationRepository authRepository = Get.put(AuthenticationRepository());

  // Current comment data (for replies screen)
  Rx<Comment> currentComment = Comment.empty().obs;

  // User data cache
  final RxMap<String, UserModel> userDataCache = <String, UserModel>{}.obs;

  // Loading states
  final RxBool isLoadingUserData = false.obs;
  final RxBool isSubmitting = false.obs;

  // Text controller for adding/editing comments
  final commentController = TextEditingController();
  final FocusNode commentFocusNode = FocusNode();

  // Edit mode
  final RxBool isEditMode = false.obs;
  final Rx<Comment?> editingComment = Rx<Comment?>(null);

  // 添加可观察的文本状态
  final RxString commentText = ''.obs;

  // Current post ID
  String _currentPostId = '';

  @override
  void onInit() {
    super.onInit();
    // 监听文本变化
    commentController.addListener(() {
      commentText.value = commentController.text;
    });
  }

  @override
  void onClose() {
    commentController.removeListener(() {});
    commentController.dispose();
    commentFocusNode.dispose();
    super.onClose();
  }

  /// Load user data for all comments
  Future<void> loadUserDataForComments(List<Comment> comments) async {
    if (comments.isEmpty) return;

    try {
      isLoadingUserData.value = true;

      // 获取所有唯一的 user IDs
      final uniqueUserIds = comments.map((c) => c.userId).toSet();

      // 过滤出还没有缓存的用户
      final uncachedUserIds = uniqueUserIds.where((id) => !userDataCache.containsKey(id)).toSet();

      if (uncachedUserIds.isNotEmpty) {
        // 批量获取用户数据
        final usersData = await userRepository.getUsersProfileData(uncachedUserIds);

        // 更新缓存
        userDataCache.addAll(usersData);
      }
    } catch (e) {
      debugPrint('Failed to load user data for comments: $e');
    } finally {
      isLoadingUserData.value = false;
    }
  }

  /// Get username from cache
  String getUsername(String userId) {
    return userDataCache[userId]?.username ?? 'Loading...';
  }

  /// Get profile image from cache
  String getProfileImage(String userId) {
    return userDataCache[userId]?.profileImg ?? '';
  }

  /// Initialize controller with comment data (for replies screen)
  Future<void> initialize(Comment comment, {String? postId}) async {
    currentComment.value = comment;
    if (postId != null) {
      _currentPostId = postId;
    }

    // Load user data for the comment
    await loadUserDataForComments([comment]);
  }

  /// Toggle like on the main comment
  Future<void> toggleLike() async {
    try {
      final currentUserId = getCurrentUserId();
      if (currentUserId.isEmpty) {
        FLoaders.warningSnackBar(
          title: 'Authentication Required',
          message: 'Please login to like comments',
        );
        return;
      }

      final isCurrentlyLiked = currentComment.value.likes.contains(currentUserId);
      List<String> updatedLikes = List.from(currentComment.value.likes);

      if (isCurrentlyLiked) {
        updatedLikes.remove(currentUserId);
      } else {
        updatedLikes.add(currentUserId);
      }

      // Optimistically update UI
      currentComment.value = currentComment.value.copyWith(likes: updatedLikes);

      // Update in Firestore
      await commentRepository.toggleCommentLike(
        currentComment.value.commentId,
        updatedLikes,
      );
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update like: ${e.toString()}',
      );
    }
  }

  /// Toggle like on any comment (for use in PostDetailsController)
  Future<void> toggleCommentLike(String commentId) async {
    try {
      final currentUserId = getCurrentUserId();
      if (currentUserId.isEmpty) {
        FLoaders.warningSnackBar(
          title: 'Authentication Required',
          message: 'Please login to like comments',
        );
        return;
      }

      // This will be handled by the stream update
      final comment = await commentRepository.getCommentById(commentId);
      if (comment == null) return;

      final isCurrentlyLiked = comment.likes.contains(currentUserId);
      List<String> updatedLikes = List.from(comment.likes);

      if (isCurrentlyLiked) {
        updatedLikes.remove(currentUserId);
      } else {
        updatedLikes.add(currentUserId);
      }

      await commentRepository.toggleCommentLike(commentId, updatedLikes);
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update like: ${e.toString()}',
      );
    }
  }

  /// Add comment to a post
  Future<void> addComment(String postId) async {
    final content = commentController.text.trim();
    if (content.isEmpty) {
      FLoaders.warningSnackBar(
        title: 'Empty Comment',
        message: 'Please write something before posting',
      );
      return;
    }

    try {
      isSubmitting.value = true;
      final currentUserId = getCurrentUserId();

      if (currentUserId.isEmpty) {
        FLoaders.warningSnackBar(
          title: 'Authentication Required',
          message: 'Please login to comment',
        );
        return;
      }

      final newCommentId = FirebaseFirestore.instance.collection('comments').doc().id;

      final newComment = Comment(
        commentId: newCommentId,
        userId: currentUserId,
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Clear input immediately
      commentController.clear();
      commentText.value = '';

      // Add to Firestore
      await commentRepository.addComment(postId, newComment);

      // Update comment count
      await postRepository.increaseCommentCount(postId);

      FLoaders.successSnackBar(
        title: 'Success',
        message: 'Comment added successfully',
      );
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to add comment: ${e.toString()}',
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Start editing a comment
  void startEdit(Comment comment) {
    isEditMode.value = true;
    editingComment.value = comment;
    commentController.text = comment.content;
    commentText.value = comment.content;
    commentFocusNode.requestFocus();
  }

  /// Cancel editing
  void cancelEdit() {
    isEditMode.value = false;
    editingComment.value = null;
    commentController.clear();
    commentText.value = '';
  }

  /// Save edited comment
  Future<void> saveEdit() async {
    if (editingComment.value == null) return;

    final newContent = commentController.text.trim();
    if (newContent.isEmpty) {
      FLoaders.warningSnackBar(
        title: 'Empty Content',
        message: 'Comment cannot be empty',
      );
      return;
    }

    if (newContent == editingComment.value!.content) {
      cancelEdit();
      return;
    }

    try {
      isSubmitting.value = true;

      // Update in Firestore
      await commentRepository.updateComment(
        editingComment.value!.commentId,
        newContent,
      );

      // If editing the main comment in replies screen
      if (editingComment.value!.commentId == currentComment.value.commentId) {
        currentComment.value = currentComment.value.copyWith(
          content: newContent,
          updatedAt: DateTime.now(),
        );
      }

      FLoaders.successSnackBar(
        title: 'Success',
        message: 'Comment updated successfully',
      );

      cancelEdit();
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update comment: ${e.toString()}',
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Delete comment
  Future<void> deleteComment(Comment comment) async {
    if (_currentPostId.isEmpty) return;

    try {
      final confirmed = await FLoaders.showConfirmationDialog(
        title: 'Delete Comment',
        message: 'Are you sure you want to delete this comment? This action cannot be undone.',
        confirmText: 'Delete',
        cancelText: 'Cancel',
        confirmColor: Colors.red,
      );

      if (confirmed != true) return;

      FLoaders.showLoading('Deleting comment...');

      await commentRepository.deleteComment(_currentPostId, comment.commentId);
      await postRepository.decreaseCommentCount(_currentPostId);

      FLoaders.stopLoading();
      FLoaders.successSnackBar(
        title: 'Success',
        message: 'Comment deleted successfully',
      );

      // If deleting main comment in replies screen, go back
      if (comment.commentId == currentComment.value.commentId) {
        Get.back();
      }
    } catch (e) {
      FLoaders.stopLoading();
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to delete comment: ${e.toString()}',
      );
    }
  }

  /// Copy comment text to clipboard
  Future<void> copyText(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      FLoaders.successSnackBar(
        title: 'Copied',
        message: 'Text copied to clipboard',
      );
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to copy text: ${e.toString()}',
      );
    }
  }

  /// Update reply count
  void updateReplyCount(int delta) {
    final newCount = currentComment.value.replyCount + delta;
    currentComment.value = currentComment.value.copyWith(
      replyCount: newCount.clamp(0, double.infinity).toInt(),
    );
  }

  /// Set current post ID
  void setPostId(String postId) {
    _currentPostId = postId;
  }

  /// Get current user ID
  String getCurrentUserId() {
    return authRepository.authUser?.uid ?? '';
  }

  /// Check if current user can modify comment
  bool canModifyComment(Comment comment) {
    return comment.userId == getCurrentUserId();
  }

  /// Clear data
  void clearData() {
    currentComment.value = Comment.empty();
    _currentPostId = '';
    commentController.clear();
    commentText.value = '';
    isEditMode.value = false;
    editingComment.value = null;
  }
}