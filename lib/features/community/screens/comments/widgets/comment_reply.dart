import 'package:flutter/material.dart';
import 'package:fyp/features/community/controllers/posts/comment_controller.dart';
import 'package:fyp/features/community/controllers/posts/reply_controller.dart';
import 'package:fyp/features/community/models/reply_model.dart';
import 'package:fyp/features/community/screens/comments/widgets/comment_card.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/features/community/models/comment_model.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/common/widgets/appbar/appbar.dart';

// Comment Replies Screen
class CommentRepliesScreen extends StatelessWidget {
  final String postId;
  final Comment comment;
  final bool autoFocusReply;

  const CommentRepliesScreen({
    super.key,
    required this.postId,
    required this.comment,
    this.autoFocusReply = false,
  });

  @override
  Widget build(BuildContext context) {
    final commentController = Get.put(CommentController());
    final repliesController = Get.put(ReplyController());

    // Initialize with comment data and auto focus if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      commentController.initialize(comment, postId: postId);
      repliesController.initialize(postId, comment.commentId, autoFocus: autoFocusReply);
    });

    return Scaffold(
      backgroundColor: Colors.white, // 改为白色
      appBar: const FAppBar(
        title: Text('Replies'),
        showBackArrow: true,
      ),
      body: Column(
        children: [
          // Main content with refresh indicator
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => repliesController.refreshReplies(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  color: Colors.white, // 改为白色
                  child: Column(
                    children: [
                      // Original comment using unified FCommentCard
                      FCommentCard(
                        comment: comment,
                        postId: postId,
                        isInRepliesScreen: true,
                        isOriginalComment: true,
                      ),

                      // Divider
                      Container(
                        height: 1,
                        color: Colors.grey[200],
                        margin: const EdgeInsets.symmetric(horizontal: FSizes.md),
                      ),

                      // Replies list
                      FRepliesList(replies: repliesController.replies),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Write reply input at bottom
          const FWriteReplyInput(),
        ],
      ),
    );
  }
}

// Write Reply Input Widget
class FWriteReplyInput extends StatelessWidget {
  const FWriteReplyInput({super.key});

  @override
  Widget build(BuildContext context) {
    final commentController = Get.find<CommentController>();
    final repliesController = Get.find<ReplyController>();

    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: FSizes.md,
        right: FSizes.md,
        top: FSizes.sm,
        bottom: MediaQuery.of(context).padding.bottom + FSizes.sm,
      ),
      child: Row(
        children: [
          // User avatar
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(
              commentController.getUserAvatar(commentController.getCurrentUserId()),
            ),
          ),

          const SizedBox(width: FSizes.sm),

          // Input field
          Expanded(
            child: Obx(() => TextField(
              controller: repliesController.replyController,
              focusNode: repliesController.replyFocusNode,
              enabled: !repliesController.isSubmitting.value,
              decoration: InputDecoration(
                hintText: 'Write a reply...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: repliesController.isSubmitting.value
                    ? Colors.grey[200]
                    : Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: FSizes.md,
                  vertical: FSizes.sm,
                ),
                suffixIcon: repliesController.isSubmitting.value
                    ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
                    : null,
              ),
              maxLines: null,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _handleSubmit(repliesController),
            )),
          ),

          const SizedBox(width: FSizes.sm),

          // Send button - FIXED: 使用 isReplyValid 来更新颜色
          Obx(() {
            final isValid = repliesController.isReplyValid.value;
            final isSubmitting = repliesController.isSubmitting.value;

            return GestureDetector(
              onTap: isValid && !isSubmitting
                  ? () => _handleSubmit(repliesController)
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getSendButtonColor(isValid, isSubmitting),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _getSendButtonIcon(isSubmitting),
                  color: Colors.white,
                  size: 20,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _handleSubmit(ReplyController controller) {
    if (controller.isReplyValid.value && !controller.isSubmitting.value) {
      controller.submitReply();
    }
  }

  Color _getSendButtonColor(bool isValid, bool isSubmitting) {
    if (isSubmitting) {
      return Colors.grey[400]!;
    } else if (isValid) {
      return const Color(0xFF4CAF50); // 青色
    } else {
      return Colors.grey[300]!;
    }
  }

  IconData _getSendButtonIcon(bool isSubmitting) {
    if (isSubmitting) {
      return Icons.hourglass_empty;
    } else {
      return Icons.send;
    }
  }
}

// Replies List Widget
class FRepliesList extends StatelessWidget {
  final RxList<Reply> replies;

  const FRepliesList({
    super.key,
    required this.replies,
  });

  @override
  Widget build(BuildContext context) {
    final repliesController = Get.find<ReplyController>();

    return Obx(() {
      // Show loading indicator for initial load
      if (repliesController.isLoading.value && replies.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(FSizes.defaultSpace),
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Show empty state
      if (replies.isEmpty && !repliesController.isLoading.value) {
        return Container(
          padding: const EdgeInsets.all(FSizes.defaultSpace),
          color: Colors.white, // 改为白色
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Iconsax.message_text,
                  size: 48,
                  color: Colors.grey,
                ),
                SizedBox(height: FSizes.sm),
                Text(
                  'No replies yet',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: FSizes.xs),
                Text(
                  'Be the first to reply!',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Show replies list
      return Container(
        color: Colors.white, // 改为白色
        child: Column(
          children: replies.map((reply) => FReplyCard(reply: reply)).toList(),
        ),
      );
    });
  }
}

// Individual Reply Card
class FReplyCard extends StatelessWidget {
  final Reply reply;

  const FReplyCard({super.key, required this.reply});

  @override
  Widget build(BuildContext context) {
    final commentController = Get.find<CommentController>();
    final repliesController = Get.find<ReplyController>();

    return GestureDetector(
      onLongPress: () => _showReplyContextMenu(context, commentController, repliesController),
      child: Container(
        color: Colors.white, // 改为白色
        margin: const EdgeInsets.only(left: FSizes.lg), // Indent for replies
        padding: const EdgeInsets.symmetric(
          horizontal: FSizes.md,
          vertical: FSizes.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User avatar (smaller for replies)
            CircleAvatar(
              radius: 14,
              backgroundImage: NetworkImage(
                commentController.getUserAvatar(reply.userId),
              ),
            ),

            const SizedBox(width: FSizes.md),

            // Reply content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User name and time
                  Row(
                    children: [
                      Text(
                        commentController.getUserName(reply.userId),
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: FSizes.md),
                      Text(
                        commentController.formatTimeAgo(reply.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      // Show edited indicator if reply was edited
                      if (reply.updatedAt.isAfter(reply.createdAt.add(const Duration(minutes: 1)))) ...[
                        const SizedBox(width: FSizes.xs),
                        Text(
                          '(edited)',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: FSizes.md),

                  // Reply content
                  Text(
                    reply.content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: FSizes.md),

                  // Action buttons
                  Row(
                    children: [
                      // Like button with count
                      GestureDetector(
                        onTap: () => repliesController.toggleReplyLike(reply.replyId),
                        child: Row(
                          children: [
                            Obx(() {
                              final currentUserId = commentController.getCurrentUserId();
                              final currentReply = repliesController.replies.firstWhere(
                                    (r) => r.replyId == reply.replyId,
                                orElse: () => reply,
                              );
                              final isLiked = currentReply.likes.contains(currentUserId);

                              return Icon(
                                isLiked ? Iconsax.like_15 : Iconsax.like_1,
                                size: 16,
                                color: isLiked
                                    ? const Color(0xFF4CAF50)
                                    : Colors.grey[600],
                              );
                            }),
                            const SizedBox(width: 4),
                            Obx(() {
                              final currentReply = repliesController.replies.firstWhere(
                                    (r) => r.replyId == reply.replyId,
                                orElse: () => reply,
                              );
                              if (currentReply.likes.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return Text(
                                currentReply.likes.length.toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReplyContextMenu(BuildContext context, CommentController commentController, ReplyController repliesController) {
    final canModify = repliesController.canModifyReply(reply);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white, // 改为白色
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(FSizes.defaultSpace),
        color: Colors.white, // 改为白色
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: FSizes.md),

            // Copy text option (always available)
            ListTile(
              leading: const Icon(Iconsax.copy),
              title: const Text('Copy Text'),
              onTap: () {
                Navigator.pop(context);
                repliesController.copyReplyText(reply.content);
              },
            ),

            // Owner-only options
            if (canModify) ...[
              ListTile(
                leading: const Icon(Iconsax.edit_2),
                title: const Text('Edit Reply'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditReplyDialog(context, repliesController);
                },
              ),
              ListTile(
                leading: const Icon(Iconsax.trash, color: Colors.red),
                title: const Text('Delete Reply', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  repliesController.deleteReply(reply.replyId);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showEditReplyDialog(BuildContext context, ReplyController controller) {
    final editController = TextEditingController(text: reply.content);

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white, // 改为白色
        title: const Text('Edit Reply'),
        content: TextField(
          controller: editController,
          maxLines: null,
          decoration: const InputDecoration(
            hintText: 'Edit your reply...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newContent = editController.text.trim();
              if (newContent.isNotEmpty && newContent != reply.content) {
                controller.editReply(reply.replyId, newContent);
                Get.back();
              } else {
                Get.back();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}