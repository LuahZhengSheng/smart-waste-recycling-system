import 'package:flutter/material.dart';
import 'package:fyp/features/community/controllers/posts/post_detail_controller.dart';
import 'package:fyp/features/community/models/post_enums.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';

import '../../../../../utils/constants/colors.dart';

class FCommentsHeader extends StatelessWidget {
  const FCommentsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostDetailsController>();
    final dark = FHelperFunctions.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      child: Row(
        children: [
          Obx(() => Text(
            '${controller.comments.length} Comments',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: dark ? FColors.white : FColors.black,
            ),
          )),
          const Spacer(),
          GestureDetector(
            onTap: () => _showSortingBottomSheet(context),
            child: Row(
              children: [
                Obx(() => Text(
                  controller.commentSortType.value.displayName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: FColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                )),
                const SizedBox(width: FSizes.xs),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: FColors.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSortingBottomSheet(BuildContext context) {
    final controller = Get.find<PostDetailsController>();
    final dark = FHelperFunctions.isDarkMode(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: dark ? FColors.communityDarkSurface : FColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(FSizes.borderRadiusLg)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(FSizes.defaultSpace),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sort Comments',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: dark ? FColors.white : FColors.black,
              ),
            ),
            const SizedBox(height: FSizes.spaceBtwItems),

            // 使用枚举值而不是字符串
            _buildSortOption(CommentSortType.topComments, controller, dark),
            _buildSortOption(CommentSortType.newestFirst, controller, dark),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(CommentSortType sortType, PostDetailsController controller, bool dark) {
    final isSelected = controller.commentSortType.value == sortType;

    return ListTile(
      title: Text(
        sortType.displayName,
        style: TextStyle(
          color: isSelected
              ? FColors.primary
              : (dark ? FColors.darkText : FColors.darkGrey),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: FColors.primary) : null,
      onTap: () {
        controller.setSortType(sortType);
        Get.back();
      },
    );
  }
}