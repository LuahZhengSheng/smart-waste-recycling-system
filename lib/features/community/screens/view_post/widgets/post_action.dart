import 'package:flutter/material.dart';
import 'package:fyp/features/community/models/post_model.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

import 'action_button.dart';

class FPostActions extends StatelessWidget {
  final PostModel post;
  final bool isLiked;
  final VoidCallback? onLikePressed;
  final VoidCallback? onCommentPressed;
  final VoidCallback? onSharePressed;

  const FPostActions({
    super.key,
    required this.post,
    required this.isLiked,
    this.onLikePressed,
    this.onCommentPressed,
    this.onSharePressed,
  });

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Row(
      children: [
        // Like Button
        FActionButton(
          icon: isLiked ? Iconsax.like_15 : Iconsax.like_1,
          text: _formatCount(post.likes.length),
          backgroundColor: FColors.transparent,
          iconColor: FColors.primary,
          textColor: FColors.primary,
          hasHoverEffect: true,
          onPressed: onLikePressed,
        ),
        const SizedBox(width: FSizes.spaceBtwItems),

        // Comment Button
        FActionButton(
          icon: Iconsax.message,
          text: _formatCount(post.commentCount),
          backgroundColor: FColors.transparent,
          iconColor: FColors.primary,
          textColor: FColors.primary,
          hasHoverEffect: true,
          onPressed: onCommentPressed,
        ),
        const SizedBox(width: FSizes.spaceBtwItems),

        // Share Button
        // FActionButton(
        //   icon: Iconsax.share,
        //   text: 'Share',
        //   backgroundColor: FColors.transparent,
        //   iconColor: FColors.primary,
        //   textColor: FColors.primary,
        //   hasHoverEffect: true,
        //   onPressed: onSharePressed ?? () => _showShareOptions(context),
        // ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count < 1000) {
      return count.toString();
    } else if (count < 1000000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
  }

  void _showShareOptions(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: dark ? FColors.darkerGrey : FColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(FSizes.borderRadiusLg)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(FSizes.defaultSpace),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: FSizes.spaceBtwItems),
              decoration: BoxDecoration(
                color: dark ? FColors.darkGrey : FColors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Text(
              'Share Post',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: dark ? FColors.white : FColors.black,
              ),
            ),
            const SizedBox(height: FSizes.spaceBtwItems),

            // Share options
            ListTile(
              leading: Icon(
                Iconsax.copy,
                color: dark ? FColors.darkGrey : FColors.grey,
              ),
              title: Text(
                'Copy Link',
                style: TextStyle(
                  color: dark ? FColors.white : FColors.black,
                ),
              ),
              onTap: () {
                // TODO: Implement copy link functionality
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Iconsax.message,
                color: dark ? FColors.darkGrey : FColors.grey,
              ),
              title: Text(
                'Share via Message',
                style: TextStyle(
                  color: dark ? FColors.white : FColors.black,
                ),
              ),
              onTap: () {
                // TODO: Implement share via message
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}