import 'package:flutter/material.dart';
import 'package:fyp/common/widgets/appbar/appbar.dart';
import 'package:fyp/features/community/controllers/posts/comment_controller.dart';
import 'package:fyp/features/community/controllers/posts/post_detail_controller.dart';
import 'package:fyp/features/community/screens/comments/widgets/comment_header.dart';
import 'package:fyp/features/community/screens/comments/widgets/comment_list.dart';
import 'package:fyp/features/community/screens/comments/widgets/write_comment.dart';
import 'package:fyp/features/community/screens/view_post/widgets/post_card.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../common_post_widgets/common_post_widgets.dart';

class PostDetailsScreen extends StatelessWidget {
  final String postId;

  const PostDetailsScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PostDetailsController());
    final commentController = Get.put(CommentController());
    final dark = FHelperFunctions.isDarkMode(context);

    // 设置当前 postId 到 CommentController
    commentController.setPostId(postId);

    // Load post details when screen is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadPostDetails(postId);
    });

    return Scaffold(
      backgroundColor: dark ? FColors.communityDarkBackground : FColors.white,
      appBar: FAppBar(
        showBackArrow: true,
        title: const Text('Details'),
      ),
      body: SafeArea(
        child: Obx(() {
          final isPostDisabled = controller.post.value.isDisabled;

          // 添加统一的加载状态
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: FColors.primary),
            );
          }

          return Column(
            children: [
              // Main scrollable content
              Expanded(
                child: Obx(() {
                  if (controller.post.value.postId.isEmpty) {
                    return _buildNotFoundState(context, dark);
                  }

                  return ListView(
                    children: [
                      // Post content
                      FPostCard(
                        post: controller.post.value,
                        isInDetailScreen: true,
                      ),

                      const SizedBox(height: FSizes.spaceBtwSections),

                      // Comments section
                      Container(
                        color: dark ? FColors.communityDarkBackground : FColors.white,
                        child: Column(
                          children: [
                            // Comments header with sorting
                            const FCommentsHeader(),

                            // Comments list
                            Obx(() {
                              // 当评论列表更新时，加载用户数据
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (controller.sortedComments.isNotEmpty) {
                                  commentController.loadUserDataForComments(controller.sortedComments);
                                }
                              });

                              return FCommentsList(
                                postId: postId,
                                comments: controller.sortedComments,
                                isPostDisabled: isPostDisabled,
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),

              // Write comment input at bottom - Disabled if post is disabled
              if (isPostDisabled)
                _buildDisabledOverlay(context, dark)
              else
                FWriteCommentInput(postId: postId),
            ],
          );
        }),
      ),
    );
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
                  'Comments Disabled',
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

  Widget _buildNotFoundState(BuildContext context, bool dark) {
    return FEmptyState(
      icon: Iconsax.document_text,
      title: 'Post not found',
      subtitle: 'This post may have been deleted or is no longer available',
      actionText: 'Go Back',
      onActionPressed: () => Get.back(),
    );
  }
}

// Media Viewer Widget - Updated with dark mode
class FMediaViewer extends StatefulWidget {
  final List<String> mediaUrls;
  final int initialIndex;

  const FMediaViewer({
    super.key,
    required this.mediaUrls,
    required this.initialIndex,
  });

  @override
  State<FMediaViewer> createState() => _FMediaViewerState();
}

class _FMediaViewerState extends State<FMediaViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Media viewer
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.mediaUrls.length,
            itemBuilder: (context, index) {
              return Container(
                color: Colors.black,
                child: Center(
                  child: InteractiveViewer(
                    child: Image.network(
                      widget.mediaUrls[index],
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                            color: FColors.primary,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.white,
                              size: 64,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Failed to load image',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),

          // Top gradient overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),

          // Bottom gradient overlay (for multiple images)
          if (widget.mediaUrls.length > 1)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

          // Page indicator (if multiple images)
          if (widget.mediaUrls.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 32,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.mediaUrls.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

          // Dot indicators (alternative to text)
          if (widget.mediaUrls.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 70,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.mediaUrls.length,
                      (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index
                          ? FColors.primary
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

