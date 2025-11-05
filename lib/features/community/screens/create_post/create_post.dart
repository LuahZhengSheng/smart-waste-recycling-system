import 'package:flutter/material.dart';
import 'package:fyp/common/widgets/appbar/appbar.dart';
import 'package:fyp/features/community/controllers/posts/create_post_controller.dart';
import 'package:fyp/features/community/screens/create_post/widgets/media_preview_grid.dart';
import 'package:fyp/features/community/screens/create_post/widgets/post_type_selector.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CreatePostScreen extends StatelessWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreatePostController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Obx(() {
      // 如果是编辑模式且正在加载媒体，显示全屏加载
      if (controller.isEditMode && controller.isLoadingMedia) {
        return Scaffold(
          backgroundColor: dark ? FColors.communityDarkBackground : FColors.light,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  color: FColors.primary,
                  strokeWidth: 3,
                ),
                const SizedBox(height: FSizes.spaceBtwItems),
                Text(
                  'Loading post data...',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: dark ? FColors.white : FColors.black,
                  ),
                ),
                const SizedBox(height: FSizes.xs),
                Text(
                  'Please wait',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: dark ? FColors.darkTextSecondary : FColors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // 正常显示创建/编辑界面
      return Scaffold(
        backgroundColor: dark ? FColors.communityDarkBackground : FColors.light,
        appBar: FAppBar(
          title: Text(controller.isEditMode ? 'Edit Post' : 'Create Post'),
          showBackArrow: true,
          backgroundColor: dark ? FColors.communityDarkBackground : FColors.white,
          actions: [
            TextButton(
              onPressed: controller.isPosting ? null : () => controller.createPost(),
              child: controller.isPosting
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: FColors.primary,
                ),
              )
                  : Text(
                controller.isEditMode ? 'Update' : 'Post',
                style: TextStyle(
                  color: controller.canPost ? FColors.primary : FColors.darkGrey,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(FSizes.defaultSpace),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Post Type Selector
                      Text(
                        'Post Type',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: dark ? FColors.white : FColors.black,
                        ),
                      ),
                      const SizedBox(height: FSizes.sm),
                      const FPostTypeSelector(),
                      const SizedBox(height: FSizes.spaceBtwSections),

                      // Content Input
                      Text(
                        'Content',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: dark ? FColors.white : FColors.black,
                        ),
                      ),
                      const SizedBox(height: FSizes.sm),
                      TextField(
                        controller: controller.contentController,
                        maxLines: 8,
                        maxLength: 2000,
                        style: TextStyle(
                          color: dark ? FColors.darkText : FColors.black,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Share your thoughts...',
                          hintStyle: TextStyle(
                            color: dark ? FColors.darkTextSecondary : FColors.grey,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(FSizes.md),
                          counterStyle: TextStyle(
                            color: dark ? FColors.darkTextSecondary : FColors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: FSizes.spaceBtwSections),

                      // Media Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Media',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: dark ? FColors.white : FColors.black,
                            ),
                          ),
                          Text(
                            '${controller.mediaFiles.length}/10',
                            style: TextStyle(
                              color: controller.mediaFiles.length >= 10
                                  ? FColors.error
                                  : (dark ? FColors.darkTextSecondary : FColors.grey),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: FSizes.sm),

                      // Media Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _MediaButton(
                              icon: Iconsax.camera,
                              label: 'Camera',
                              onPressed: () => controller.openCustomCamera(),
                              dark: dark,
                            ),
                          ),
                          const SizedBox(width: FSizes.sm),
                          Expanded(
                            child: _MediaButton(
                              icon: Iconsax.gallery,
                              label: 'Gallery',
                              onPressed: () => controller.pickFromGallery(),
                              dark: dark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: FSizes.md),

                      // Media Preview Grid
                      const FMediaPreviewGrid(),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Post Button
            Container(
              padding: EdgeInsets.only(
                left: FSizes.defaultSpace,
                right: FSizes.defaultSpace,
                bottom: MediaQuery.of(context).padding.bottom + FSizes.md,
                top: FSizes.sm,
              ),
              decoration: BoxDecoration(
                color: dark ? FColors.communityDarkSurface : FColors.white,
                border: Border(
                  top: BorderSide(
                    color: dark ? FColors.communityDarkBorder : FColors.grey.withOpacity(0.2),
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.canPost && !controller.isPosting
                      ? () => controller.createPost()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FColors.primary,
                    disabledBackgroundColor: dark ? FColors.darkGrey : FColors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isPosting
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: FColors.white,
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Iconsax.send_1,
                        color: FColors.white,
                        size: 20,
                      ),
                      const SizedBox(width: FSizes.sm),
                      Text(
                        controller.isEditMode ? 'Update' : 'Post',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: FColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _MediaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool dark;

  const _MediaButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: FSizes.md,
          horizontal: FSizes.sm,
        ),
        decoration: BoxDecoration(
          color: dark ? FColors.communityDarkSurface : FColors.white,
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
          border: Border.all(
            color: FColors.primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: FColors.primary,
              size: FSizes.iconMd,
            ),
            const SizedBox(width: FSizes.xs),
            Text(
              label,
              style: const TextStyle(
                color: FColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}