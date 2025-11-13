import 'package:flutter/material.dart';
import 'package:fyp/common/widgets/appbar/appbar.dart';
import 'package:fyp/features/community/controllers/posts/comment_controller.dart';
import 'package:fyp/features/community/controllers/posts/reply_controller.dart';
import 'package:fyp/features/community/models/comment_model.dart';
import 'package:fyp/features/community/models/reply_model.dart';
import 'package:fyp/features/community/screens/comments/widgets/comment_card.dart';
import 'package:fyp/features/community/screens/common_post_widgets/common_post_widgets.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/utils/popups/loaders.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../utils/formatters/formatter.dart';

class CommentRepliesScreen extends StatefulWidget {
  final String postId;
  final Comment comment;
  final bool autoFocusReply;
  final bool isPostDisabled;

  const CommentRepliesScreen({
    super.key,
    required this.postId,
    required this.comment,
    this.autoFocusReply = false,
    this.isPostDisabled = false,
  });

  @override
  State<CommentRepliesScreen> createState() => _CommentRepliesScreenState();
}

class _CommentRepliesScreenState extends State<CommentRepliesScreen> {
  final _commentController = Get.put(CommentController());
  final _repliesController = Get.put(ReplyController());
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Initialize comment controller first
    await _commentController.initialize(widget.comment, postId: widget.postId);

