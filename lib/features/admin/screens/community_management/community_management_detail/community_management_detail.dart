import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/utils/formatters/formatter.dart';
import 'package:fyp/features/community/models/post_model.dart';
import 'package:fyp/features/admin/controllers/community_management/post_detail_controller.dart';
import 'package:fyp/features/admin/screens/community_management/widgets/post_type_badge.dart';
import 'package:fyp/features/admin/screens/community_management/widgets/admin_media_preview.dart';
import 'package:fyp/data/repositories/user/user_repository.dart';

import '../../../../../utils/popups/admin_loaders.dart';
import '../../../controllers/community_management/community_management_controller.dart';

class PostDetailScreen extends StatelessWidget {
  final PostModel post;

  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PostDetailController(post));
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor:
      dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
      appBar: AppBar(
        backgroundColor:
        dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Iconsax.arrow_left_2,
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        title: Text(
          'Post Details',
          style: TextStyle(
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          Obx(
                () => IconButton(
              onPressed: () =>
                  showActionDialog(controller.currentPost.value),
              icon: Icon(
                controller.currentPost.value.isDisabled
                    ? Iconsax.refresh
                    : Iconsax.close_circle,
                color: controller.currentPost.value.isDisabled
                    ? (dark
                    ? FColors.adminDarkSuccess
                    : FColors.adminLightSuccess)
                    : (dark ? FColors.adminDarkError : FColors.adminLightError),
              ),
              tooltip: controller.currentPost.value.isDisabled
                  ? 'Recover'
                  : 'Disable',
            ),
          ),
          const SizedBox(width: FSizes.sm),
        ],
      ),
      body: Obx(
            () => Column(
          children: [
            // 固定顶部的内容变化提示
            if (controller.hasContentChanged.value)
              Padding(
                padding: const EdgeInsets.all(FSizes.lg),
                child: buildContentChangedNotification(controller, dark),
              ),

            // 固定顶部的 comments 变化提示
            if (controller.hasCommentsChanged.value)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: FSizes.lg,
                ),
                child: buildCommentsChangedNotification(controller, dark),
              ),

            // 下面是可滚动区域
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(FSizes.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildPostCard(controller, dark),
                    const SizedBox(height: FSizes.spaceBtwSections),
                    buildCommentsSection(controller, dark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 通知区组件 ====================

Widget buildContentChangedNotification(
    PostDetailController controller, bool dark) {
  return Container(
    margin: const EdgeInsets.only(bottom: FSizes.spaceBtwItems),
    padding: const EdgeInsets.all(FSizes.md),
    decoration: BoxDecoration(
      color: dark
          ? FColors.adminDarkWarning.withOpacity(0.1)
          : FColors.adminLightWarning.withOpacity(0.1),
      borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
    ),
    child: Row(
      children: [
        Icon(
          Iconsax.info_circle,
          color: dark ? FColors.adminDarkWarning : FColors.adminLightWarning,
          size: 20,
        ),
        const SizedBox(width: FSizes.sm),
        Expanded(
          child: Text(
            'Post content has been updated',
            style: TextStyle(
              color: dark ? FColors.adminDarkWarning : FColors.adminLightWarning,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          onPressed: controller.dismissContentChangedNotification,
          icon: Icon(
            Iconsax.close_circle,
            color: dark ? FColors.adminDarkWarning : FColors.adminLightWarning,
            size: 20,
          ),
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
        ),
      ],
    ),
  );
}

Widget buildCommentsChangedNotification(
    PostDetailController controller, bool dark) {
  return Container(
    margin: const EdgeInsets.only(bottom: FSizes.spaceBtwItems),
    padding: const EdgeInsets.all(FSizes.md),
    decoration: BoxDecoration(
      color: dark
          ? FColors.adminDarkInfo.withOpacity(0.1)
          : FColors.adminLightInfo.withOpacity(0.1),
      borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
    ),
    child: Row(
      children: [
        Icon(
          Iconsax.message_notif,
          color: dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
          size: 20,
        ),
        const SizedBox(width: FSizes.sm),
        const Expanded(
          child: Text(
            'Comments have changed', // 简化文字
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          onPressed: () => controller.hasCommentsChanged.value = false,
          icon: Icon(
            Iconsax.close_circle,
            color: dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
            size: 20,
          ),
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
        ),
        const SizedBox(width: FSizes.sm),
        ElevatedButton.icon(
          onPressed: controller.refreshComments,
          icon: const Icon(Iconsax.refresh, size: 16),
          label: const Text('Refresh'),
          style: ElevatedButton.styleFrom(
            backgroundColor:
            dark ? FColors.adminDarkInfo : FColors.adminLightInfo,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: FSizes.md,
              vertical: FSizes.sm,
            ),
            minimumSize: Size.zero,
          ),
        ),
      ],
    ),
  );
}

// ==================== Post Card ====================

Widget buildPostCard(PostDetailController controller, bool dark) {
  final post = controller.currentPost.value;
  final poster = controller.usersCache[post.userId];

  return Container(
    decoration: BoxDecoration(
      color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
      borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with status badge
        Container(
          padding: const EdgeInsets.all(FSizes.lg),
          decoration: BoxDecoration(
            color: dark
                ? FColors.adminDarkPrimary.withOpacity(0.1)
                : FColors.adminLightPrimary.withOpacity(0.1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(FSizes.cardRadiusLg),
              topRight: Radius.circular(FSizes.cardRadiusLg),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PostTypeBadge(
                    postType: post.postType,
                    dark: dark,
                    showIcon: true,
                    fontSize: 13,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: FSizes.md,
                      vertical: FSizes.xs,
                    ),
                    decoration: BoxDecoration(
                      color: post.isDisabled
                          ? (dark
                          ? FColors.adminDarkError
                          : FColors.adminLightError)
                          : (dark
                          ? FColors.adminDarkSuccess
                          : FColors.adminLightSuccess),
                      borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          post.isDisabled ? Iconsax.pause : Iconsax.tick_circle,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: FSizes.xs),
                        Text(
                          post.isDisabled ? 'DISABLED' : 'ACTIVE',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: FSizes.md),
              buildInfoRow('Post ID', post.postId, Iconsax.document_text, dark),
            ],
          ),
        ),

        const Divider(height: 1),

        // Poster Info
        if (poster != null)
          Container(
            padding: const EdgeInsets.all(FSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Posted by',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: dark
                        ? FColors.adminDarkTextMuted
                        : FColors.adminLightTextMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: FSizes.sm),
                FutureBuilder<String?>(
                  future: poster.profileImg != null &&
                      poster.profileImg!.isNotEmpty
                      ? UserRepository.instance
                      .getProfileImageUrl(poster.profileImg!)
                      : Future.value(null),
                  builder: (context, snapshot) {
                    final imageUrl = snapshot.data;
                    return Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (imageUrl != null && imageUrl.isNotEmpty) {
                              Get.dialog(
                                AdminMediaLightbox(
                                  mediaUrls: [imageUrl],
                                  initialIndex: 0,
                                  dark: dark,
                                ),
                              );
                            }
                          },
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: dark
                                ? FColors.adminDarkPrimary
                                : FColors.adminLightPrimary,
                            backgroundImage: imageUrl != null &&
                                imageUrl.isNotEmpty
                                ? NetworkImage(imageUrl)
                                : null,
                            child: imageUrl == null || imageUrl.isEmpty
                                ? const Icon(
                              Iconsax.user,
                              color: Colors.white,
                              size: 28,
                            )
                                : null,
                          ),
                        ),
                        const SizedBox(width: FSizes.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                poster.username,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: dark
                                      ? FColors.adminDarkText
                                      : FColors.adminLightText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                poster.email,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: dark
                                      ? FColors.adminDarkTextSecondary
                                      : FColors.adminLightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

        const Divider(height: 1),

        // Dates
        Container(
          padding: const EdgeInsets.all(FSizes.lg),
          child: Row(
            children: [
              Expanded(
                child: buildDateCard(
                  'Created',
                  post.createdAt,
                  Iconsax.calendar_add,
                  dark,
                ),
              ),
              const SizedBox(width: FSizes.md),
              Expanded(
                child: buildDateCard(
                  'Updated',
                  post.updatedAt,
                  Iconsax.calendar_edit,
                  dark,
                  isEdited:
                  post.updatedAt.difference(post.createdAt).inSeconds > 60,
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Content
        Padding(
          padding: const EdgeInsets.all(FSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Content',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: dark ? FColors.adminDarkText : FColors.adminLightText,
                ),
              ),
              const SizedBox(height: FSizes.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(FSizes.md),
                decoration: BoxDecoration(
                  color: dark
                      ? FColors.adminDarkBackground.withOpacity(0.5)
                      : FColors.adminLightBackground,
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                ),
                child: SelectableText(
                  post.content,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: dark
                        ? FColors.adminDarkTextSecondary
                        : FColors.adminLightTextSecondary,
                  ),
                ),
              ),

              // Media
              if (post.media.isNotEmpty) ...[
                const SizedBox(height: FSizes.spaceBtwItems),
                Text(
                  'Media (${post.media.length})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color:
                    dark ? FColors.adminDarkText : FColors.adminLightText,
                  ),
                ),
                const SizedBox(height: FSizes.sm),
                buildMediaGrid(post.media, dark),
              ],
            ],
          ),
        ),

        const Divider(height: 1),

        // Statistics
        Container(
          padding: const EdgeInsets.all(FSizes.lg),
          decoration: BoxDecoration(
            color: dark
                ? FColors.adminDarkSurfaceVariant.withOpacity(0.5)
                : FColors.adminLightSurfaceVariant,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(FSizes.cardRadiusLg),
              bottomRight: Radius.circular(FSizes.cardRadiusLg),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: buildStatCard(
                  'Likes',
                  post.likes.length.toString(),
                  Iconsax.heart,
                  dark,
                ),
              ),
              const SizedBox(width: FSizes.md),
              Expanded(
                child: buildStatCard(
                  'Comments',
                  controller.displayCommentCount.value.toString(),
                  Iconsax.message,
                  dark,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ==================== Comments Section ====================

Widget buildCommentsSection(PostDetailController controller, bool dark) {
  return Container(
    decoration: BoxDecoration(
      color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
      borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),

      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(FSizes.lg),
          decoration: BoxDecoration(
            color: dark
                ? FColors.adminDarkPrimary.withOpacity(0.1)
                : FColors.adminLightPrimary.withOpacity(0.1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(FSizes.cardRadiusLg),
              topRight: Radius.circular(FSizes.cardRadiusLg),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Iconsax.message,
                color: dark ? FColors.adminDarkText : FColors.adminLightText,
                size: 22,
              ),
              const SizedBox(width: FSizes.sm),
              Text(
                'Comments (${controller.displayCommentCount.value})',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: dark ? FColors.adminDarkText : FColors.adminLightText,
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Comments List
        Obx(() {
          // 【新增】初始加载状态
          if (controller.isInitialLoading.value) {
            return buildLoadingState(dark);
          }

          if (controller.isLoadingComments.value &&
              controller.comments.isEmpty) {
            return buildLoadingState(dark);
          }

          if (controller.comments.isEmpty) {
            return buildEmptyCommentsState(dark);
          }

          return Column(
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: controller.comments.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: dark
                      ? FColors.adminDarkDivider
                      : FColors.adminLightDivider,
                ),
                itemBuilder: (context, index) {
                  final comment = controller.comments[index];
                  return buildCommentItem(comment, controller, dark);
                },
              ),

              // Load More Button
              if (controller.hasMoreComments.value)
                Container(
                  padding: const EdgeInsets.all(FSizes.lg),
                  child: Center(
                    child: controller.isLoadingComments.value
                        ? CircularProgressIndicator(
                      color: dark
                          ? FColors.adminDarkPrimary
                          : FColors.adminLightPrimary,
                    )
                        : OutlinedButton.icon(
                      onPressed: controller.loadMoreComments,
                      icon: const Icon(Iconsax.refresh),
                      label: const Text('Load More Comments'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: dark
                              ? FColors.adminDarkBorder
                              : FColors.adminLightBorder,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: FSizes.lg,
                          vertical: FSizes.md,
                        ),
                      ),
                    ),
                  ),
                )
              else if (controller.comments.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(FSizes.lg),
                  child: Center(
                    child: Text(
                      'No more comments',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: dark
                            ? FColors.adminDarkTextMuted
                            : FColors.adminLightTextMuted,
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
      ],
    ),
  );
}

// ==================== Helper Widgets ====================

Widget buildInfoRow(String label, String value, IconData icon, bool dark) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(
            icon,
            size: 16,
            color:
            dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
          ),
          const SizedBox(width: FSizes.xs),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: dark
                  ? FColors.adminDarkTextMuted
                  : FColors.adminLightTextMuted,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      const SizedBox(height: FSizes.xs),
      SelectableText(
        value,
        style: TextStyle(
          fontSize: 14,
          color: dark ? FColors.adminDarkText : FColors.adminLightText,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}

Widget buildDateCard(
    String label,
    DateTime date,
    IconData icon,
    bool dark, {
      bool isEdited = true,
    }) {
  if (!isEdited && label == 'Updated') {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark
            ? FColors.adminDarkSurfaceVariant.withOpacity(0.3)
            : FColors.adminLightSurfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
      ),
      child: Center(
        child: Text(
          'Not Edited',
          style: TextStyle(
            fontSize: 13,
            fontStyle: FontStyle.italic,
            color:
            dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
          ),
        ),
      ),
    );
  }

  return Container(
    padding: const EdgeInsets.all(FSizes.md),
    decoration: BoxDecoration(
      color: dark
          ? FColors.adminDarkSurfaceVariant
          : FColors.adminLightSurfaceVariant,
      borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
            ),
            const SizedBox(width: FSizes.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: dark
                    ? FColors.adminDarkTextMuted
                    : FColors.adminLightTextMuted,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: FSizes.xs),
        Text(
          formatDateTime(date),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        Text(
          FFormatter.formatTimeAgo(date),
          style: TextStyle(
            fontSize: 11,
            color:
            dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
          ),
        ),
      ],
    ),
  );
}

Widget buildStatCard(String label, String value, IconData icon, bool dark) {
  return Container(
    padding: const EdgeInsets.all(FSizes.md),
    decoration: BoxDecoration(
      color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
      borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(FSizes.sm),
          decoration: BoxDecoration(
            color: dark
                ? FColors.adminDarkPrimary.withOpacity(0.1)
                : FColors.adminLightPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
          ),
          child: Icon(
            icon,
            size: 20,
            color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
          ),
        ),
        const SizedBox(width: FSizes.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: dark ? FColors.adminDarkText : FColors.adminLightText,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: dark
                    ? FColors.adminDarkTextMuted
                    : FColors.adminLightTextMuted,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget buildMediaGrid(List<String> media, bool dark) {
  print('========== buildMediaGrid DEBUG START ==========');
  print('Total media count: ${media.length}');
  print('Is empty: ${media.isEmpty}');

  if (media.isEmpty) {
    print('Media is empty, showing "No media" message');
    print('========== buildMediaGrid DEBUG END ==========');
    return Container(
      padding: const EdgeInsets.all(FSizes.xl),
      child: Center(
        child: Text(
          'No media',
          style: TextStyle(
            color: dark
                ? FColors.adminDarkTextMuted
                : FColors.adminLightTextMuted,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  print('Media URLs:');
  for (int i = 0; i < media.length; i++) {
    print('  [$i]: ${media[i]}');
    print('       Is Image: ${isImageUrl(media[i])}');
  }

  print('Building Wrap widget with ${media.length} children');
  print('========== buildMediaGrid DEBUG END ==========');

  return Container(
    decoration: BoxDecoration(
      color: dark
          ? FColors.adminDarkBackground.withOpacity(0.5)
          : FColors.adminLightBackground,
      borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
    ),
    padding: const EdgeInsets.all(FSizes.md),
    child: Wrap(
      spacing: FSizes.sm,
      runSpacing: FSizes.sm,
      children: List.generate(
        media.length,
            (index) {
          print('Generating thumbnail $index for: ${media[index]}');
          return buildMediaThumbnail(media[index], index, media, dark);
        },
      ),
    ),
  );
}

Widget buildMediaThumbnail(String mediaUrl, int index, List<String> allMedia, bool dark) {
  print('buildMediaThumbnail called:');
  print('  Index: $index');
  print('  URL: $mediaUrl');
  print('  Is Image: ${isImageUrl(mediaUrl)}');

  final bool isImage = isImageUrl(mediaUrl);

  return GestureDetector(
    onTap: () {
      print('Thumbnail $index tapped, opening lightbox');
      showMediaDialog(allMedia, index, dark);
    },
    child: Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: dark
            ? FColors.adminDarkSurfaceVariant
            : FColors.adminLightSurfaceVariant,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusSm),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusSm - 1),
        child: isImage
            ? Image.network(
          mediaUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              print('Image $index loaded successfully');
              return child;
            }
            final progress = loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
                : null;
            print('Image $index loading: ${progress != null ? (progress * 100).toStringAsFixed(1) : "..."}%');
            return Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: dark
                      ? FColors.adminDarkPrimary
                      : FColors.adminLightPrimary,
                  value: progress,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('ERROR loading image $index: $error');
            return Icon(
              Iconsax.image,
              color: dark
                  ? FColors.adminDarkTextMuted
                  : FColors.adminLightTextMuted,
              size: 24,
            );
          },
        )
            : Container(
          // 视频缩略图：深色背景 + 播放图标
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                (dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary).withOpacity(0.2),
                (dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary).withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Icon(
              Iconsax.video_play,
              color: dark
                  ? FColors.adminDarkPrimary
                  : FColors.adminLightPrimary,
              size: 28,
            ),
          ),
        ),
      ),
    ),
  );
}

bool isImageUrl(String url) {
  try {
    // 解析 URL 并获取路径部分（不包含查询参数）
    final uri = Uri.parse(url);
    final path = uri.path.toLowerCase();

    print('isImageUrl check:');
    print('  Full URL: $url');
    print('  Path only: $path');

    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
    final result = imageExtensions.any((ext) => path.endsWith(ext));

    print('  Result: $result');

    return result;
  } catch (e) {
    print('Error parsing URL in isImageUrl: $e');
    // 如果解析失败，回退到简单的字符串检查
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
    return imageExtensions.any((ext) => url.toLowerCase().contains(ext));
  }
}

Widget buildLoadingState(bool dark) {
  return Container(
    padding: const EdgeInsets.all(FSizes.xl * 2),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
          ),
          const SizedBox(height: FSizes.md),
          Text(
            'Loading comments...',
            style: TextStyle(
              fontSize: 14,
              color: dark
                  ? FColors.adminDarkTextSecondary
                  : FColors.adminLightTextSecondary,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildEmptyCommentsState(bool dark) {
  return Container(
    padding: const EdgeInsets.all(FSizes.xl * 2),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.message_question,
            size: 64,
            color:
            dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
          ),
          const SizedBox(height: FSizes.md),
          Text(
            'No comments yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: dark ? FColors.adminDarkText : FColors.adminLightText,
            ),
          ),
          const SizedBox(height: FSizes.sm),
          Text(
            'Be the first to comment on this post',
            style: TextStyle(
              fontSize: 14,
              color: dark
                  ? FColors.adminDarkTextMuted
                  : FColors.adminLightTextMuted,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildCommentItem(
    dynamic comment, PostDetailController controller, bool dark) {
  final commenter = controller.usersCache[comment.userId];

  return Obx(() {
    final isExpanded = controller.expandedComments[comment.commentId] ?? false;

    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Commenter Info
          if (commenter != null)
            FutureBuilder<String?>(
              future: commenter.profileImg != null &&
                  commenter.profileImg!.isNotEmpty
                  ? UserRepository.instance
                  .getProfileImageUrl(commenter.profileImg!)
                  : Future.value(null),
              builder: (context, snapshot) {
                final imageUrl = snapshot.data;
                return Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (imageUrl != null && imageUrl.isNotEmpty) {
                          Get.dialog(
                            AdminMediaLightbox(
                              mediaUrls: [imageUrl],
                              initialIndex: 0,
                              dark: dark,
                            ),
                          );
                        }
                      },
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: dark
                            ? FColors.adminDarkPrimary
                            : FColors.adminLightPrimary,
                        backgroundImage:
                        imageUrl != null && imageUrl.isNotEmpty
                            ? NetworkImage(imageUrl)
                            : null,
                        child: imageUrl == null || imageUrl.isEmpty
                            ? const Icon(
                          Iconsax.user,
                          color: Colors.white,
                          size: 20,
                        )
                            : null,
                      ),
                    ),
                    const SizedBox(width: FSizes.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            commenter.username,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: dark
                                  ? FColors.adminDarkText
                                  : FColors.adminLightText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

          const SizedBox(height: FSizes.sm),

          // Comment Content
          Container(
            padding: const EdgeInsets.all(FSizes.md),
            decoration: BoxDecoration(
              color: dark
                  ? FColors.adminDarkBackground.withOpacity(0.5)
                  : FColors.adminLightBackground,
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
            ),
            child: Text(
              comment.content,
              style: TextStyle(
                fontSize: 13,
                color: dark
                    ? FColors.adminDarkTextSecondary
                    : FColors.adminLightTextSecondary,
              ),
            ),
          ),

          const SizedBox(height: FSizes.sm),

          // Comment Stats & Actions
          Row(
            children: [
              Icon(
                Iconsax.heart,
                size: 14,
                color: dark
                    ? FColors.adminDarkTextMuted
                    : FColors.adminLightTextMuted,
              ),
              const SizedBox(width: 4),
              Text(
                '${comment.likes.length}',
                style: TextStyle(
                  fontSize: 12,
                  color: dark
                      ? FColors.adminDarkTextMuted
                      : FColors.adminLightTextMuted,
                ),
              ),
              const SizedBox(width: FSizes.md),
              Icon(
                Iconsax.message_2,
                size: 14,
                color: dark
                    ? FColors.adminDarkTextMuted
                    : FColors.adminLightTextMuted,
              ),
              const SizedBox(width: 4),
              Text(
                '${comment.replyCount}',
                style: TextStyle(
                  fontSize: 12,
                  color: dark
                      ? FColors.adminDarkTextMuted
                      : FColors.adminLightTextMuted,
                ),
              ),
              const Spacer(),
              Text(
                FFormatter.formatTimeAgo(comment.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: dark
                      ? FColors.adminDarkTextMuted
                      : FColors.adminLightTextMuted,
                ),
              ),
              if (comment.replyCount > 0) ...[
                const SizedBox(width: FSizes.sm),
                TextButton.icon(
                  onPressed: () =>
                      controller.toggleCommentExpansion(comment.commentId),
                  icon: Icon(
                    isExpanded ? Iconsax.arrow_up_2 : Iconsax.arrow_down_1,
                    size: 16,
                  ),
                  label: Text(isExpanded ? 'Hide Replies' : 'View Replies'),
                  style: TextButton.styleFrom(
                    padding:
                    const EdgeInsets.symmetric(horizontal: FSizes.sm),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ],
          ),

          // Replies Section
          if (isExpanded) ...[
            const SizedBox(height: FSizes.md),
            Obx(() {
              final replies =
                  controller.commentReplies[comment.commentId] ?? [];
              final isLoadingReplies =
                  controller.loadingReplies[comment.commentId] ?? false;
              final hasMoreReplies =
                  controller.hasMoreRepliesMap[comment.commentId] ?? false;

              if (isLoadingReplies && replies.isEmpty) {
                return buildRepliesLoadingState(dark);
              }

              if (replies.isEmpty) {
                return buildNoRepliesState(dark);
              }

              return Column(
                children: [
                  ...replies.map((reply) =>
                      buildReplyItem(reply, controller, dark)),

                  // Load More Replies Button
                  if (hasMoreReplies)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: FSizes.xl,
                        top: FSizes.sm,
                      ),
                      child: isLoadingReplies
                          ? Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: dark
                                ? FColors.adminDarkPrimary
                                : FColors.adminLightPrimary,
                          ),
                        ),
                      )
                          : TextButton.icon(
                        onPressed: () =>
                            controller.loadMoreReplies(comment.commentId),
                        icon: const Icon(Iconsax.refresh, size: 14),
                        label: const Text('Load More Replies'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: FSizes.sm),
                          minimumSize: Size.zero,
                        ),
                      ),
                    )
                  else if (replies.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: FSizes.xl,
                        top: FSizes.sm,
                      ),
                      child: Center(
                        child: Text(
                          'No more replies',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: dark
                                ? FColors.adminDarkTextMuted
                                : FColors.adminLightTextMuted,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }),
          ],
        ],
      ),
    );
  });
}

Widget buildRepliesLoadingState(bool dark) {
  return Container(
    margin: const EdgeInsets.only(left: FSizes.xl, top: FSizes.sm),
    padding: const EdgeInsets.all(FSizes.md),
    child: Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
        ),
      ),
    ),
  );
}

Widget buildNoRepliesState(bool dark) {
  return Container(
    margin: const EdgeInsets.only(left: FSizes.xl, top: FSizes.sm),
    padding: const EdgeInsets.all(FSizes.md),
    child: Center(
      child: Text(
        'No replies yet',
        style: TextStyle(
          fontSize: 12,
          fontStyle: FontStyle.italic,
          color: dark
              ? FColors.adminDarkTextMuted
              : FColors.adminLightTextMuted,
        ),
      ),
    ),
  );
}

Widget buildReplyItem(
    dynamic reply, PostDetailController controller, bool dark) {
  final replier = controller.usersCache[reply.userId];

  return FutureBuilder<String?>(
    future: replier?.profileImg != null && replier!.profileImg!.isNotEmpty
        ? UserRepository.instance.getProfileImageUrl(replier.profileImg!)
        : Future.value(null),
    builder: (context, snapshot) {
      final imageUrl = snapshot.data;

      return Container(
        margin: const EdgeInsets.only(left: FSizes.xl, top: FSizes.sm),
        padding: const EdgeInsets.all(FSizes.md),
        decoration: BoxDecoration(
          color: dark
              ? FColors.adminDarkSurfaceVariant.withOpacity(0.5)
              : FColors.adminLightSurfaceVariant,
          borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Replier Info
            if (replier != null)
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (imageUrl != null && imageUrl.isNotEmpty) {
                        Get.dialog(
                          AdminMediaLightbox(
                            mediaUrls: [imageUrl],
                            initialIndex: 0,
                            dark: dark,
                          ),
                        );
                      }
                    },
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: dark
                          ? FColors.adminDarkPrimary
                          : FColors.adminLightPrimary,
                      backgroundImage:
                      imageUrl != null && imageUrl.isNotEmpty
                          ? NetworkImage(imageUrl)
                          : null,
                      child: imageUrl == null || imageUrl.isEmpty
                          ? const Icon(
                        Iconsax.user,
                        color: Colors.white,
                        size: 16,
                      )
                          : null,
                    ),
                  ),
                  const SizedBox(width: FSizes.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          replier.username,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: dark
                                ? FColors.adminDarkText
                                : FColors.adminLightText,
                          ),
                        ),
                        Text(
                          FFormatter.formatTimeAgo(reply.createdAt),
                          style: TextStyle(
                            fontSize: 10,
                            color: dark
                                ? FColors.adminDarkTextMuted
                                : FColors.adminLightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

            const SizedBox(height: FSizes.sm),

            // Reply Content
            Text(
              reply.content,
              style: TextStyle(
                fontSize: 12,
                color: dark
                    ? FColors.adminDarkTextSecondary
                    : FColors.adminLightTextSecondary,
              ),
            ),

            const SizedBox(height: FSizes.sm),

            // Reply Stats
            Row(
              children: [
                Icon(
                  Iconsax.heart,
                  size: 12,
                  color: dark
                      ? FColors.adminDarkTextMuted
                      : FColors.adminLightTextMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  '${reply.likes.length}',
                  style: TextStyle(
                    fontSize: 11,
                    color: dark
                        ? FColors.adminDarkTextMuted
                        : FColors.adminLightTextMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

// ==================== Utility Functions ====================

void showMediaDialog(List<String> media, int initialIndex, bool dark) {
  showDialog(
    context: Get.context!,
    barrierColor: Colors.black.withOpacity(0.9),
    builder: (context) => AdminMediaLightbox(
      mediaUrls: media,
      initialIndex: initialIndex,
      dark: dark,
    ),
  );
}

void showActionDialog(PostModel post) {
  final controller = CommunityManagementController.instance;

  FAdminLoaders.showPostDisableRecoverDialog(
    postContent: post.content.length > 50 ? '${post.content.substring(0, 50)}...' : post.content,
    isDisabled: post.isDisabled,
    onConfirm: () => controller.togglePostStatus(post),
  );
}

String formatDateTime(DateTime dateTime) {
  return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}
