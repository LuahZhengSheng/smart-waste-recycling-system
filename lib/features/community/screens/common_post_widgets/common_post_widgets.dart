import 'package:flutter/material.dart';
import 'package:fyp/data/repositories/user/user_repository.dart';
import 'package:fyp/features/community/models/post_enums.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/features/community/controllers/posts/comment_controller.dart';

import '../../controllers/posts/reply_controller.dart';

class FUserInfo extends StatelessWidget {
  final String userId;
  final String timeAgo;
  final PostType postType;
  final bool showMenuButton;
  final VoidCallback? onMenuPressed; // 保持可空

  const FUserInfo({
    super.key,
    required this.userId,
    required this.timeAgo,
    required this.postType,
    this.showMenuButton = false,
    this.onMenuPressed, // 保持可选
  });

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);
    final userRepo = Get.put(UserRepository());

    return Row(
      children: [
        // User avatar
        StreamBuilder<String?>(
          stream: userRepo.getUserDetailsStream(userId).map((user) => user.profileImg),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return FutureBuilder<String?>(
                future: userRepo.getProfileImageUrl(snapshot.data!),
                builder: (context, urlSnapshot) {
                  if (urlSnapshot.hasData && urlSnapshot.data != null) {
                    return CircleAvatar(
                      radius: FSizes.iconMd,
                      backgroundImage: NetworkImage(urlSnapshot.data!),
                      backgroundColor: Colors.transparent,
                    );
                  }
                  return _buildDefaultAvatar(dark);
                },
              );
            }
            return _buildDefaultAvatar(dark);
          },
        ),
        const SizedBox(width: FSizes.spaceBtwItems),

        // User info, post type and menu button in same row
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Username, post type and menu button in same row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // User name
                  Expanded(
                    child: StreamBuilder<String>(
                      stream: userRepo.getUserDetailsStream(userId).map((user) => user.username),
                      builder: (context, snapshot) {
                        final username = snapshot.data ?? 'Loading...';
                        return Text(
                          username,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: dark ? FColors.white : FColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: FSizes.sm),

                  // Post type tag
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.25,
                    ),
                    child: FPostTypeTag(postType: postType),
                  ),

                  const SizedBox(width: FSizes.sm),

                  // Menu button - 现在与用户名在同一行
                  if (showMenuButton && onMenuPressed != null)
                    FMenuButton(
                      onPressed: onMenuPressed!, // 使用 ! 断言非空，或者提供默认值
                    ),
                ],
              ),

              const SizedBox(height: FSizes.xs),

              // Time ago
              Text(
                timeAgo,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: dark ? FColors.darkGrey : FColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar(bool dark) {
    return CircleAvatar(
      radius: FSizes.iconMd,
      backgroundColor: dark ? FColors.darkGrey : FColors.grey.withOpacity(0.3),
      child: Icon(
        Icons.person,
        size: FSizes.iconMd,
        color: dark ? FColors.white : FColors.darkGrey,
      ),
    );
  }
}

/// Post type 标签组件
class FPostTypeTag extends StatelessWidget {
  final PostType postType;

  const FPostTypeTag({super.key, required this.postType});

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FSizes.sm,
        vertical: FSizes.xs,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(dark),
        borderRadius: BorderRadius.circular(FSizes.borderRadiusSm * 2),
      ),
      child: Text(
        _getDisplayText(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: _getTextColor(dark),
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  String _getDisplayText() {
    switch (postType) {
      case PostType.tip:
        return 'Tip';
      case PostType.question:
        return 'Q&A';
      case PostType.discussion:
        return 'Discussion';
    }
  }

  Color _getBackgroundColor(bool dark) {
    if (dark) {
      switch (postType) {
        case PostType.tip:
          return FColors.success.withOpacity(0.2);
        case PostType.question:
          return FColors.info.withOpacity(0.2);
        case PostType.discussion:
          return FColors.warning.withOpacity(0.2);
      }
    } else {
      switch (postType) {
        case PostType.tip:
          return FColors.lightGreen.withOpacity(0.2);
        case PostType.question:
          return FColors.info.withOpacity(0.1);
        case PostType.discussion:
          return FColors.warning.withOpacity(0.1);
      }
    }
  }

  Color _getTextColor(bool dark) {
    switch (postType) {
      case PostType.tip:
        return dark ? FColors.lightGreen : FColors.success;
      case PostType.question:
        return dark ? Colors.lightBlue : FColors.info;
      case PostType.discussion:
        return dark ? Colors.orangeAccent : FColors.warning;
    }
  }
}

/// 三点菜单按钮
class FMenuButton extends StatelessWidget {
  final VoidCallback onPressed;

  const FMenuButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        Icons.more_vert,
        color: dark ? FColors.darkGrey : FColors.grey,
      ),
      iconSize: FSizes.iconMd,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(),
    );
  }
}

