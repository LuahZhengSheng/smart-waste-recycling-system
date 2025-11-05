import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyp/features/community/controllers/posts/comment_controller.dart';
import 'package:get/get.dart';
import 'package:fyp/features/community/models/reply_model.dart';
import 'package:fyp/data/repositories/community/reply_repository.dart';
import 'package:fyp/data/repositories/authentication/authentication_repository.dart';
import 'package:fyp/utils/popups/loaders.dart';

import '../../../../data/repositories/community/comment_repository.dart';
import '../../models/comment_model.dart';

class ReplyController extends GetxController {
  static ReplyController get instance => Get.find();

  // Dependencies
  final CommentRepository commentRepository = Get.put(CommentRepository());
  final ReplyRepository replyRepository = Get.put(ReplyRepository());
  final AuthenticationRepository authRepository = Get.put(AuthenticationRepository());

  // Observable variables
  final RxList<Reply> replies = <Reply>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  // IDs
  String postId = '';
  String commentId = '';

  // Stream subscription
  StreamSubscription<List<Reply>>? _repliesSubscription;

  // Text controller for reply input
  final TextEditingController replyController = TextEditingController();
  final FocusNode replyFocusNode = FocusNode();

  // Edit mode
  final RxBool isEditMode = false.obs;
  final Rx<Reply?> editingReply = Rx<Reply?>(null);

  // Reactive variable for reply input validation
  final RxBool isReplyValid = false.obs;

  // Get CommentController instance
  CommentController get _commentController => CommentController.instance;

  @override
  void onInit() {
    super.onInit();
    replyController.addListener(_validateReplyInput);
  }

  @override
  void onClose() {
    _repliesSubscription?.cancel();
    replyController.removeListener(_validateReplyInput);
    replyController.dispose();
    replyFocusNode.dispose();
    super.onClose();
  }

