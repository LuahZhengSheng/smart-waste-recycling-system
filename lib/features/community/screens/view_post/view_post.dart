import 'package:flutter/material.dart';
import 'package:fyp/common/widgets/appbar/appbar.dart';
import 'package:fyp/features/community/controllers/posts/post_controller.dart';
import 'package:fyp/features/community/models/post_model.dart';
import 'package:fyp/features/community/screens/view_post/widgets/post_list.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../create_post/create_post.dart';
import '../my_post/my_post.dart';

class PostsScreen extends StatelessWidget {
  const PostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PostsController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: FAppBar(
        title: Text('Community'),
        centerTitle: false,
        showBackArrow: false,
        titleIcon: Iconsax.messages_2,
        actionButtonText: 'My Posts',
        actionButtonIcon: Iconsax.user,
        onActionButtonPressed: () => Get.to(() => const MyPostsScreen()),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Modern Tab Bar with Pills Design
            Container(
              color: dark ? FColors.dark : FColors.white,
              padding: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace, vertical: 12),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: dark ? FColors.darkerGrey : FColors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: controller.tabController,
                  labelColor: FColors.white,
                  unselectedLabelColor: dark ? FColors.darkGrey : FColors.textSecondary,
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

            // Search Bar and Filter Button Row
            Container(
              padding: const EdgeInsets.fromLTRB(FSizes.defaultSpace, 8, FSizes.defaultSpace, 8),
              color: dark ? FColors.dark : FColors.white,
              child: Row(
                children: [
                  // Search Bar
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: dark ? FColors.darkerGrey : FColors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        onChanged: (value) => controller.setSearchQuery(value),
                        decoration: InputDecoration(
                          hintText: "Search posts, topics...",
                          hintStyle: TextStyle(
                            color: dark ? FColors.darkGrey : FColors.textSecondary,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Iconsax.search_normal_1,
                            color: dark ? FColors.darkGrey : FColors.textSecondary,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: FSizes.md,
                            vertical: FSizes.md,
                          ),
                        ),
                        style: TextStyle(
                          color: dark ? FColors.white : FColors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Time Filter Button
                  Obx(() {
                    final isFiltered = controller.selectedTimeFilter.value != 'All Time';
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
                                : (dark ? FColors.darkerGrey : FColors.grey.withOpacity(0.1)),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isFiltered
                                  ? FColors.primary
                                  : (dark ? FColors.darkGrey.withOpacity(0.3) : FColors.grey.withOpacity(0.2)),
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
                                    : (dark ? FColors.darkGrey : FColors.textSecondary),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                controller.selectedTimeFilter.value,
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
                                    : (dark ? FColors.darkGrey : FColors.textSecondary),
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

            // Posts List - 修复 TabBarView 布局问题
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

  // 修复：将 TabBarView 的内容提取为单独的方法
  Widget _buildTabContent(PostsController controller, bool dark, BuildContext context) {
    return Obx(() {
      if (controller.filteredPosts.isEmpty) {
        return _buildEmptyState(context, dark);
      }

      return FPostsList(
        posts: controller.filteredPosts.toList(),
        onRefresh: () => controller.refreshPosts(),
      );
    });
  }

  IconData _getTimeFilterIcon(String filter) {
    switch (filter) {
      case 'Today':
        return Iconsax.sun_1;
      case 'This Week':
        return Iconsax.calendar_1;
      case 'This Month':
        return Iconsax.calendar;
      case 'This Year':
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
          color: dark ? FColors.darkerGrey : FColors.white,
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
                    Icon(
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
                children: [
                  _buildTimeFilterOption('All Time', controller, dark, context),
                  _buildTimeFilterOption('Today', controller, dark, context),
                  _buildTimeFilterOption('This Week', controller, dark, context),
                  _buildTimeFilterOption('This Month', controller, dark, context),
                  _buildTimeFilterOption('This Year', controller, dark, context),
                ],
              )),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeFilterOption(String filter, PostsController controller, bool dark, BuildContext context) {
    final isSelected = controller.selectedTimeFilter.value == filter;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          controller.setTimeFilter(filter);
          Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: FSizes.defaultSpace,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? FColors.primary.withOpacity(0.1)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? FColors.primary.withOpacity(0.2)
                      : (dark ? FColors.darkGrey.withOpacity(0.2) : FColors.grey.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getTimeFilterIcon(filter),
                  color: isSelected
                      ? FColors.primary
                      : (dark ? FColors.darkGrey : FColors.textSecondary),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected
                        ? FColors.primary
                        : (dark ? FColors.white : FColors.black),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
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

  Widget _buildEmptyState(BuildContext context, bool dark) {
    return Center(
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
                Iconsax.message_search,
                size: 64,
                color: FColors.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: FSizes.spaceBtwItems),
            Text(
              'No posts found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: dark ? FColors.white : FColors.black,
              ),
            ),
            const SizedBox(height: FSizes.sm),
            Text(
              'Try adjusting your filters or be the first to post!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: dark ? FColors.darkGrey : FColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ViewPostScreen extends StatelessWidget {
  final String postId;
  const ViewPostScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Post')),
      body: Center(child: Text('View Post Screen: $postId')),
    );
  }
}

class EditPostScreen extends StatelessWidget {
  final PostModel post;
  const EditPostScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Post')),
      body: Center(child: Text('Edit Post Screen: ${post.postId}')),
    );
  }
}

class FPostInput extends StatelessWidget {
  const FPostInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(FSizes.md),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            ),
            child: GestureDetector(
              onTap: () {
                Get.to(() => const CreatePostScreen());
              },
              child: Text(
                "What's on your mind?",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
          const SizedBox(height: FSizes.spaceBtwItems),
          FCustomButton(
            text: 'My Post',
            backgroundColor: const Color(0xFF4CAF50),
            textColor: Colors.white,
            onPressed: () {
              Get.to(() => const MyPostsScreen());
            },
          ),
        ],
      ),
    );
  }
}

class FCustomButton extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final double? fontSize;
  final IconData? icon;
  final bool isOutlined;
  final double? borderRadius;

  const FCustomButton({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.onPressed,
    this.width,
    this.height,
    this.fontSize,
    this.icon,
    this.isOutlined = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    final effectiveBackgroundColor = backgroundColor ??
        (isOutlined ? Colors.transparent : FColors.primary);

    final effectiveTextColor = textColor ??
        (isOutlined ? FColors.primary : FColors.white);

    return SizedBox(
      width: width,
      height: height ?? 36,
      child: isOutlined
          ? OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: effectiveTextColor,
          side: BorderSide(color: effectiveTextColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              borderRadius ?? FSizes.borderRadiusSm * 2,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: FSizes.sm,
            vertical: FSizes.xs,
          ),
        ),
        onPressed: onPressed,
        icon: icon != null
            ? Icon(icon, size: FSizes.iconXs)
            : const SizedBox.shrink(),
        label: Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: effectiveTextColor,
            fontWeight: FontWeight.w500,
            fontSize: fontSize ?? 12,
          ),
        ),
      )
          : ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBackgroundColor,
          foregroundColor: effectiveTextColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              borderRadius ?? FSizes.borderRadiusSm * 2,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: FSizes.sm,
            vertical: FSizes.xs,
          ),
        ),
        onPressed: onPressed,
        icon: icon != null
            ? Icon(icon, size: FSizes.iconXs)
            : const SizedBox.shrink(),
        label: Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: effectiveTextColor,
            fontWeight: FontWeight.w500,
            fontSize: fontSize ?? 12,
          ),
        ),
      ),
    );
  }
}

class FCustomTag extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const FCustomTag({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: FSizes.sm,
        vertical: FSizes.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusSm * 2),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}