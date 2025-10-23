import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:fyp/features/community/models/comment_model.dart';

import '../../../../data/repositories/community/comment_repository.dart';

class CommentController extends GetxController {
  static CommentController get instance => Get.find();

  // Dependencies
  final CommentRepository commentRepository = Get.put(CommentRepository());

  // Current comment data
  Rx<Comment> currentComment = Comment.empty().obs;

  // Current post ID
  String _currentPostId = '';

  // Text controller for adding comments
  final commentController = TextEditingController();

  // User cache for quick lookup
  final RxMap<String, Map<String, String>> _userCache = <String, Map<String, String>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeUserCache();
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }

  /// Initialize controller with comment data
  void initialize(Comment comment, {String? postId}) {
    currentComment.value = comment;
    if (postId != null) {
      _currentPostId = postId;
    }
  }

  /// Toggle like on the main comment
  Future<void> toggleLike() async {
    try {
      final currentUserId = getCurrentUserId();
      if (currentUserId.isEmpty) return;

      final isCurrentlyLiked = currentComment.value.likes.contains(currentUserId);

      // Optimistically update UI
      List<String> updatedLikes = List.from(currentComment.value.likes);
      if (isCurrentlyLiked) {
        updatedLikes.remove(currentUserId);
      } else {
        updatedLikes.add(currentUserId);
      }

      _updateComment(likes: updatedLikes);

      // Update in Firestore
      await commentRepository.toggleCommentLike(
        currentComment.value.commentId,
        updatedLikes,
      );

    } catch (e) {
      // Revert optimistic update on error
      await _revertLike();
      _showError('Failed to update like', e.toString());
    }
  }

  /// Toggle like on any comment (for use in PostDetailsController)
  Future<void> toggleCommentLike(String commentId) async {
    try {
      final currentUserId = getCurrentUserId();

      final isCurrentlyLiked = currentComment.value.likes.contains(currentUserId);

      // Optimistically update UI
      List<String> updatedLikes = List.from(currentComment.value.likes);
      if (isCurrentlyLiked) {
        updatedLikes.remove(currentUserId);
      } else {
        updatedLikes.add(currentUserId);
      }

      _updateComment(likes: updatedLikes);

      // Update in Firestore
      await commentRepository.toggleCommentLike(
        commentId,
        updatedLikes,
      );

    } catch (e) {
      // Revert optimistic update on error
      await _revertLike();
      _showError('Failed to update like', e.toString());
    }
  }

  /// Add comment to a post
  Future<void> addComment(String postId) async {
    final content = commentController.text.trim();
    if (content.isEmpty) return;

    try {
      final newComment = Comment(
        commentId: _db.collection('temp').doc().id, // Generate ID
        userId: getCurrentUserId(),
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Clear input immediately for better UX
      commentController.clear();

      // Add to Firestore
      await commentRepository.addComment(postId, newComment);

      _showSuccess('Comment added successfully');

    } catch (e) {
      _showError('Failed to add comment', e.toString());
    }
  }

  /// Edit the main comment
  Future<void> edit(String newContent) async {
    final originalContent = currentComment.value.content;

    try {
      // Optimistically update UI
      _updateComment(content: newContent, updatedAt: DateTime.now());

      // Update in Firestore
      await commentRepository.updateComment(
        currentComment.value.commentId,
        newContent,
      );

      _showSuccess('Comment updated successfully');
    } catch (e) {
      // Revert on error
      _updateComment(content: originalContent);
      _showError('Failed to update comment', e.toString());
    }
  }

  /// Delete the main comment
  Future<void> delete() async {
    if (_currentPostId.isEmpty) return;

    try {
      final confirmed = await _showDeleteConfirmationDialog(
        'Delete Comment',
        'Are you sure you want to delete this comment? This action cannot be undone.',
      );

      if (!confirmed) return;

      // Delete from Firestore
      await commentRepository.deleteComment(
        _currentPostId,
        currentComment.value.commentId,
      );

      _showSuccess('Comment deleted successfully');

      // Navigate back
      Get.back();
    } catch (e) {
      _showError('Failed to delete comment', e.toString());
    }
  }

  /// Copy comment text to clipboard
  Future<void> copyText() async {
    try {
      await Clipboard.setData(ClipboardData(text: currentComment.value.content));
      _showSuccess('Text copied to clipboard');
    } catch (e) {
      _showError('Failed to copy text', e.toString());
    }
  }

  /// Report comment
  Future<void> report(String reason) async {
    try {
      // TODO: Implement reporting in repository
      _showSuccess('Comment reported. Thank you for your feedback.');
    } catch (e) {
      _showError('Failed to report comment', e.toString());
    }
  }

  /// Update reply count (called from RepliesController)
  void updateReplyCount(int delta) {
    final newCount = currentComment.value.replyCount + delta;
    _updateComment(replyCount: newCount.clamp(0, double.infinity).toInt());
  }

  /// Set current post ID
  void setPostId(String postId) {
    _currentPostId = postId;
  }

  /// Get current user ID
  String getCurrentUserId() {
    // TODO: Get from authentication service
    return 'current_user_id';
  }

  /// Get user name by ID
  String getUserName(String userId) {
    return _userCache[userId]?['name'] ?? 'User ${userId.substring(0, 4)}';
  }

  /// Get user avatar by ID
  String getUserAvatar(String userId) {
    return _userCache[userId]?['avatar'] ?? 'https://picsum.photos/100?random=${userId.hashCode}';
  }

  /// Check if current user can delete/edit comment
  bool canModify() {
    return currentComment.value.userId == getCurrentUserId();
  }

  /// Check if current user can delete/edit any comment
  bool canModifyComment(Comment comment) {
    return comment.userId == getCurrentUserId();
  }

  /// Clear comment data
  void clearData() {
    currentComment.value = Comment.empty();
    _currentPostId = '';
  }

  /// Format time ago (moved from PostDetailsController)
  String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    }
  }

  /// Private helper methods
  void _updateComment({
    String? content,
    List<String>? likes,
    int? replyCount,
    DateTime? updatedAt,
  }) {
    currentComment.value = Comment(
      commentId: currentComment.value.commentId,
      userId: currentComment.value.userId,
      content: content ?? currentComment.value.content,
      likes: likes ?? currentComment.value.likes,
      replyCount: replyCount ?? currentComment.value.replyCount,
      createdAt: currentComment.value.createdAt,
      updatedAt: updatedAt ?? currentComment.value.updatedAt,
      replies: currentComment.value.replies,
    );
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

  Future<void> _revertLike() async {
    try {
      final freshComment = await commentRepository.getCommentById(
        currentComment.value.commentId,
      );
      if (freshComment != null) {
        currentComment.value = freshComment;
      }
    } catch (e) {
      debugPrint('Failed to revert comment like: $e');
    }
  }

  void _initializeUserCache() {
    _userCache.addAll({
      'current_user_id': {
        'name': 'You',
        'avatar': 'https://picsum.photos/100?random=0',
      },
      'anna_mary': {
        'name': 'Anna Mary',
        'avatar': 'https://picsum.photos/100?random=1',
      },
      'mark_ramos': {
        'name': 'Mark Ramos',
        'avatar': 'https://picsum.photos/100?random=2',
      },
      'sarah_johnson': {
        'name': 'Sarah Johnson',
        'avatar': 'https://picsum.photos/100?random=3',
      },
      'mike_chen': {
        'name': 'Mike Chen',
        'avatar': 'https://picsum.photos/100?random=4',
      },
      'lisa_wong': {
        'name': 'Lisa Wong',
        'avatar': 'https://picsum.photos/100?random=5',
      },
      'david_kim': {
        'name': 'David Kim',
        'avatar': 'https://picsum.photos/100?random=6',
      },
    });
  }

  // Reference to Firestore for ID generation
  final _db = FirebaseFirestore.instance;
}