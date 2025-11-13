import 'package:flutter/material.dart';
import 'package:fyp/features/community/models/comment_model.dart';
import 'package:fyp/features/community/screens/comments/widgets/comment_card.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../common_post_widgets/common_post_widgets.dart';

class FCommentsList extends StatelessWidget {
  final String postId;
  final List<Comment> comments;
  final bool isPostDisabled;

  const FCommentsList({
    super.key,
    required this.postId,
    required this.comments,
    this.isPostDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    if (comments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: FSizes.spaceBtwSections * 2),
        child: FEmptyState(
          icon: Iconsax.message_text,
          title: 'No comments yet',
          subtitle: isPostDisabled
              ? 'This post has been disabled'
              : 'Be the first to comment!',
        ),
      );
    }

    // If post is disabled, wrap comments in a Stack with overlay
    if (isPostDisabled) {
      return Stack(
        children: [
          // Comments list (dimmed)
          Opacity(
            opacity: 0.6,
            child: IgnorePointer(
              child: _buildCommentsList(context),
            ),
          ),
          // Disabled overlay
          Positioned.fill(
            child: Container(
              color: (dark ? FColors.black : FColors.white).withOpacity(0.3),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: FSizes.defaultSpace),
                  padding: const EdgeInsets.all(FSizes.lg),
                  decoration: BoxDecoration(
                    color: dark ? FColors.communityDarkSurface : FColors.white,
                    borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Container(
                      //   padding: const EdgeInsets.all(FSizes.md),
                      //   decoration: BoxDecoration(
                      //     color: FColors.error.withOpacity(0.1),
                      //     shape: BoxShape.circle,
                      //   ),
                      //   child: Icon(
                      //     Iconsax.slash,
                      //     color: FColors.error,
                      //     size: 32,
                      //   ),
                      // ),
                      // const SizedBox(height: FSizes.md),
                      // Text(
                      //   'Interactions Disabled',
                      //   style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      //     color: FColors.error,
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),
                      // const SizedBox(height: FSizes.xs),
                      // Text(
                      //   'You cannot interact with comments on this disabled post',
                      //   textAlign: TextAlign.center,
                      //   style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      //     color: dark ? FColors.darkTextSecondary : FColors.textSecondary,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Normal comments list for enabled posts
    return _buildCommentsList(context);
  }

  Widget _buildCommentsList(BuildContext context) {
    return Column(
      children: comments.map((comment) {
        return FCommentCard(
          comment: comment,
          postId: postId,
          isPostDisabled: isPostDisabled,
        );
      }).toList(),
    );
  }
}