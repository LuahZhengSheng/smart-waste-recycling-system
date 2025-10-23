import 'package:flutter/material.dart';
import 'package:fyp/features/community/controllers/posts/post_controller.dart';
import 'package:fyp/features/community/controllers/posts/post_detail_controller.dart';
import 'package:fyp/features/community/models/post_model.dart';
import 'package:fyp/features/community/screens/view_post/post_detail.dart';
import 'package:fyp/features/community/screens/view_post/widgets/post_action.dart';
import 'package:fyp/features/community/screens/view_post/widgets/post_media.dart';
import 'package:fyp/features/community/screens/view_post/widgets/user_info.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/formatters/formatter.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class FPostCard extends StatelessWidget {
  final PostModel post;
  final bool isInDetailScreen;
  final VoidCallback? onMediaTap;

  const FPostCard({
    super.key,
    required this.post,
    this.isInDetailScreen = false,
    this.onMediaTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTap: isInDetailScreen ? null : () => _navigateToPostDetails(context, post.postId),
      child: Container(
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
          boxShadow: [
            BoxShadow(
              color: dark
                  ? Colors.black.withOpacity(0.1)
                  : FColors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info & Post Options
            _buildUserInfoSection(context, dark),
            const SizedBox(height: FSizes.spaceBtwSections),

            // Post Content
            Text(
              post.content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.4,
                color: dark ? FColors.white : FColors.black,
              ),
            ),

            // Post Media (if any)
            if (post.media.isNotEmpty) ...[
              const SizedBox(height: FSizes.spaceBtwItems),
              FPostMedia(
                mediaUrls: post.media,
              ),
            ],

            const SizedBox(height: FSizes.spaceBtwSections),

            // Action Buttons
            _buildPostActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoSection(BuildContext context, bool dark) {
    if (isInDetailScreen) {
      // 在详情页面，使用 PostDetailsController
      final controller = Get.find<PostDetailsController>();
      final isUserPost = post.userId == controller.getCurrentUserId();

      return Row(
        children: [
          Expanded(
            child: FUserInfo(
              userId: post.userId,
              timeAgo: FFormatter.formatTimeAgo(post.createdAt),
              postType: post.postType,
            ),
          ),
          if (isUserPost)
            IconButton(
              onPressed: () => _showPostOptions(context, post),
              icon: Icon(
                Iconsax.menu_14,
                color: dark ? FColors.darkGrey : FColors.grey,
              ),
              iconSize: FSizes.iconMd,
            ),
        ],
      );
    } else {
      // 在 Feed 页面，使用 PostsController
      final controller = Get.find<PostsController>();
      final isUserPost = controller.isUserPost(post);

      return Row(
        children: [
          Expanded(
            child: FUserInfo(
              userId: post.userId,
              timeAgo: FFormatter.formatTimeAgo(post.createdAt),
              postType: post.postType,
            ),
          ),
          if (isUserPost)
            IconButton(
              onPressed: () => _showPostOptions(context, post),
              icon: Icon(
                Iconsax.menu_14,
                color: dark ? FColors.darkGrey : FColors.grey,
              ),
              iconSize: FSizes.iconMd,
            ),
        ],
      );
    }
  }

  Widget _buildPostActions() {
    if (isInDetailScreen) {
      // 在详情页面，使用 PostDetailsController
      return GetBuilder<PostDetailsController>(
        builder: (controller) {
          final currentUserId = controller.getCurrentUserId();
          final isLiked = post.likes.contains(currentUserId);

          return FPostActions(
            post: post,
            isLiked: isLiked,
            onLikePressed: () => controller.togglePostLike(),
            onCommentPressed: () {}, // 已经在评论页面，不需要评论按钮功能
          );
        },
      );
    } else {
      // 在 Feed 页面，使用 PostsController
      return GetBuilder<PostsController>(
        builder: (controller) {
          final isLiked = post.likes.contains(controller.getCurrentUserId());

          return FPostActions(
            post: post,
            isLiked: isLiked,
            onLikePressed: () => controller.toggleLike(post.postId),
            onCommentPressed: () => controller.navigateToPostDetails(post.postId),
          );
        },
      );
    }
  }

  void _navigateToPostDetails(BuildContext context, String postId) {
    Get.to(() => PostDetailsScreen(postId: postId));
  }

  void _showPostOptions(BuildContext context, PostModel post) {
    final dark = FHelperFunctions.isDarkMode(context);

    if (isInDetailScreen) {
      // 在详情页面的选项菜单
      final controller = Get.find<PostsController>();

      showModalBottomSheet(
        context: context,
        backgroundColor: dark ? FColors.darkerGrey : FColors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(FSizes.borderRadiusLg)),
        ),
        builder: (context) => Container(
          padding: const EdgeInsets.all(FSizes.defaultSpace),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit option (only for post owner)
              if (controller.isUserPost(post))
                ListTile(
                  leading: Icon(
                    Iconsax.edit,
                    color: FColors.primary,
                  ),
                  title: Text(
                    'Edit Post',
                    style: TextStyle(
                      color: dark ? FColors.white : FColors.black,
                    ),
                  ),
                  onTap: () {
                    Get.back();
                    controller.navigateToEditPost(post);
                  },
                ),

              // Delete option (only for post owner)
              if (controller.isUserPost(post))
                ListTile(
                  leading: const Icon(
                    Iconsax.trash,
                    color: FColors.error,
                  ),
                  title: Text(
                    'Delete Post',
                    style: TextStyle(
                      color: FColors.error,
                    ),
                  ),
                  onTap: () {
                    Get.back();
                    _showDeleteConfirmation(context, post);
                  },
                ),
            ],
          ),
        ),
      );
    } else {
      // 在 Feed 页面的选项菜单
      final controller = Get.find<PostsController>();

      showModalBottomSheet(
        context: context,
        backgroundColor: dark ? FColors.darkerGrey : FColors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(FSizes.borderRadiusLg)),
        ),
        builder: (context) => Container(
          padding: const EdgeInsets.all(FSizes.defaultSpace),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit option (only for post owner)
              if (controller.isUserPost(post))
                ListTile(
                  leading: Icon(
                    Iconsax.edit,
                    color: FColors.primary,
                  ),
                  title: Text(
                    'Edit Post',
                    style: TextStyle(
                      color: dark ? FColors.white : FColors.black,
                    ),
                  ),
                  onTap: () {
                    Get.back();
                    controller.navigateToEditPost(post);
                  },
                ),

              // Delete option (only for post owner)
              if (controller.isUserPost(post))
                ListTile(
                  leading: const Icon(
                    Iconsax.trash,
                    color: FColors.error,
                  ),
                  title: Text(
                    'Delete Post',
                    style: TextStyle(
                      color: FColors.error,
                    ),
                  ),
                  onTap: () {
                    _showDeleteConfirmation(context, post);
                  },
                ),
            ],
          ),
        ),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context, PostModel post) {
    FDeleteConfirmation.show(
      context: context,
      title: 'Delete Post',
      message: 'Are you sure you want to delete this post? This action cannot be undone.',
      onConfirm: () {
        if (isInDetailScreen) {
          // 在详情页面删除：先关闭确认对话框，再删除帖子，最后关闭详情页面
          Get.back(); // 关闭确认对话框
          final controller = Get.find<PostsController>();
          controller.deletePost(post.postId);
          Get.back(); // 关闭loading
          Get.back(); // 关闭详情页面
        } else {
          // 在 Feed 页面删除：只关闭确认对话框并删除帖子
          Get.back(); // 关闭确认对话框
          final controller = Get.find<PostsController>();
          controller.deletePost(post.postId);
        }
      },
    );
  }
}

