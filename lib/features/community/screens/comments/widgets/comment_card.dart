import 'package:flutter/material.dart';
import 'package:fyp/features/community/controllers/posts/post_detail_controller.dart';
import 'package:fyp/features/community/controllers/posts/reply_controller.dart';
import 'package:fyp/features/community/models/comment_model.dart';
import 'package:fyp/features/community/screens/comments/widgets/comment_reply.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/services.dart';
import 'package:fyp/features/community/controllers/posts/comment_controller.dart';

class FCommentCard extends StatelessWidget {
  final Comment comment;
  final String postId;
  final bool isInRepliesScreen;
  final bool isOriginalComment;

  const FCommentCard({
    super.key,
    required this.comment,
    required this.postId,
    this.isInRepliesScreen = false,
    this.isOriginalComment = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showContextMenu(context),
      child: Container(
        padding: EdgeInsets.all(isOriginalComment ? FSizes.md * 1.4 : FSizes.md * 1.2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User avatar
            CircleAvatar(
              radius: isOriginalComment ? 20 : 16,
              backgroundImage: NetworkImage(
                _getUserAvatar(comment.userId),
              ),
            ),

            const SizedBox(width: FSizes.md),

            // Comment content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User name and time
                  Row(
                    children: [
                      Text(
                        _getUserName(comment.userId),
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: FSizes.xs),
                      Text(
                        _formatTimeAgo(comment.createdAt),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: FSizes.spaceBtwItems),

                  // Comment content
                  Text(
                    comment.content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: isOriginalComment ? 1.4 : 1.3,
                    ),
                  ),

                  const SizedBox(height: FSizes.spaceBtwItems),

                  // Action buttons
                  _buildActionButtons(context),

                  // View replies if exist (only show in post details screen)
                  if (!isInRepliesScreen && comment.replyCount > 0) ...[
                    const SizedBox(height: FSizes.md),
                    GestureDetector(
                      onTap: () => _navigateToReplies(context, comment, false),
                      child: Text(
                        'View ${comment.replyCount} ${comment.replyCount == 1 ? 'reply' : 'replies'}',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                          color: const Color(0xFF4CAF50),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (isInRepliesScreen) {
      return _buildRepliesScreenButtons(context);
    } else {
      return _buildPostDetailsButtons(context);
    }
  }

  // Action buttons for community details screen
  Widget _buildPostDetailsButtons(BuildContext context) {
    // 检查控制器是否存在，如果不存在则使用默认值
    final bool hasCommentController = Get.isRegistered<CommentController>();
    final currentUserId = hasCommentController
        ? Get.find<CommentController>().getCurrentUserId()
        : 'current_user_id';

    final isLiked = comment.likes.contains(currentUserId);

    return Row(
      children: [
        // Like button with count
        GestureDetector(
          onTap: () {
            if (hasCommentController) {
              Get.find<CommentController>().toggleCommentLike(comment.commentId);
            }
          },
          child: Row(
            children: [
              Icon(
                isLiked ? Iconsax.like_15 : Iconsax.like_1,
                size: 16,
                color: isLiked ? const Color(0xFF4CAF50) : Colors.grey[600],
              ),
              if (comment.likes.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  comment.likes.length.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(width: FSizes.md),

        // Reply button
        GestureDetector(
          onTap: () => _navigateToReplies(context, comment, true),
          child: Text(
            'Reply',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // Action buttons for replies screen (original comment)
  Widget _buildRepliesScreenButtons(BuildContext context) {
    final bool hasCommentController = Get.isRegistered<CommentController>();
    final bool hasReplyController = Get.isRegistered<ReplyController>();

    if (!hasCommentController || !hasReplyController) {
      return const SizedBox.shrink();
    }

    final commentController = Get.find<CommentController>();
    final repliesController = Get.find<ReplyController>();
    final currentUserId = commentController.getCurrentUserId();

    return Obx(() {
      final isLiked = commentController.currentComment.value.likes.contains(currentUserId);
      final likesCount = commentController.currentComment.value.likes.length;

      return Row(
        children: [
          // Like button with count
          GestureDetector(
            onTap: () => commentController.toggleLike(),
            child: Row(
              children: [
                Icon(
                  isLiked ? Iconsax.like_15 : Iconsax.like_1,
                  size: 18,
                  color: isLiked ? const Color(0xFF4CAF50) : Colors.grey[600],
                ),
                if (likesCount > 0) ...[
                  const SizedBox(width: 4),
                  Text(
                    likesCount.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: FSizes.lg),

          // Reply button (focus input when tapped)
          GestureDetector(
            onTap: () => repliesController.replyFocusNode.requestFocus(),
            child: Row(
              children: [
                Icon(
                  Iconsax.message_text,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Reply',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  void _showContextMenu(BuildContext context) {
    final currentUserId = _getCurrentUserId();
    final isOwner = comment.userId == currentUserId;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(FSizes.defaultSpace),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Copy text option (always available)
            ListTile(
              leading: const Icon(Iconsax.copy),
              title: const Text('Copy Text'),
              onTap: () {
                _copyCommentText();
                Navigator.pop(context);
              },
            ),

            // Owner-only options
            if (isOwner) ...[
              ListTile(
                leading: const Icon(Iconsax.edit_2),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Iconsax.trash, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteDialog(context);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _copyCommentText() {
    if (isInRepliesScreen && Get.isRegistered<CommentController>()) {
      final commentController = Get.find<CommentController>();
      commentController.copyText();
    } else {
      Clipboard.setData(ClipboardData(text: comment.content));
      Get.snackbar('Copied', 'Comment text copied to clipboard');
    }
  }

  void _showEditDialog(BuildContext context) {
    final editController = TextEditingController(text: comment.content);

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Comment'),
        content: TextField(
          controller: editController,
          maxLines: null,
          decoration: const InputDecoration(
            hintText: 'Edit your comment...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (editController.text.trim().isNotEmpty) {
                _editComment(editController.text.trim());
                Get.back();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text(
            'Are you sure you want to delete this comment? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteComment();
              Get.back(); // Close dialog
              if (isOriginalComment) {
                Get.back(); // Close replies screen if deleting original comment
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _editComment(String newContent) {
    if (isInRepliesScreen && Get.isRegistered<CommentController>()) {
      final commentController = Get.find<CommentController>();
      commentController.edit(newContent);
    } else if (Get.isRegistered<PostDetailsController>()) {
      final controller = Get.find<PostDetailsController>();
      // controller.editComment(comment.commentId, newContent);
    }
  }

  void _deleteComment() {
    if (isInRepliesScreen && Get.isRegistered<CommentController>()) {
      final commentController = Get.find<CommentController>();
      commentController.delete();
    } else if (Get.isRegistered<PostDetailsController>()) {
      final controller = Get.find<PostDetailsController>();
      // controller.deleteComment(comment.commentId);
    }
  }

  void _navigateToReplies(BuildContext context, Comment comment, bool autoFocus) {
    Get.to(() => CommentRepliesScreen(
      postId: postId,
      comment: comment,
      autoFocusReply: autoFocus,
    ));
  }

  String _getCurrentUserId() {
    if (isInRepliesScreen && Get.isRegistered<CommentController>()) {
      final commentController = Get.find<CommentController>();
      return commentController.getCurrentUserId();
    } else if (Get.isRegistered<PostDetailsController>()) {
      final controller = Get.find<PostDetailsController>();
      return controller.getCurrentUserId();
    }
    return 'current_user_id';
  }

  String _getUserAvatar(String userId) {
    if (isInRepliesScreen && Get.isRegistered<CommentController>()) {
      final commentController = Get.find<CommentController>();
      return commentController.getUserAvatar(userId);
    } else if (Get.isRegistered<PostDetailsController>()) {
      final controller = Get.find<PostDetailsController>();
      return controller.getUserAvatar(userId);
    }
    return 'https://picsum.photos/100?random=${userId.hashCode}';
  }

  String _getUserName(String userId) {
    if (isInRepliesScreen && Get.isRegistered<CommentController>()) {
      final commentController = Get.find<CommentController>();
      return commentController.getUserName(userId);
    } else if (Get.isRegistered<PostDetailsController>()) {
      final controller = Get.find<PostDetailsController>();
      return controller.getUserName(userId);
    }
    return 'User ${userId.substring(0, 4)}';
  }

  String _formatTimeAgo(DateTime dateTime) {
    if (isInRepliesScreen && Get.isRegistered<CommentController>()) {
      final commentController = Get.find<CommentController>();
      return commentController.formatTimeAgo(dateTime);
    } else {
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h';
      } else if (difference.inDays < 30) {
        return '${difference.inDays}d';
      } else {
        final months = (difference.inDays / 30).floor();
        return '${months}mo';
      }
    }
  }
}