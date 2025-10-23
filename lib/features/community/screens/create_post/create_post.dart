import 'package:flutter/material.dart';
import 'package:fyp/common/widgets/appbar/appbar.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/posts/create_post_controller.dart';
import 'widgets/media_preview_grid.dart';
import 'widgets/post_type_selector.dart';

class CreatePostScreen extends StatelessWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreatePostController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: FAppBar(
        title: const Text('Create Post'),
        showBackArrow: true,
        actions: [
          Obx(() => TextButton(
            onPressed: controller.isPosting
                ? null
                : () => controller.createPost(),
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
              'Post',
              style: TextStyle(
                color: controller.canPost
                    ? FColors.primary
                    : FColors.darkGrey,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          )),
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
                    Container(
                      decoration: BoxDecoration(
                        color: dark ? FColors.darkerGrey : FColors.white,
                        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                        border: Border.all(
                          color: dark
                              ? FColors.darkGrey
                              : FColors.grey.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: controller.contentController,
                            maxLines: 8,
                            maxLength: 2000,
                            decoration: InputDecoration(
                              hintText: 'Share your thoughts...',
                              hintStyle: TextStyle(
                                color: dark ? FColors.darkGrey : FColors.grey,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(FSizes.md),
                              counterStyle: TextStyle(
                                color: dark ? FColors.darkGrey : FColors.grey,
                                fontSize: 12,
                              ),
                            ),
                            style: TextStyle(
                              color: dark ? FColors.white : FColors.black,
                              fontSize: 15,
                            ),
                          ),
                        ],
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
                        Obx(() => Text(
                          '${controller.mediaFiles.length}/10',
                          style: TextStyle(
                            color: controller.mediaFiles.length >= 10
                                ? FColors.error
                                : (dark ? FColors.darkGrey : FColors.grey),
                            fontSize: 14,
                          ),
                        )),
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
              color: dark ? FColors.darkerGrey : FColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Obx(() => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.canPost && !controller.isPosting
                    ? () => controller.createPost()
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: FColors.primary,
                  disabledBackgroundColor: FColors.grey,
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
                      'Post',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: FColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ),
        ],
      ),
    );
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
          color: dark ? FColors.darkerGrey : FColors.white,
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
              style: TextStyle(
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