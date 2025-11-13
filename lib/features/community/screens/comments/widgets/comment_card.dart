import 'package:flutter/material.dart';
import 'package:fyp/features/community/controllers/posts/comment_controller.dart';
import 'package:fyp/features/community/models/comment_model.dart';
import 'package:fyp/features/community/screens/comments/widgets/comment_reply.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/utils/popups/loaders.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../utils/formatters/formatter.dart';
import '../../../controllers/posts/reply_controller.dart';
import '../../common_post_widgets/common_post_widgets.dart';

class FCommentCard extends StatelessWidget {
  final Comment comment;
  final String postId;
  final bool isInRepliesScreen;
  final bool isOriginalComment;
  final bool isPostDisabled;

  const FCommentCard({
    super.key,
    required this.comment,
    required this.postId,
    this.isInRepliesScreen = false,
    this.isOriginalComment = false,
    this.isPostDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    // 使用 Get.find 获取 CommentController，如果找不到则使用 Get.put 创建
    final CommentController commentController = Get.find<CommentController>();
    final dark = FHelperFunctions.isDarkMode(context);

    return GestureDetector(
      onLongPress: isPostDisabled ? null : () => _showContextMenu(context, commentController, dark),
      child: Container(
        padding: EdgeInsets.all(isOriginalComment ? FSizes.md * 1.4 : FSizes.md * 1.2),
        color: dark ? FColors.communityDarkBackground : FColors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User avatar
            FUserAvatar(
              userId: comment.userId,
              radius: isOriginalComment ? 20 : 16,
            ),
            const SizedBox(width: FSizes.md),

            // Comment content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User name and time
                  FUserInfoRow(
                    userId: comment.userId,
                    createdAt: comment.createdAt,
                    updatedAt: comment.updatedAt,
                    formatTimeAgo: FFormatter.formatTimeAgo,
                  ),
                  const SizedBox(height: FSizes.spaceBtwItems * 1.5),

                  // Comment content
                  Text(
                    comment.content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: isOriginalComment ? 1.4 : 1.3,
                      color: dark ? FColors.darkText : FColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: FSizes.spaceBtwItems * 1.5),

                  // Action buttons - Disabled if post is disabled
                  if (isPostDisabled)
                    Opacity(
                      opacity: 0.5,
                      child: IgnorePointer(
                        child: _buildActionButtons(context, commentController, dark),
                      ),
                    )
                  else
                    _buildActionButtons(context, commentController, dark),

                  // View replies (only in post details screen) - Disabled if post is disabled
                  if (!isInRepliesScreen && comment.replyCount > 0) ...[
                    const SizedBox(height: FSizes.md),
                    if (isPostDisabled)
                      Opacity(
                        opacity: 0.5,
                        child: IgnorePointer(
                          child: _buildViewRepliesButton(context, comment),
                        ),
                      )
                    else
                      _buildViewRepliesButton(context, comment),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewRepliesButton(BuildContext context, Comment comment) {
    return GestureDetector(
      onTap: () => _navigateToReplies(context, comment, false),
      child: Text(
        'View ${comment.replyCount} ${comment.replyCount == 1 ? 'reply' : 'replies'}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: FColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, CommentController commentController, bool dark) {
    if (isInRepliesScreen) {
      return _buildRepliesScreenButtons(context, commentController, dark);
    } else {
      return _buildPostDetailsButtons(context, dark);
    }
  }

  Widget _buildPostDetailsButtons(BuildContext context, bool dark) {
    final CommentController commentController = Get.find<CommentController>();
    final currentUserId = commentController.getCurrentUserId();
    final isLiked = comment.likes.contains(currentUserId);

    return Row(
      children: [
        // Like button
        FLikeButton(
          likes: comment.likes,
          isLiked: isLiked,
          onTap: () => commentController.toggleCommentLike(comment.commentId),
        ),
        const SizedBox(width: FSizes.md),

        // Reply button
        GestureDetector(
          onTap: () => _navigateToReplies(context, comment, true),
          child: Text(
            'Reply',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: dark ? FColors.darkTextSecondary : FColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRepliesScreenButtons(BuildContext context, CommentController commentController, bool dark) {
    final currentUserId = commentController.getCurrentUserId();

    return Obx(() {
      final isLiked = commentController.currentComment.value.likes.contains(currentUserId);
      final likesCount = commentController.currentComment.value.likes.length;

      return Row(
        children: [
          // Like button
          FLikeButton(
            likes: commentController.currentComment.value.likes,
            isLiked: isLiked,
            onTap: () => commentController.toggleLike(),
          ),
          const SizedBox(width: FSizes.lg),

          // Reply button
          GestureDetector(
            onTap: () {
              final repliesController = Get.find<ReplyController>();
              repliesController.replyFocusNode.requestFocus();
            },
            child: Row(
              children: [
                Icon(
                  Iconsax.message_text,
                  size: 16,
                  color: dark ? FColors.darkTextSecondary : FColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Reply',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: dark ? FColors.darkTextSecondary : FColors.textSecondary,
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

  void _showContextMenu(BuildContext context, CommentController commentController, bool dark) {
    final canModify = commentController.canModifyComment(comment);

    FLoaders.showBottomSheet(
      FContextMenuBottomSheet(
        content: comment.content,
        canModify: canModify,
        onCopy: () => commentController.copyText(comment.content),
        onEdit: canModify ? () => commentController.startEdit(comment) : null,
        onDelete: canModify ? () => commentController.deleteComment(comment) : null,
      ),
    );
  }

  void _navigateToReplies(BuildContext context, Comment comment, bool autoFocus) {
    if (isPostDisabled) return;

    // 确保在进入回复页面之前 CommentController 已经初始化
    final CommentController commentController = Get.find<CommentController>();
    commentController.initialize(comment, postId: postId);

    Get.to(() => CommentRepliesScreen(
      postId: postId,
      comment: comment,
      autoFocusReply: autoFocus,
      isPostDisabled: isPostDisabled,
    ));
  }
}