/// 静态删除确认对话框类
class FDeleteConfirmation {
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmText = 'Delete',
    String cancelText = 'Cancel',
  }) {
    final dark = FHelperFunctions.isDarkMode(context);

    Get.dialog(
      AlertDialog(
        backgroundColor: dark ? FColors.dark : FColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: dark ? FColors.white : FColors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            color: dark ? FColors.lightGrey : FColors.darkGrey,
            fontSize: 16,
            height: 1.4,
          ),
        ),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              foregroundColor: dark ? FColors.lightGrey : FColors.darkGrey,
              padding: const EdgeInsets.symmetric(horizontal: FSizes.lg, vertical: FSizes.sm),
            ),
            child: Text(
              cancelText,
              style: TextStyle(
                color: dark ? FColors.lightGrey : FColors.darkGrey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Delete button
          TextButton(
            onPressed: onConfirm,
            style: TextButton.styleFrom(
              backgroundColor: FColors.error.withOpacity(0.1),
              foregroundColor: FColors.error,
              padding: const EdgeInsets.symmetric(horizontal: FSizes.lg, vertical: FSizes.sm),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
              ),
            ),
            child: Text(
              confirmText,
              style: const TextStyle(
                color: FColors.error,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        actionsAlignment: MainAxisAlignment.spaceBetween,
        contentPadding: const EdgeInsets.fromLTRB(FSizes.defaultSpace, FSizes.sm, FSizes.defaultSpace, 0),
        titlePadding: const EdgeInsets.fromLTRB(FSizes.defaultSpace, FSizes.defaultSpace, FSizes.defaultSpace, 0),
      ),
      barrierDismissible: true,
    );
  }
}