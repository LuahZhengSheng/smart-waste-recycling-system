import 'package:flutter/material.dart';
import 'package:fyp/features/community/controllers/posts/post_detail_controller.dart';
import 'package:fyp/features/community/screens/comments/widgets/comment_header.dart';
import 'package:fyp/features/community/screens/comments/widgets/comment_list.dart';
import 'package:fyp/features/community/screens/comments/widgets/write_comment.dart';
import 'package:get/get.dart';
import 'package:fyp/utils/constants/sizes.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/helpers/helper_functions.dart';
import 'widgets/post_card.dart';

import 'package:fyp/features/community/controllers/posts/comment_controller.dart';

// Post Details Screen
class PostDetailsScreen extends StatelessWidget {
  final String postId;

  const PostDetailsScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    // 确保控制器在 PostDetailsScreen 中初始化
    final controller = Get.put(PostDetailsController());
    final commentController = Get.put(CommentController()); // 添加 CommentController

    final dark = FHelperFunctions.isDarkMode(context);

    // Load community details when screen is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadPostDetails(postId);
    });

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.white,
      appBar: FAppBar(
        showBackArrow: true,
        title: Text(
          "Details",
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Main content
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: FColors.primary,
                    ),
                  );
                }

                if (controller.post.value.postId.isEmpty) {
                  return Center(
                    child: Text(
                      'Post not found',
                      style: TextStyle(
                        color: dark ? FColors.white : FColors.black,
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Post content - 使用修改后的 FPostCard
                      FPostCard(
                        post: controller.post.value,
                        isInDetailScreen: true, // 标记在详情页面
                      ),

                      const SizedBox(height: FSizes.spaceBtwSections),

                      // Comments section
                      Container(
                        color: dark ? FColors.dark : FColors.white,
                        child: Column(
                          children: [
                            // Comments header with sorting
                            FCommentsHeader(),

                            // Comments list
                            Obx(() => FCommentsList(
                              postId: postId,
                              comments: controller.sortedComments,
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),

            // Write comment input at bottom
            FWriteCommentInput(postId: postId),
          ],
        ),
      ),
    );
  }
}

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 强制设置为黑色背景
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
                color: Colors.black, // 确保页面背景也是黑色
                child: Center(
                  child: InteractiveViewer(
                    child: Image.network(
                      widget.mediaUrls[index],
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.error,
                          color: Colors.white, // 错误图标改为白色
                          size: 64,
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),

          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5), // 使用黑色半透明
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white, // 关闭图标改为白色
                  size: 24,
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6), // 使用黑色半透明
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.mediaUrls.length}',
                    style: const TextStyle(
                      color: Colors.white, // 文字改为白色
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}