    // Then initialize replies controller
    await _repliesController.initialize(
      widget.postId,
      widget.comment.commentId,
      autoFocus: widget.autoFocusReply && !widget.isPostDisabled,
    );

    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.communityDarkBackground : FColors.white,
      appBar: FAppBar(
        title: const Text('Replies'),
        showBackArrow: true,
        backgroundColor: dark ? FColors.communityDarkBackground : FColors.white,
      ),
      body: _buildBody(dark),
    );
  }

  Widget _buildBody(bool dark) {
    // Show full screen loading while initializing or loading user data
    if (!_isInitialized) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: FColors.primary,
              backgroundColor: dark ? FColors.communityDarkBorder : FColors.grey.withOpacity(0.2),
            ),
            const SizedBox(height: FSizes.md),
            Text(
              'Loading...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: dark ? FColors.darkTextSecondary : FColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Show content when loaded
    return Column(
      children: [
        // Main content
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _repliesController.refreshReplies(),
            color: FColors.primary,
            backgroundColor: dark ? FColors.communityDarkSurface : FColors.white,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                color: dark ? FColors.communityDarkBackground : FColors.white,
                child: Column(
                  children: [
                    // Original comment
                    FCommentCard(
                      comment: widget.comment,
                      postId: widget.postId,
                      isInRepliesScreen: true,
                      isOriginalComment: true,
                      isPostDisabled: widget.isPostDisabled,
                    ),

                    // Divider
                    Container(
                      height: 1,
                      color: dark ? FColors.communityDarkDivider : FColors.grey.withOpacity(0.2),
                      margin: const EdgeInsets.symmetric(horizontal: FSizes.md),
                    ),

                    // Replies list
                    _RepliesList(isPostDisabled: widget.isPostDisabled),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Write reply input - Disabled if post is disabled
        if (widget.isPostDisabled)
          _buildDisabledOverlay(context, dark)
        else
          _buildReplyInput(),
      ],
    );
  }

  Widget _buildReplyInput() {
    return Obx(() {
      // 使用可观察变量来触发 Obx 更新
      final isSubmitting = _repliesController.isSubmitting.value;
      final isEditMode = _repliesController.isEditMode.value;

      return FInputField(
        controller: _repliesController.replyController,
        focusNode: _repliesController.replyFocusNode,
        isEnabled: !isSubmitting,
        isSubmitting: isSubmitting,
        hintText: 'Write a reply...',
        isEditMode: isEditMode,
        onSubmit: () {
          if (isEditMode) {
            _repliesController.saveEdit();
          } else {
            _repliesController.submitReply();
          }
        },
        onCancel: () => _repliesController.cancelEdit(),
        isComment: false,
      );
    });
  }

  Widget _buildDisabledOverlay(BuildContext context, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark ? FColors.communityDarkSurface : FColors.white,
        border: Border(
          top: BorderSide(
            color: dark ? FColors.communityDarkBorder : FColors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: FColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Iconsax.slash,
              color: FColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: FSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Replies Disabled',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: FColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'This post has been disabled',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: dark ? FColors.darkTextSecondary : FColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Replies list widget
class _RepliesList extends StatelessWidget {
  final bool isPostDisabled;

  const _RepliesList({this.isPostDisabled = false});

  @override
  Widget build(BuildContext context) {
    final repliesController = Get.find<ReplyController>();
    final dark = FHelperFunctions.isDarkMode(context);

    return Obx(() {
      // 使用可观察变量来触发 Obx 更新
      final replies = repliesController.replies;

      // Empty state
      if (replies.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: FSizes.spaceBtwSections * 2),
          child: FEmptyState(
            icon: Iconsax.message_text,
            title: 'No replies yet',
            subtitle: isPostDisabled
                ? 'This post has been disabled'
                : 'Be the first to reply!',
          ),
        );
      }

      // Replies list
      return Container(
        color: dark ? FColors.communityDarkBackground : FColors.white,
        child: Column(
          children: replies
              .map((reply) => _ReplyCard(
            reply: reply,
            isPostDisabled: isPostDisabled,
          ))
              .toList(),
        ),
      );
    });
  }
}

/// Individual Reply Card
class _ReplyCard extends StatelessWidget {
  final Reply reply;
  final bool isPostDisabled;

  const _ReplyCard({
    required this.reply,
    this.isPostDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final commentController = Get.find<CommentController>();
    final repliesController = Get.find<ReplyController>();
    final dark = FHelperFunctions.isDarkMode(context);
    final currentUserId = commentController.getCurrentUserId();

    return GestureDetector(
      onLongPress: isPostDisabled
          ? null
          : () => _showReplyContextMenu(context, commentController, repliesController, dark),
      child: Container(
        color: dark ? FColors.communityDarkBackground : FColors.white,
        margin: const EdgeInsets.only(left: FSizes.lg),
        padding: const EdgeInsets.symmetric(
          horizontal: FSizes.md,
          vertical: FSizes.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User avatar
            FUserAvatar(userId: reply.userId, radius: 14),
            const SizedBox(width: FSizes.md),

            // Reply content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User name and time
                  FUserInfoRow(
                    userId: reply.userId,
                    createdAt: reply.createdAt,
                    updatedAt: reply.updatedAt,
                    formatTimeAgo: FFormatter.formatTimeAgo,
                  ),
                  const SizedBox(height: FSizes.md),

                  // Reply content
                  Text(
                    reply.content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.3,
                      color: dark ? FColors.darkText : FColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: FSizes.md),

                  // Like button - Disabled if post is disabled
                  if (isPostDisabled)
                    Opacity(
                      opacity: 0.5,
                      child: IgnorePointer(
                        child: _buildLikeButton(currentUserId, repliesController),
                      ),
                    )
                  else
                    _buildLikeButton(currentUserId, repliesController),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLikeButton(String currentUserId, ReplyController repliesController) {
    return Obx(() {
      // 使用可观察变量来触发 Obx 更新
      final currentReplies = repliesController.replies;
      final currentReply = currentReplies.firstWhere(
            (r) => r.replyId == reply.replyId,
        orElse: () => reply,
      );
      final isLiked = currentReply.likes.contains(currentUserId);

      return FLikeButton(
        likes: currentReply.likes,
        isLiked: isLiked,
        onTap: () => repliesController.toggleReplyLike(reply.replyId),
      );
    });
  }

  void _showReplyContextMenu(
      BuildContext context,
      CommentController commentController,
      ReplyController repliesController,
      bool dark,
      ) {
    final canModify = repliesController.canModifyReply(reply);

    FLoaders.showBottomSheet(
      FContextMenuBottomSheet(
        content: reply.content,
        canModify: canModify,
        onCopy: () => repliesController.copyReplyText(reply.content),
        onEdit: canModify ? () => repliesController.startEdit(reply) : null,
        onDelete: canModify ? () => repliesController.deleteReply(reply) : null,
      ),
    );
  }
}