  /// Initialize controller with comment ID
  Future<void> initialize(String postId, String commentId, {bool autoFocus = false}) async {
    try {
      this.postId = postId;
      this.commentId = commentId;

      isLoading.value = true;

      // Subscribe to replies stream
      _repliesSubscription?.cancel();
      _repliesSubscription = replyRepository.getRepliesStream(commentId).listen(
            (repliesList) async {
          replies.assignAll(repliesList);

          // Load user data for all replies
          if (repliesList.isNotEmpty) {
            await _commentController.loadUserDataForComments(
              repliesList.map((r) => Comment(
                commentId: r.replyId,
                userId: r.userId,
                content: r.content,
                likes: r.likes,
                createdAt: r.createdAt,
                updatedAt: r.updatedAt,
              )).toList(),
            );
          }

          isLoading.value = false;
        },
        onError: (error) {
          isLoading.value = false;
          FLoaders.errorSnackBar(
            title: 'Error',
            message: 'Failed to load replies: ${error.toString()}',
          );
        },
      );

      // Auto focus reply input if needed
      if (autoFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          replyFocusNode.requestFocus();
        });
      }
    } catch (e) {
      isLoading.value = false;
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to initialize: ${e.toString()}',
      );
    }
  }

  /// Submit a new reply
  Future<void> submitReply() async {
    if (!_canSubmitReply()) return;

    final replyContent = replyController.text.trim();
    if (replyContent.isEmpty) {
      FLoaders.warningSnackBar(
        title: 'Empty Reply',
        message: 'Please write something before posting',
      );
      return;
    }

    try {
      isSubmitting.value = true;

      final currentUserId = authRepository.authUser?.uid ?? '';
      if (currentUserId.isEmpty) {
        FLoaders.warningSnackBar(
          title: 'Authentication Required',
          message: 'Please login to reply',
        );
        return;
      }

      final replyId = FirebaseFirestore.instance.collection('replies').doc().id;

      final newReply = Reply(
        replyId: replyId,
        userId: currentUserId,
        content: replyContent,
        likes: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Clear input immediately
      replyController.clear();
      isReplyValid.value = false;

      // Add to Firestore
      await replyRepository.addReply(commentId, newReply);

      // Increase reply count
      await commentRepository.increaseReplyCount(commentId);

      // Update comment reply count
      _commentController.updateReplyCount(1);

      FLoaders.successSnackBar(
        title: 'Success',
        message: 'Reply posted successfully',
      );
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to post reply: ${e.toString()}',
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Start editing a reply
  void startEdit(Reply reply) {
    isEditMode.value = true;
    editingReply.value = reply;
    replyController.text = reply.content;
    replyFocusNode.requestFocus();
  }

  /// Cancel editing
  void cancelEdit() {
    isEditMode.value = false;
    editingReply.value = null;
    replyController.clear();
  }

  /// Save edited reply
  Future<void> saveEdit() async {
    if (editingReply.value == null) return;

    final newContent = replyController.text.trim();
    if (newContent.isEmpty) {
      FLoaders.warningSnackBar(
        title: 'Empty Content',
        message: 'Reply cannot be empty',
      );
      return;
    }

    if (newContent == editingReply.value!.content) {
      cancelEdit();
      return;
    }

    try {
      isSubmitting.value = true;

      // Update in Firestore
      await replyRepository.updateReply(editingReply.value!.replyId, newContent);

      FLoaders.successSnackBar(
        title: 'Success',
        message: 'Reply updated successfully',
      );

      cancelEdit();
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update reply: ${e.toString()}',
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Toggle like on a reply
  Future<void> toggleReplyLike(String replyId) async {
    try {
      final currentUserId = authRepository.authUser?.uid ?? '';
      if (currentUserId.isEmpty) {
        FLoaders.warningSnackBar(
          title: 'Authentication Required',
          message: 'Please login to like replies',
        );
        return;
      }

      final replyIndex = replies.indexWhere((r) => r.replyId == replyId);
      if (replyIndex == -1) return;

      final reply = replies[replyIndex];
      final isCurrentlyLiked = reply.likes.contains(currentUserId);

      List<String> updatedLikes = List.from(reply.likes);
      if (isCurrentlyLiked) {
        updatedLikes.remove(currentUserId);
      } else {
        updatedLikes.add(currentUserId);
      }

      // Optimistically update UI
      replies[replyIndex] = reply.copyWith(likes: updatedLikes);

      // Update in Firestore
      await replyRepository.toggleReplyLike(replyId, updatedLikes);
    } catch (e) {
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update like: ${e.toString()}',
      );
    }
  }

  /// Delete a reply
  Future<void> deleteReply(Reply reply) async {
    try {
      final confirmed = await FLoaders.showConfirmationDialog(
        title: 'Delete Reply',
        message: 'Are you sure you want to delete this reply?',
        confirmText: 'Delete',
        cancelText: 'Cancel',
        confirmColor: Colors.red,
      );

      if (confirmed != true) return;

      FLoaders.showLoading('Deleting reply...');

      await replyRepository.deleteReply(reply.replyId);

      // Decrease reply count
      await commentRepository.decreaseReplyCount(commentId);

      // Update comment reply count
      _commentController.updateReplyCount(-1);

      FLoaders.stopLoading();
      FLoaders.successSnackBar(
        title: 'Success',
        message: 'Reply deleted',
      );
    } catch (e) {
      FLoaders.stopLoading();
      FLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to delete reply: ${e.toString()}',
      );
    }
  }

  /// Copy reply text to clipboard
  Future<void> copyReplyText(String text) async {
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

  /// Check if current user can modify reply
  bool canModifyReply(Reply reply) {
    final currentUserId = authRepository.authUser?.uid ?? '';
    return reply.userId == currentUserId;
  }

  /// Refresh replies
  Future<void> refreshReplies() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Get replies count
  int get repliesCount => replies.length;

  /// Clear all data
  void clearData() {
    replies.clear();
    replyController.clear();
    isReplyValid.value = false;
    isEditMode.value = false;
    editingReply.value = null;
    replyFocusNode.unfocus();
    postId = '';
    commentId = '';
    _repliesSubscription?.cancel();
  }

  /// Private helper methods
  bool _canSubmitReply() {
    return isReplyValid.value && !isSubmitting.value;
  }

  void _validateReplyInput() {
    final isValid = replyController.text.trim().isNotEmpty;
    if (isReplyValid.value != isValid) {
      isReplyValid.value = isValid;
    }
  }
}

