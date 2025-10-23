import 'package:flutter/material.dart';
import 'package:fyp/features/community/models/post_model.dart';
import 'package:fyp/features/community/screens/view_post/post_detail.dart';
import 'package:fyp/features/community/screens/view_post/view_post.dart';
import 'package:fyp/features/community/screens/view_post/widgets/post_action.dart';
import 'package:fyp/features/community/screens/view_post/widgets/post_media.dart';
import 'package:fyp/features/community/screens/view_post/widgets/user_info.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../controllers/posts/my_post_controller.dart';

class FMyPostCard extends StatelessWidget {
  final PostModel post;

  const FMyPostCard({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyPostsController>();
    final currentUserId = controller.getCurrentUserId();
    final dark = FHelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTap: post.isDisabled
          ? null
          : () {
        Get.to(() => PostDetailsScreen(postId: post.postId));
      },
      child: Container(
        padding: const EdgeInsets.all(FSizes.md),
        margin: const EdgeInsets.only(bottom: FSizes.spaceBtwItems),
        decoration: BoxDecoration(
          color: post.isDisabled
              ? (dark ? FColors.darkerGrey.withOpacity(0.5) : FColors.grey.withOpacity(0.15))
              : (dark ? FColors.darkerGrey : FColors.white),
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
          border: Border.all(
            color: post.isDisabled
                ? (dark ? FColors.error.withOpacity(0.3) : FColors.error.withOpacity(0.25))
                : (dark ? FColors.darkGrey.withOpacity(0.3) : FColors.grey.withOpacity(0.2)),
            width: post.isDisabled ? 1.5 : 1,
          ),
          boxShadow: post.isDisabled
              ? null
              : [
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
            // User Info & Status Badge
            Row(
              children: [
                Expanded(
                  child: Opacity(
                    opacity: post.isDisabled ? 0.6 : 1.0,
                    child: FUserInfo(
                      userId: post.userId,
                      timeAgo: _formatTimeAgo(post.createdAt),
                      postType: post.postType,
                    ),
                  ),
                ),
                // Violated Badge with modern design
                if (post.isDisabled)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          FColors.error,
                          FColors.error.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: FColors.error.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Iconsax.warning_25,
                          color: FColors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'VIOLATED',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: FColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Options Menu (only for active posts)
                if (!post.isDisabled)
                  Container(
                    decoration: BoxDecoration(
                      color: dark ? FColors.darkGrey.withOpacity(0.2) : FColors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      onPressed: () => _showPostOptions(context, post, dark),
                      icon: Icon(
                        Iconsax.more,
                        color: dark ? FColors.darkGrey : FColors.grey,
                      ),
                      iconSize: FSizes.iconMd,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: FSizes.spaceBtwItems),

            // Post Content
            Opacity(
              opacity: post.isDisabled ? 0.6 : 1.0,
              child: Text(
                post.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.4,
                  color: dark ? FColors.white : FColors.black,
                ),
              ),
            ),

            // Post Media (if any)
            if (post.media.isNotEmpty) ...[
              const SizedBox(height: FSizes.spaceBtwItems),
              Opacity(
                opacity: post.isDisabled ? 0.6 : 1.0,
                child: FPostMedia(mediaUrls: post.media),
              ),
            ],

            const SizedBox(height: FSizes.spaceBtwItems),

            // Violated Notice or Action Buttons
            if (post.isDisabled)
              Container(
                padding: const EdgeInsets.all(FSizes.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      FColors.error.withOpacity(0.08),
                      FColors.error.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: FColors.error.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: FColors.error.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Iconsax.info_circle5,
                        size: 20,
                        color: FColors.error,
                      ),
                    ),
                    const SizedBox(width: FSizes.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Community Guidelines Violation',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: FColors.error,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'This post has been disabled for violating our community standards',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: dark ? FColors.darkGrey : FColors.textSecondary,
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Obx(() {
                final currentPost = controller.myPosts.firstWhere(
                      (p) => p.postId == post.postId,
                  orElse: () => post,
                );
                final isLiked = currentPost.likes.contains(currentUserId);

                return FPostActions(
                  post: currentPost,
                  isLiked: isLiked,
                  onLikePressed: () => controller.toggleLike(post.postId),
                  onCommentPressed: () =>
                      Get.to(() => PostDetailsScreen(postId: post.postId)),
                );
              }),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
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

  void _showPostOptions(BuildContext context, PostModel post, bool dark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: dark ? FColors.darkerGrey : FColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: dark ? FColors.darkGrey : FColors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Edit Option
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Get.back();
                  Get.to(() => EditPostScreen(post: post));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FSizes.defaultSpace,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: FColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Iconsax.edit,
                          color: FColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Edit Post',
                          style: TextStyle(
                            color: dark ? FColors.white : FColors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Iconsax.arrow_right_3,
                        color: dark ? FColors.darkGrey : FColors.grey,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Delete Option
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Get.back();
                  _showDeleteConfirmation(context, post, dark);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FSizes.defaultSpace,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: FColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Iconsax.trash,
                          color: FColors.error,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Delete Post',
                          style: TextStyle(
                            color: FColors.error,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Iconsax.arrow_right_3,
                        color: FColors.error.withOpacity(0.5),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, PostModel post, bool dark) {
    Get.dialog(
      AlertDialog(
        backgroundColor: dark ? FColors.darkerGrey : FColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: FColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Iconsax.trash,
                color: FColors.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Delete Post',
              style: TextStyle(
                color: dark ? FColors.white : FColors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
          style: TextStyle(
            color: dark ? FColors.darkGrey : FColors.grey,
            fontSize: 15,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              foregroundColor: dark ? FColors.darkGrey : FColors.grey,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: dark ? FColors.darkGrey : FColors.grey,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  FColors.error,
                  FColors.error.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: FColors.error.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextButton(
              onPressed: () {
                Get.back();
                Get.find<MyPostsController>().deletePost(post.postId);
              },
              style: TextButton.styleFrom(
                foregroundColor: FColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: FColors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
        actionsAlignment: MainAxisAlignment.spaceBetween,
        contentPadding: const EdgeInsets.fromLTRB(FSizes.defaultSpace, FSizes.sm, FSizes.defaultSpace, FSizes.defaultSpace),
        titlePadding: const EdgeInsets.all(FSizes.defaultSpace),
      ),
      barrierDismissible: true,
    );
  }
}