import 'package:flutter/material.dart';
import 'package:fyp/features/community/models/comment_model.dart';
import 'package:fyp/features/community/screens/comments/widgets/comment_card.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:fyp/features/community/controllers/posts/comment_controller.dart';

class FCommentsList extends StatefulWidget {
  final List<Comment> comments;
  final String postId;

  const FCommentsList({
    super.key,
    required this.comments,
    required this.postId,
  });

  @override
  State<FCommentsList> createState() => _FCommentsListState();
}

class _FCommentsListState extends State<FCommentsList> {
  bool _isLoadingUserData = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didUpdateWidget(FCommentsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload user data when comments change
    if (widget.comments.length != oldWidget.comments.length) {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    if (widget.comments.isEmpty) return;

    setState(() {
      _isLoadingUserData = true;
    });

    final commentController = Get.find<CommentController>();
    await commentController.loadUserDataForComments(widget.comments);

    if (mounted) {
      setState(() {
        _isLoadingUserData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    // Show loading while fetching user data
    if (_isLoadingUserData && widget.comments.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(FSizes.defaultSpace),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: FColors.primary,
                backgroundColor: dark ? FColors.communityDarkBorder : FColors.grey.withOpacity(0.2),
              ),
              const SizedBox(height: FSizes.md),
              Text(
                'Loading comments...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: dark ? FColors.darkTextSecondary : FColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state
    if (widget.comments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(FSizes.defaultSpace),
        child: Center(
          child: Text(
            'No comments yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: dark ? FColors.darkTextSecondary : FColors.textSecondary,
            ),
          ),
        ),
      );
    }

    // Comments list
    return Column(
      children: widget.comments
          .map((comment) => FCommentCard(
        postId: widget.postId,
        comment: comment,
      ))
          .toList(),
    );
  }
}