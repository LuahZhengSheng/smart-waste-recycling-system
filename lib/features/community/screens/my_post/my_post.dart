import 'package:flutter/material.dart';
import 'package:fyp/common/widgets/appbar/appbar.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/posts/my_post_controller.dart';
import '../create_post/create_post.dart';
import '../view_post/widgets/post_card.dart';

class MyPostsScreen extends StatelessWidget {
  const MyPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyPostsController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: FAppBar(
        showBackArrow: true,
        backgroundColor: dark ? FColors.dark : FColors.white,
        title: Row(
          children: [
            Text(
              'My Posts',
              style: TextStyle(
                color: dark ? FColors.white : FColors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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

            // Divider
            Container(
              height: 8,
              color: dark ? FColors.black : FColors.grey.withOpacity(0.05),
            ),

            // Posts List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return _buildLoadingState(dark);
                }

                return TabBarView(
                  controller: controller.tabController,
                  children: List.generate(4, (index) {
                    return RefreshIndicator(
                      onRefresh: () => controller.refreshPosts(),
                      color: FColors.primary,
                      backgroundColor: dark ? FColors.darkerGrey : FColors.white,
                      child: Obx(() {
                        if (controller.filteredPosts.isEmpty) {
                          return _buildEmptyState(context, dark);
                        }

                        return ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(FSizes.defaultSpace),
                          itemCount: controller.filteredPosts.length,
                          itemBuilder: (context, index) {
                            return FPostCard(post: controller.filteredPosts[index]);
                          },
                        );
                      }),
                    );
                  }),
                );
              }),
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

  Widget _buildLoadingState(bool dark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: FColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              color: FColors.primary,
              backgroundColor: dark ? FColors.darkGrey : FColors.grey.withOpacity(0.2),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: FSizes.spaceBtwItems),
          Text(
            'Loading your posts...',
            style: TextStyle(
              color: dark ? FColors.white : FColors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool dark) {
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
                  Iconsax.document_text,
                  size: 64,
                  color: FColors.primary.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: FSizes.spaceBtwItems),
              Text(
                'No posts yet',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: dark ? FColors.white : FColors.black,
                ),
              ),
              const SizedBox(height: FSizes.sm),
              Text(
                'Start sharing your thoughts with the community!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: dark ? FColors.darkGrey : FColors.textSecondary,
                ),
              ),
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
                  onPressed: () => Get.to(() => const CreatePostScreen()),
                  icon: const Icon(Iconsax.edit_2, size: 20),
                  label: const Text(
                    'Create Your First Post',
                    style: TextStyle(
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
          ),
        ),
      ),
    );
  }
}