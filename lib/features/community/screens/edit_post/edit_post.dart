import 'package:flutter/material.dart';
import 'package:fyp/common/widgets/appbar/appbar.dart';
import 'package:fyp/features/community/models/post_model.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/posts/my_post_controller.dart';

class EditPostScreen extends StatelessWidget {
  final PostModel post;

  const EditPostScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyPostsController>();
    final dark = FHelperFunctions.isDarkMode(context);

    final contentController = TextEditingController(text: post.content);
    final postTypeController = TextEditingController(text: post.postType);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: FAppBar(
        title: const Text('Edit Post'),
        showBackArrow: true,
        actions: [
          TextButton(
            onPressed: () async {
              if (contentController.text.trim().isEmpty) {
                Get.snackbar('Error', 'Post content cannot be empty');
                return;
              }

              final updatedPost = post.copyWith(
                content: contentController.text.trim(),
                postType: postTypeController.text.trim(),
                updatedAt: DateTime.now(),
              );

              await controller.editPost(updatedPost);
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(FSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Type Selection
            Text(
              'Post Type',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: dark ? FColors.white : FColors.black,
              ),
            ),
            const SizedBox(height: FSizes.spaceBtwItems),
            DropdownButtonFormField<String>(
              value: post.postType,
              decoration: InputDecoration(
                labelText: 'Select Post Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Tips',
                  child: Text('Tips'),
                ),
                DropdownMenuItem(
                  value: 'Question',
                  child: Text('Question'),
                ),
                DropdownMenuItem(
                  value: 'Discussion',
                  child: Text('Discussion'),
                ),
              ],
              onChanged: (value) {
                postTypeController.text = value ?? post.postType;
              },
            ),
            const SizedBox(height: FSizes.spaceBtwSections),

            // Content Editor
            Text(
              'Post Content',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: dark ? FColors.white : FColors.black,
              ),
            ),
            const SizedBox(height: FSizes.spaceBtwItems),
            TextFormField(
              controller: contentController,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: 'What would you like to share?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
                ),
              ),
            ),
            const SizedBox(height: FSizes.spaceBtwSections),

            // Current Media Preview (if any)
            if (post.media.isNotEmpty) ...[
              Text(
                'Current Media',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: dark ? FColors.white : FColors.black,
                ),
              ),
              const SizedBox(height: FSizes.spaceBtwItems),
              Text(
                'Note: Media files cannot be edited. To change media, please delete and create a new community.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: dark ? FColors.darkGrey : FColors.grey,
                ),
              ),
            ],

            const SizedBox(height: FSizes.spaceBtwSections),

            // Delete Post Button
            Center(
              child: TextButton(
                onPressed: () {
                  Get.dialog(
                    AlertDialog(
                      title: const Text('Delete Post'),
                      content: const Text('Are you sure you want to delete this community? This action cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Get.back();
                            await controller.deletePost(post.postId);
                            Get.back(); // Close edit screen
                          },
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text(
                  'Delete Post',
                  style: TextStyle(color: FColors.error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}