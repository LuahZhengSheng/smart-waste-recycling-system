import 'package:flutter/material.dart';
import 'package:fyp/common/widgets/appbar/appbar.dart';
import 'package:fyp/features/community/controllers/posts/post_controller.dart';
import 'package:fyp/features/community/screens/create_post/create_post.dart';
import 'package:fyp/features/community/screens/my_post/my_post.dart';
import 'package:fyp/features/community/screens/view_post/widgets/post_list.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/time_filter/time_filter.dart';
import '../common_post_widgets/common_post_widgets.dart';

class PostsScreen extends StatelessWidget {
  const PostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PostsController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.communityDarkBackground : FColors.light,
      appBar: FAppBar(
        title: const Text('Community'),
        centerTitle: false,
        showBackArrow: false,
        backgroundColor: dark ? FColors.communityDarkBackground : FColors.white,
        titleIcon: Iconsax.messages_2,
        actionButtonText: 'My Posts',
        actionButtonIcon: Iconsax.user,
        onActionButtonPressed: () => Get.to(() => const MyPostsScreen()),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Modern Tab Bar
            Container(
              color: dark ? FColors.communityDarkBackground : FColors.white,
              padding: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace, vertical: 12),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: dark ? FColors.communityDarkSurface : FColors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: controller.tabController,
                  labelColor: FColors.white,
                  unselectedLabelColor: dark ? FColors.darkTextSecondary : FColors.textSecondary,
                  indicator: BoxDecoration(
                    color: FColors.primary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: FColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Tips'),
                    Tab(text: 'Questions'),
                    Tab(text: 'Discussion'),
                  ],
                ),
              ),
            ),

            // Search Bar and Filter Button
            Container(
              padding: const EdgeInsets.fromLTRB(FSizes.defaultSpace, 8, FSizes.defaultSpace, 8),
              color: dark ? FColors.communityDarkBackground : FColors.white,
              child: Row(
                children: [
                  // Search Bar
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: dark ? FColors.communityDarkSurface : FColors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        onChanged: (value) => controller.setSearchQuery(value),
                        style: TextStyle(
                          color: dark ? FColors.darkText : FColors.black,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: "Search posts, topics...",
                          hintStyle: TextStyle(
                            color: dark ? FColors.darkTextSecondary : FColors.textSecondary,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Iconsax.search_normal_1,
                            color: dark ? FColors.darkTextSecondary : FColors.textSecondary,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: FSizes.md,
                            vertical: FSizes.md,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Time Filter Button - 使用通用组件
                  Obx(() => UniversalTimeFilter(
                    selectedFilter: controller.selectedTimeFilter.value,
                    onFilterChanged: controller.setTimeFilter,
                    darkMode: dark,
                    showCloseButton: true,
                  )),
                ],
              ),
            ),

            // Posts List
            Expanded(
              child: TabBarView(
                controller: controller.tabController,
                children: List.generate(4, (index) {
                  return _buildTabContent(controller, dark, context);
                }),
              ),
            ),
          ],
        ),
      ),

      // Modern Floating Action Button
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: FColors.primary.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => Get.to(() => const CreatePostScreen()),
          backgroundColor: FColors.primary,
          elevation: 0,
          icon: const Icon(Iconsax.edit_2, color: FColors.white, size: 20),
          label: const Text(
            'Create Post',
            style: TextStyle(
              color: FColors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(PostsController controller, bool dark, BuildContext context) {
    return Obx(() {
      // 添加统一的加载状态
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: FColors.primary),
        );
      }

      if (controller.filteredPosts.isEmpty) {
        return FEmptyState(
          icon: Iconsax.message_search,
          title: 'No posts found',
          subtitle: 'Try adjusting your filters or be the first to post!',
          actionText: 'Create Post',
          onActionPressed: () => Get.to(() => const CreatePostScreen()),
        );
      }

      return FPostsList(
        posts: controller.filteredPosts.toList(),
        onRefresh: () => controller.refreshPosts(),
      );
    });
  }
}