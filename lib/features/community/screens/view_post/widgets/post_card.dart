import 'package:flutter/material.dart';
import 'package:fyp/features/community/controllers/posts/post_controller.dart';
import 'package:fyp/features/community/controllers/posts/post_detail_controller.dart';
import 'package:fyp/features/community/models/post_model.dart';
import 'package:fyp/features/community/models/post_enums.dart';
import 'package:fyp/features/community/screens/view_post/widgets/post_action.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:video_player/video_player.dart';

import '../../../../../utils/formatters/formatter.dart';
import '../../common_post_widgets/common_post_widgets.dart';
import '../../create_post/widgets/media_lightbox.dart';

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
    final controller = Get.find<PostsController>();
    final dark = FHelperFunctions.isDarkMode(context);
    final postType = PostType.fromString(post.postType);
    final isDisabled = post.isDisabled;

    return GestureDetector(
      onTap: isInDetailScreen
          ? null
          : () => controller.navigateToPostDetails(post.postId),
      child: Stack(
        children: [
          Opacity(
            opacity: isDisabled ? 0.6 : 1.0,
            child: Container(
              padding: const EdgeInsets.all(FSizes.md),
              margin: const EdgeInsets.only(bottom: FSizes.spaceBtwItems),
              decoration: BoxDecoration(
                color: isInDetailScreen
                    ? dark
                    ? FColors.dark
                    : FColors.white
                    : dark
                    ? FColors.communityDarkSurface
                    : FColors.white,
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                border: isDisabled
                    ? Border.all(color: FColors.error.withOpacity(0.3), width: 1.5)
                    : null,
                boxShadow: dark
                    ? null
                    : [
                  BoxShadow(
                    color: FColors.grey.withOpacity(0.1),
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
                  _buildUserInfoSection(context, dark, postType),
                  const SizedBox(height: FSizes.spaceBtwItems * 2),

                  // Post Content
                  Text(
                    post.content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                      color: dark ? FColors.darkText : FColors.black,
                    ),
                  ),

                  // Post Media (if any)
                  if (post.media.isNotEmpty) ...[
                    const SizedBox(height: FSizes.spaceBtwItems * 2),
                    _PostMediaPreview(
                      mediaUrls: post.media,
                      onTap: (index) => _openMediaLightbox(context, index),
                    ),
                  ],

                  const SizedBox(height: FSizes.spaceBtwItems),

                  // Action Buttons - Disabled if post is disabled
                  if (isDisabled)
                    Opacity(
                      opacity: 0.5,
                      child: IgnorePointer(
                        child: Row(
                          children: [
                            const Spacer(),
                            _buildPostActions(),
                          ],
                        ),
                      ),
                    )
                  else
                    Row(
                      children: [
                        const Spacer(),
                        _buildPostActions(),
                      ],
                    ),
                ],
              ),
            ),
          ),
          // Violated badge for disabled posts
          if (isDisabled)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: FSizes.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: FColors.error.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: FColors.error.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Iconsax.warning_2,
                      color: FColors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'VIOLATED',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: FColors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openMediaLightbox(BuildContext context, int initialIndex) {
    final mediaItems = post.media.map((url) {
      return UnifiedMediaItem.network(
        id: url,
        networkUrl: url,
        isVideo: _isVideo(url),
      );
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UnifiedMediaLightbox(
          mediaItems: mediaItems,
          initialIndex: initialIndex,
          showDeleteButton: false,
        ),
      ),
    );
  }

  bool _isVideo(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('.mp4') ||
        lowerUrl.contains('.mov') ||
        lowerUrl.contains('.avi');
  }

  Widget _buildUserInfoSection(
      BuildContext context, bool dark, PostType postType) {
    if (isInDetailScreen) {
      final controller = Get.find<PostDetailsController>();
      final isUserPost = post.userId == controller.getCurrentUserId();

      return FUserInfo(
        userId: post.userId,
        timeAgo: FFormatter.formatTimeAgo(post.createdAt),
        postType: postType,
        showMenuButton: isUserPost,
        onMenuPressed: () => _showPostOptions(context, post),
      );
    } else {
      final controller = Get.find<PostsController>();
      final isUserPost = controller.isUserPost(post);

      return FUserInfo(
        userId: post.userId,
        timeAgo: FFormatter.formatTimeAgo(post.createdAt),
        postType: postType,
        showMenuButton: isUserPost,
        onMenuPressed: () => _showPostOptions(context, post),
      );
    }
  }

  Widget _buildPostActions() {
    if (isInDetailScreen) {
      return GetBuilder<PostDetailsController>(
        builder: (controller) {
          final currentUserId = controller.getCurrentUserId();
          final isLiked = post.likes.contains(currentUserId);

          return FPostActions(
            post: post,
            isLiked: isLiked,
            onLikePressed: () => controller.togglePostLike(),
            onCommentPressed: () {},
          );
        },
      );
    } else {
      return GetBuilder<PostsController>(
        builder: (controller) {
          final isLiked = post.likes.contains(controller.getCurrentUserId());

          return FPostActions(
            post: post,
            isLiked: isLiked,
            onLikePressed: () => controller.toggleLike(post.postId),
            onCommentPressed: () =>
                controller.navigateToPostDetails(post.postId),
          );
        },
      );
    }
  }

  void _showPostOptions(BuildContext context, PostModel post) {
    final controller = Get.find<PostsController>();
    final dark = FHelperFunctions.isDarkMode(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: dark ? FColors.communityDarkSurface : FColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(FSizes.borderRadiusLg)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(FSizes.defaultSpace),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
  }

  void _showDeleteConfirmation(BuildContext context, PostModel post) {
    final dark = FHelperFunctions.isDarkMode(context);

    Get.dialog(
      AlertDialog(
        backgroundColor: dark ? FColors.communityDarkSurface : FColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        ),
        title: Text(
          'Delete Post',
          style: TextStyle(
            color: dark ? FColors.white : FColors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
          style: TextStyle(
            color: dark ? FColors.darkTextSecondary : FColors.darkGrey,
            fontSize: 16,
            height: 1.4,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: FSizes.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: dark ? FColors.lightGrey : FColors.darkGrey,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _confirmDelete(post),
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      color: FColors.error,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  void _confirmDelete(PostModel post) async {
    Get.back();

    if (isInDetailScreen) {
      final controller = Get.find<PostsController>();
      await controller.deletePost(post.postId);
      Get.back();
    } else {
      final controller = Get.find<PostsController>();
      await controller.deletePost(post.postId);
    }
  }
}

/// 优化的媒体预览组件 - 使用统一的布局计算
class _PostMediaPreview extends StatelessWidget {
  final List<String> mediaUrls;
  final Function(int) onTap;

  const _PostMediaPreview({
    required this.mediaUrls,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (mediaUrls.isEmpty) return const SizedBox();

    final count = mediaUrls.length;
    final layout = _calculateMediaLayout(count);

    return _buildMediaGrid(layout);
  }

  /// 计算媒体布局
  _MediaLayout _calculateMediaLayout(int count) {
    switch (count) {
      case 1:
        return _MediaLayout(
          rows: [
            _MediaRow(items: [_MediaLayoutItem(index: 0, span: 2)]),
          ],
          itemHeight: null, // 使用 AspectRatio
        );
      case 2:
        return _MediaLayout(
          rows: [
            _MediaRow(items: [
              _MediaLayoutItem(index: 0, span: 1),
              _MediaLayoutItem(index: 1, span: 1),
            ]),
          ],
          itemHeight: 200,
        );
      case 3:
        return _MediaLayout(
          rows: [
            _MediaRow(items: [
              _MediaLayoutItem(index: 0, span: 1),
              _MediaLayoutItem(index: 1, span: 1),
            ]),
            _MediaRow(items: [
              _MediaLayoutItem(index: 2, span: 2),
            ]),
          ],
          itemHeight: 150,
        );
      case 4:
        return _MediaLayout(
          rows: [
            _MediaRow(items: [
              _MediaLayoutItem(index: 0, span: 1),
              _MediaLayoutItem(index: 1, span: 1),
            ]),
            _MediaRow(items: [
              _MediaLayoutItem(index: 2, span: 1),
              _MediaLayoutItem(index: 3, span: 1),
            ]),
          ],
          itemHeight: 150,
        );
      case 5:
        return _MediaLayout(
          rows: [
            _MediaRow(items: [
              _MediaLayoutItem(index: 0, span: 1),
              _MediaLayoutItem(index: 1, span: 1),
            ]),
            _MediaRow(items: [
              _MediaLayoutItem(index: 2, span: 1),
              _MediaLayoutItem(index: 3, span: 1),
              _MediaLayoutItem(index: 4, span: 1),
            ]),
          ],
          itemHeight: 150,
        );
      default: // 6+
        final remaining = count - 5;
        return _MediaLayout(
          rows: [
            _MediaRow(items: [
              _MediaLayoutItem(index: 0, span: 1),
              _MediaLayoutItem(index: 1, span: 1),
            ]),
            _MediaRow(items: [
              _MediaLayoutItem(index: 2, span: 1),
              _MediaLayoutItem(index: 3, span: 1),
              _MediaLayoutItem(index: 4, span: 1, overlayCount: remaining),
            ]),
          ],
          itemHeight: 150,
        );
    }
  }

  Widget _buildMediaGrid(_MediaLayout layout) {
    if (layout.itemHeight == null) {
      // 单张图片使用 AspectRatio
      return GestureDetector(
        onTap: () => onTap(0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: _MediaItem(
              mediaUrl: mediaUrls[0],
              showPlayIcon: _isVideo(mediaUrls[0]),
            ),
          ),
        ),
      );
    }

    return Column(
      children: layout.rows.map((row) => _buildMediaRow(row, layout.itemHeight!)).toList(),
    );
  }

  Widget _buildMediaRow(_MediaRow row, double itemHeight) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: SizedBox(
        height: itemHeight,
        child: Row(
          children: row.items.map((item) {
            return Expanded(
              flex: item.span,
              child: Padding(
                padding: EdgeInsets.only(
                  right: item == row.items.last ? 0 : 4,
                ),
                child: GestureDetector(
                  onTap: () => onTap(item.index),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                    child: item.overlayCount != null
                        ? _buildOverlayMedia(item)
                        : _MediaItem(
                      mediaUrl: mediaUrls[item.index],
                      showPlayIcon: _isVideo(mediaUrls[item.index]),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOverlayMedia(_MediaLayoutItem item) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _MediaItem(
          mediaUrl: mediaUrls[item.index],
          showPlayIcon: _isVideo(mediaUrls[item.index]),
        ),
        Container(
          color: Colors.black.withOpacity(0.6),
          child: Center(
            child: Text(
              '+${item.overlayCount}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _isVideo(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('.mp4') ||
        lowerUrl.contains('.mov') ||
        lowerUrl.contains('.avi');
  }
}

/// 媒体布局数据模型
class _MediaLayout {
  final List<_MediaRow> rows;
  final double? itemHeight;

  _MediaLayout({
    required this.rows,
    this.itemHeight,
  });
}

class _MediaRow {
  final List<_MediaLayoutItem> items;

  _MediaRow({required this.items});
}

class _MediaLayoutItem {
  final int index;
  final int span;
  final int? overlayCount;

  _MediaLayoutItem({
    required this.index,
    required this.span,
    this.overlayCount,
  });
}

/// 媒体项组件 - 支持视频缩略图
class _MediaItem extends StatelessWidget {
  final String mediaUrl;
  final bool showPlayIcon;

  const _MediaItem({
    required this.mediaUrl,
    this.showPlayIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    if (showPlayIcon) {
      // 如果是视频，使用 VideoThumbnail 组件
      return _VideoThumbnail(
        videoUrl: mediaUrl,
      );
    } else {
      // 如果是图片，正常显示
      return Image.network(
        mediaUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[300],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
                color: FColors.primary,
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.error, color: Colors.red),
          );
        },
      );
    }
  }
}

/// 视频缩略图组件
class _VideoThumbnail extends StatefulWidget {
  final String videoUrl;

  const _VideoThumbnail({
    required this.videoUrl,
  });

  @override
  State<_VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<_VideoThumbnail> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      await _controller.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Failed to initialize video thumbnail: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: Colors.grey[800],
        child: const Center(
          child: Icon(
            Iconsax.video_slash,
            color: Colors.white54,
            size: 32,
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: FColors.primary,
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // 视频第一帧作为缩略图
        VideoPlayer(_controller),
        // 半透明遮罩
        Container(
          color: Colors.black.withOpacity(0.3),
        ),
        // 播放按钮
        const Center(
          child: Icon(
            Iconsax.play_circle,
            color: Colors.white,
            size: 48,
          ),
        ),
      ],
    );
  }
}