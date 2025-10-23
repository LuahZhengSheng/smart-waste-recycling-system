import 'package:flutter/material.dart';
import 'package:fyp/features/community/models/post_model.dart';
import 'package:fyp/features/community/screens/view_post/widgets/post_card.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

class FPostsList extends StatelessWidget {
  final List<PostModel> posts;
  final VoidCallback? onRefresh;
  final bool isLoading;

  const FPostsList({
    super.key,
    required this.posts,
    this.onRefresh,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    if (isLoading) {
      return _buildLoadingIndicator(dark);
    }

    if (posts.isEmpty) {
      return _buildEmptyState(context, dark);
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (onRefresh != null) {
          onRefresh!();
        }
      },
      color: FColors.primary,
      backgroundColor: dark ? FColors.darkerGrey : FColors.white,
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: FSizes.defaultSpace,
          vertical: FSizes.spaceBtwItems,
        ),
        children: [
          ...posts.map((post) => Padding(
            padding: const EdgeInsets.only(bottom: FSizes.spaceBtwItems),
            child: FPostCard(
              post: post,
              isInDetailScreen: false, // 明确标记在 Feed 页面
            ),
          )),

          // Add some bottom padding for better scrolling experience
          const SizedBox(height: FSizes.spaceBtwSections * 2),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(bool dark) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: FSizes.defaultSpace,
        vertical: FSizes.spaceBtwItems,
      ),
      children: List.generate(3, (index) => Padding(
        padding: const EdgeInsets.only(bottom: FSizes.spaceBtwItems),
        child: Container(
          padding: const EdgeInsets.all(FSizes.md),
          decoration: BoxDecoration(
            color: dark ? FColors.darkerGrey : FColors.white,
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            border: Border.all(
              color: dark
                  ? FColors.darkGrey.withOpacity(0.3)
                  : FColors.grey.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info skeleton
              Row(
                children: [
                  _buildShimmer(40, 40, isCircle: true, dark: dark),
                  const SizedBox(width: FSizes.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmer(80, 12, dark: dark),
                      const SizedBox(height: FSizes.xs),
                      _buildShimmer(60, 10, dark: dark),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: FSizes.spaceBtwItems),

              // Content skeleton
              _buildShimmer(double.infinity, 12, dark: dark),
              const SizedBox(height: FSizes.xs),
              _buildShimmer(250, 12, dark: dark),
              const SizedBox(height: FSizes.xs),
              _buildShimmer(180, 12, dark: dark),

              const SizedBox(height: FSizes.spaceBtwItems),

              // Actions skeleton
              Row(
                children: [
                  _buildShimmer(60, 32, dark: dark),
                  const SizedBox(width: FSizes.spaceBtwItems),
                  _buildShimmer(60, 32, dark: dark),
                  const SizedBox(width: FSizes.spaceBtwItems),
                  _buildShimmer(60, 32, dark: dark),
                ],
              ),
            ],
          ),
        ),
      )),
    );
  }

  Widget _buildShimmer(double width, double height, {bool isCircle = false, required bool dark}) {
    return Container(
      width: width == double.infinity ? null : width,
      height: height,
      decoration: BoxDecoration(
        color: dark
            ? FColors.darkGrey.withOpacity(0.3)
            : FColors.grey.withOpacity(0.3),
        borderRadius: isCircle
            ? BorderRadius.circular(height / 2)
            : BorderRadius.circular(FSizes.borderRadiusSm),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool dark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(FSizes.defaultSpace * 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.document,
            size: 80,
            color: dark ? FColors.darkGrey : FColors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: FSizes.spaceBtwItems),

          Text(
            'No posts found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: dark ? FColors.white : FColors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: FSizes.spaceBtwItems / 2),

          Text(
            'Be the first to share something with the community!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: dark ? FColors.darkGrey : FColors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: FSizes.spaceBtwSections),

          ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to create post screen
            },
            icon: const Icon(Iconsax.add, size: FSizes.iconSm),
            label: const Text('Create Post'),
            style: ElevatedButton.styleFrom(
              backgroundColor: FColors.primary,
              foregroundColor: FColors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: FSizes.lg,
                vertical: FSizes.sm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
              ),
            ),
          ),
        ],
      ),
    );
  }
}