/// 空状态组件
class FEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const FEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(FSizes.defaultSpace * 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: FColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 64,
                  color: FColors.primary.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: FSizes.spaceBtwItems),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: dark ? FColors.white : FColors.black,
                ),
              ),
              const SizedBox(height: FSizes.sm),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: dark ? FColors.darkGrey : FColors.textSecondary,
                ),
              ),
              if (actionText != null && onActionPressed != null) ...[
                const SizedBox(height: FSizes.spaceBtwSections),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: FColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: onActionPressed,
                    icon: const Icon(Iconsax.edit_2, size: 20),
                    label: Text(
                      actionText!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FColors.primary,
                      foregroundColor: FColors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: FSizes.lg * 1.5,
                        vertical: FSizes.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 加载骨架屏组件
class FPostSkeleton extends StatelessWidget {
  const FPostSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      margin: const EdgeInsets.only(bottom: FSizes.spaceBtwItems),
      decoration: BoxDecoration(
        color: dark ? FColors.darkerGrey : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        border: Border.all(
          color: dark
              ? FColors.darkGrey.withOpacity(0.3)
              : FColors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info skeleton
          Row(
            children: [
              _buildShimmer(40, 40, isCircle: true, dark: dark),
              const SizedBox(width: FSizes.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmer(80, 12, dark: dark),
                  const SizedBox(height: FSizes.xs),
                  _buildShimmer(60, 10, dark: dark),
                ],
              ),
            ],
          ),
          const SizedBox(height: FSizes.spaceBtwItems),

          // Content skeleton
          _buildShimmer(double.infinity, 12, dark: dark),
          const SizedBox(height: FSizes.xs),
          _buildShimmer(250, 12, dark: dark),
          const SizedBox(height: FSizes.xs),
          _buildShimmer(180, 12, dark: dark),

          const SizedBox(height: FSizes.spaceBtwItems),

          // Actions skeleton
          Row(
            children: [
              _buildShimmer(60, 32, dark: dark),
              const SizedBox(width: FSizes.spaceBtwItems),
              _buildShimmer(60, 32, dark: dark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer(double width, double height,
      {bool isCircle = false, required bool dark}) {
    return Container(
      width: width == double.infinity ? null : width,
      height: height,
      decoration: BoxDecoration(
        color: dark
            ? FColors.darkGrey.withOpacity(0.3)
            : FColors.grey.withOpacity(0.3),
        borderRadius: isCircle
            ? BorderRadius.circular(height / 2)
            : BorderRadius.circular(FSizes.borderRadiusSm),
      ),
    );
  }
}

/// Shared user avatar widget
class FUserAvatar extends StatelessWidget {
  final String userId;
  final double radius;

  const FUserAvatar({
    super.key,
    required this.userId,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final commentController = Get.find<CommentController>();
    final dark = FHelperFunctions.isDarkMode(context);

    return Obx(() {
      final profileImg = commentController.getProfileImage(userId);

      if (profileImg.isNotEmpty) {
        return CircleAvatar(
          radius: radius,
          backgroundImage: NetworkImage(profileImg),
          backgroundColor: Colors.transparent,
        );
      }

      return CircleAvatar(
        radius: radius,
        backgroundColor: dark ? FColors.darkGrey : FColors.grey.withOpacity(0.3),
        child: Icon(
          Icons.person,
          size: radius,
          color: dark ? FColors.white : FColors.darkGrey,
        ),
      );
    });
  }
}

/// Shared user info row (username + time + edited indicator)
class FUserInfoRow extends StatelessWidget {
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String Function(DateTime) formatTimeAgo;

  const FUserInfoRow({
    super.key,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.formatTimeAgo,
  });

  @override
  Widget build(BuildContext context) {
    final commentController = Get.find<CommentController>();
    final dark = FHelperFunctions.isDarkMode(context);

    return Row(
      children: [
        Obx(() {
          final username = commentController.getUsername(userId);
          return Text(
            username,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: dark ? FColors.white : FColors.textPrimary,
            ),
          );
        }),
        const SizedBox(width: FSizes.sm),
        Text(
          formatTimeAgo(createdAt),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: dark ? FColors.darkTextSecondary : FColors.textSecondary,
          ),
        ),
        if (updatedAt.isAfter(createdAt.add(const Duration(minutes: 1)))) ...[
          const SizedBox(width: FSizes.xs),
          Text(
            '(edited)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: dark ? FColors.darkTextSecondary : FColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}

/// Shared like button
class FLikeButton extends StatelessWidget {
  final List<String> likes;
  final VoidCallback onTap;
  final bool isLiked;

  const FLikeButton({
    super.key,
    required this.likes,
    required this.onTap,
    required this.isLiked,
  });

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            isLiked ? Iconsax.like_15 : Iconsax.like_1,
            size: 16,
            color: isLiked
                ? FColors.primary
                : (dark ? FColors.darkTextSecondary : FColors.textSecondary),
          ),
          if (likes.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              likes.length.toString(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: dark ? FColors.darkTextSecondary : FColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shared context menu (copy, edit, delete)
class FContextMenuBottomSheet extends StatelessWidget {
  final String content;
  final bool canModify;
  final VoidCallback onCopy;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const FContextMenuBottomSheet({
    super.key,
    required this.content,
    required this.canModify,
    required this.onCopy,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.all(FSizes.defaultSpace),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Copy text option
          ListTile(
            leading: Icon(
              Iconsax.copy,
              color: dark ? FColors.darkText : FColors.textPrimary,
            ),
            title: Text(
              'Copy Text',
              style: TextStyle(
                color: dark ? FColors.darkText : FColors.textPrimary,
              ),
            ),
            onTap: () {
              Get.back();
              onCopy();
            },
          ),

          // Owner-only options
          if (canModify && onEdit != null) ...[
            ListTile(
              leading: Icon(
                Iconsax.edit_2,
                color: dark ? FColors.darkText : FColors.textPrimary,
              ),
              title: Text(
                'Edit',
                style: TextStyle(
                  color: dark ? FColors.darkText : FColors.textPrimary,
                ),
              ),
              onTap: () {
                Get.back();
                onEdit!();
              },
            ),
          ],
          if (canModify && onDelete != null) ...[
            ListTile(
              leading: const Icon(Iconsax.trash, color: FColors.error),
              title: const Text('Delete', style: TextStyle(color: FColors.error)),
              onTap: () {
                Get.back();
                onDelete!();
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// Shared input field for comments/replies
class FInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isEnabled;
  final bool isSubmitting;
  final String hintText;
  final VoidCallback? onSubmit;
  final VoidCallback? onCancel;
  final bool isEditMode;
  final bool isComment; // 新增参数：区分评论和回复

  const FInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isEnabled,
    required this.isSubmitting,
    required this.hintText,
    this.onSubmit,
    this.onCancel,
    this.isEditMode = false,
    this.isComment = true, // 默认为评论输入框
  });

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    // 根据 isComment 参数选择正确的控制器
    final commentController = Get.find<CommentController>();
    final replyController = Get.put(ReplyController());

    final currentUserId = commentController.getCurrentUserId();

    return Container(
      padding: EdgeInsets.only(
        left: FSizes.md,
        right: FSizes.md,
        top: FSizes.sm,
        bottom: MediaQuery.of(context).viewInsets.bottom + FSizes.sm, // 修复键盘遮挡
      ),
      decoration: BoxDecoration(
        color: dark ? FColors.communityDarkSurface : FColors.white,
        border: Border(
          top: BorderSide(
            color: dark ? FColors.communityDarkBorder : FColors.grey.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 防止溢出
        children: [
          // Edit mode indicator
          if (isEditMode) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: FSizes.md,
                vertical: FSizes.sm,
              ),
              decoration: BoxDecoration(
                color: FColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.edit_2,
                    size: 16,
                    color: FColors.primary,
                  ),
                  const SizedBox(width: FSizes.sm),
                  Expanded(
                    child: Text(
                      'Editing...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: FColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onCancel,
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: FColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: FSizes.sm),
          ],

          // Input row
          Row(
            children: [
              // User avatar
              FUserAvatar(userId: currentUserId, radius: 16),
              const SizedBox(width: FSizes.sm),

              // Input field
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  enabled: isEnabled,
                  maxLines: null,
                  minLines: 1,
                  style: TextStyle(
                    color: dark ? FColors.darkText : FColors.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: dark ? FColors.darkTextSecondary : FColors.textSecondary,
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: isSubmitting
                        ? (dark ? FColors.communityDarkBorder : FColors.grey.withOpacity(0.2))
                        : (dark ? FColors.communityDarkBackground : FColors.grey.withOpacity(0.1)),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: FSizes.md,
                      vertical: FSizes.sm,
                    ),
                    suffixIcon: isSubmitting
                        ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: FColors.primary,
                        ),
                      ),
                    )
                        : null,
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSubmit?.call(),
                ),
              ),
              const SizedBox(width: FSizes.sm),

              // Send button - 根据 isComment 参数选择正确的控制器来监听文本变化
              Obx(() {
                final isValid = isComment
                    ? commentController.commentText.value.trim().isNotEmpty
                    : replyController.isReplyValid.value;
                return _SendButton(
                  isValid: isValid,
                  isSubmitting: isSubmitting,
                  onTap: onSubmit,
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}


/// Send button widget
class _SendButton extends StatelessWidget {
  final bool isValid;
  final bool isSubmitting;
  final VoidCallback? onTap;

  const _SendButton({
    required this.isValid,
    required this.isSubmitting,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTap: isValid && !isSubmitting ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _getColor(dark),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          _getIcon(),
          color: FColors.white,
          size: 20,
        ),
      ),
    );
  }

  Color _getColor(bool dark) {
    if (isSubmitting) {
      return dark ? FColors.communityDarkBorder : FColors.grey.withOpacity(0.4);
    } else if (isValid) {
      return FColors.primary;
    } else {
      return dark ? FColors.communityDarkBorder : FColors.grey.withOpacity(0.3);
    }
  }

  IconData _getIcon() {
    return isSubmitting ? Icons.hourglass_empty : Iconsax.send_1;
  }
}