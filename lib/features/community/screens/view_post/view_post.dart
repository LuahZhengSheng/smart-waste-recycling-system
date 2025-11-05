import 'package:flutter/material.dart';
import 'package:fyp/common/widgets/appbar/appbar.dart';
import 'package:fyp/features/community/controllers/posts/post_controller.dart';
import 'package:fyp/features/community/models/post_enums.dart';
import 'package:fyp/features/community/screens/create_post/create_post.dart';
import 'package:fyp/features/community/screens/my_post/my_post.dart';
import 'package:fyp/features/community/screens/view_post/widgets/post_list.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

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

                  // Time Filter Button
                  Obx(() {
                    final isFiltered = controller.selectedTimeFilter.value != TimeFilter.allTime;
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showTimeFilterBottomSheet(context, controller, dark),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isFiltered
                                ? FColors.primary.withOpacity(0.1)
                                : (dark ? FColors.communityDarkSurface : FColors.grey.withOpacity(0.1)),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isFiltered
                                  ? FColors.primary
                                  : (dark ? FColors.communityDarkBorder : FColors.grey.withOpacity(0.2)),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getTimeFilterIcon(controller.selectedTimeFilter.value),
                                color: isFiltered
                                    ? FColors.primary
                                    : (dark ? FColors.darkTextSecondary : FColors.textSecondary),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                controller.selectedTimeFilter.value.displayName,
                                style: TextStyle(
                                  color: isFiltered
                                      ? FColors.primary
                                      : (dark ? FColors.white : FColors.black),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Iconsax.arrow_down_1,
                                color: isFiltered
                                    ? FColors.primary
                                    : (dark ? FColors.darkTextSecondary : FColors.textSecondary),
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Divider
            Container(
              height: 8,
              color: dark ? FColors.black : FColors.grey.withOpacity(0.05),
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
      if (controller.isLoading.value) {
        return ListView(
          padding: const EdgeInsets.all(FSizes.defaultSpace),
          children: List.generate(3, (index) => const FPostSkeleton()),
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

  IconData _getTimeFilterIcon(TimeFilter filter) {
    switch (filter) {
      case TimeFilter.today:
        return Iconsax.sun_1;
      case TimeFilter.thisWeek:
        return Iconsax.calendar_1;
      case TimeFilter.thisMonth:
        return Iconsax.calendar;
      case TimeFilter.thisYear:
        return Iconsax.calendar_2;
      default:
        return Iconsax.clock;
    }
  }

  void _showTimeFilterBottomSheet(BuildContext context, PostsController controller, bool dark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: dark ? FColors.communityDarkSurface : FColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: dark ? FColors.darkGrey : FColors.grey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
                child: Row(
                  children: [
                    const Icon(
                      Iconsax.filter,
                      color: FColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Filter by Time',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: dark ? FColors.white : FColors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Filter Options
              Obx(() => Column(
                mainAxisSize: MainAxisSize.min,
                children: TimeFilter.values
                    .map((filter) => _buildTimeFilterOption(filter, controller, dark, context))
                    .toList(),
              )),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeFilterOption(TimeFilter filter, PostsController controller, bool dark, BuildContext context) {
    final isSelected = controller.selectedTimeFilter.value == filter;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          controller.setTimeFilter(filter);
          // 移除 Navigator.pop(context) 以实现实时更新
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: FSizes.defaultSpace,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: isSelected ? FColors.primary.withOpacity(0.1) : Colors.transparent,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? FColors.primary.withOpacity(0.2)
                      : (dark ? FColors.communityDarkBorder : FColors.grey.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getTimeFilterIcon(filter),
                  color: isSelected
                      ? FColors.primary
                      : (dark ? FColors.darkTextSecondary : FColors.textSecondary),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  filter.displayName,
                  style: TextStyle(
                    color: isSelected ? FColors.primary : (dark ? FColors.white : FColors.black),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Iconsax.tick_circle5,
                  color: FColors.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}