import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyp/features/community/controllers/posts/comment_controller.dart';
import 'package:get/get.dart';
import 'package:fyp/features/community/models/reply_model.dart';

import '../../../../data/repositories/community/comment_repository.dart';
import '../../../../data/repositories/community/reply_repository.dart';

class ReplyController extends GetxController {
  static ReplyController get instance => Get.find();

  // Dependencies
  final ReplyRepository replyRepository = Get.put(ReplyRepository());
  final CommentRepository commentRepository = Get.put(CommentRepository());

  // Observable variables
  final RxList<Reply> replies = <Reply>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isRefreshing = false.obs;

  // IDs
  String postId = '';
  String commentId = '';

  // Stream subscription
  StreamSubscription<List<Reply>>? _repliesSubscription;

  // Text controller for reply input
  final TextEditingController replyController = TextEditingController();
  final FocusNode replyFocusNode = FocusNode();

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

      // Auto focus reply input if needed
      if (autoFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          replyFocusNode.requestFocus();
        });
      }

      // Load replies via stream
      await loadReplies();
    } catch (e) {
      _showError('Failed to initialize', e.toString());
    }
  }

  /// Load replies for the comment via stream
  Future<void> loadReplies() async {
    try {
      isLoading.value = true;

      // Subscribe to replies stream
      _repliesSubscription?.cancel();
      _repliesSubscription = replyRepository.getRepliesStream(commentId).listen(
            (repliesList) {
          replies.assignAll(repliesList);
          isLoading.value = false;
        },
        onError: (error) {
          isLoading.value = false;
          _showError('Failed to load replies', error.toString());
        },
      );

    } catch (e) {
      isLoading.value = false;
      _showError('Failed to load replies', e.toString());
    }
  }

  /// Submit a new reply
  Future<void> submitReply() async {
    if (!_canSubmitReply()) return;

    try {
      isSubmitting.value = true;

      final replyContent = replyController.text.trim();

      // Generate new reply ID
      final replyId = FirebaseFirestore.instance.collection('temp').doc().id;

      // Create new reply
      final newReply = Reply(
        replyId: replyId,
        userId: _commentController.getCurrentUserId(),
        content: replyContent,
        likes: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Clear input immediately for better UX
      replyController.clear();
      isReplyValid.value = false; // Reset validation

      // Add to Firestore
      await replyRepository.addReply(postId, commentId, newReply);

      // Update comment reply count in parent controller
      _commentController.updateReplyCount(1);

      _showSuccess('Reply posted successfully');

    } catch (e) {
      _showError('Failed to post reply', e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Edit a reply
  Future<void> editReply(String replyId, String newContent) async {
    try {
      final replyIndex = replies.indexWhere((r) => r.replyId == replyId);
      if (replyIndex == -1) return;

      final originalReply = replies[replyIndex];

      // Optimistically update UI
      replies[replyIndex] = Reply(
        replyId: originalReply.replyId,
        userId: originalReply.userId,
        content: newContent,
        likes: originalReply.likes,
        createdAt: originalReply.createdAt,
        updatedAt: DateTime.now(),
      );

      // Update in Firestore
      await replyRepository.updateReply(replyId, newContent);

      _showSuccess('Reply updated successfully');

    } catch (e) {
      // Revert on error
      await _revertReplyChanges(replyId);
      _showError('Failed to update reply', e.toString());
    }
  }

  /// Toggle like on a reply
  Future<void> toggleReplyLike(String replyId) async {
    try {
      final currentUserId = _commentController.getCurrentUserId();
      if (currentUserId.isEmpty) return;

      final replyIndex = replies.indexWhere((r) => r.replyId == replyId);
      if (replyIndex == -1) return;

      final reply = replies[replyIndex];
      final isCurrentlyLiked = reply.likes.contains(currentUserId);

      // Optimistically update UI
      List<String> updatedLikes = List.from(reply.likes);
      if (isCurrentlyLiked) {
        updatedLikes.remove(currentUserId);
      } else {
        updatedLikes.add(currentUserId);
      }

      replies[replyIndex] = Reply(
        replyId: reply.replyId,
        userId: reply.userId,
        content: reply.content,
        likes: updatedLikes,
        createdAt: reply.createdAt,
        updatedAt: reply.updatedAt,
      );

      // Update in Firestore
      await replyRepository.toggleReplyLike(replyId, updatedLikes);

    } catch (e) {
      // Revert optimistic update on error
      await _revertReplyLike(replyId);
      _showError('Failed to update like', e.toString());
    }
  }

  /// Delete a reply with confirmation
  Future<void> deleteReply(String replyId) async {
    try {
      final replyIndex = replies.indexWhere((r) => r.replyId == replyId);
      if (replyIndex == -1) return;

      // Show confirmation dialog
      final confirmed = await _showDeleteConfirmationDialog(
        'Delete Reply',
        'Are you sure you want to delete this reply?',
      );

      if (!confirmed) return;

      // Delete from Firestore
      await replyRepository.deleteReply(commentId, replyId);

      // Update comment reply count
      _commentController.updateReplyCount(-1);

      _showSuccess('Reply deleted');

    } catch (e) {
      _showError('Failed to delete reply', e.toString());
    }
  }

  /// Copy reply text to clipboard
  Future<void> copyReplyText(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      _showSuccess('Text copied to clipboard');
    } catch (e) {
      _showError('Failed to copy text', e.toString());
    }
  }

  /// Report reply
  Future<void> reportReply(String replyId, String reason) async {
    try {
      // TODO: Implement reporting
      _showSuccess('Reply reported. Thank you for your feedback.');
    } catch (e) {
      _showError('Failed to report reply', e.toString());
    }
  }

  /// Check if current user can delete/edit reply
  bool canModifyReply(Reply reply) {
    return reply.userId == _commentController.getCurrentUserId();
  }

  /// Refresh replies
  Future<void> refreshReplies() async {
    isRefreshing.value = true;
    try {
      // Stream will automatically update
      await Future.delayed(const Duration(milliseconds: 500));
    } finally {
      isRefreshing.value = false;
    }
  }

  /// Get replies count
  int get repliesCount => replies.length;

  /// Clear all data
  void clearData() {
    replies.clear();
    replyController.clear();
    isReplyValid.value = false;
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

  Future<bool> _showDeleteConfirmationDialog(String title, String content) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green.withOpacity(0.1),
      colorText: Colors.green[800],
      icon: const Icon(Icons.check_circle, color: Colors.green),
      duration: const Duration(seconds: 2),
    );
  }

  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red.withOpacity(0.1),
      colorText: Colors.red[800],
      icon: const Icon(Icons.error, color: Colors.red),
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> _revertReplyLike(String replyId) async {
    try {
      final freshReply = await replyRepository.getReplyById(replyId);
      final replyIndex = replies.indexWhere((r) => r.replyId == replyId);
      if (replyIndex != -1 && freshReply != null) {
        replies[replyIndex] = freshReply;
      }
    } catch (e) {
      debugPrint('Failed to revert reply like: $e');
    }
  }

  Future<void> _revertReplyChanges(String replyId) async {
    try {
      final freshReply = await replyRepository.getReplyById(replyId);
      final replyIndex = replies.indexWhere((r) => r.replyId == replyId);
      if (replyIndex != -1 && freshReply != null) {
        replies[replyIndex] = freshReply;
      }
    } catch (e) {
      debugPrint('Failed to revert reply changes: $e');
    }
  }
}