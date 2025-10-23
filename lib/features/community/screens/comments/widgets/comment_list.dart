import 'package:flutter/material.dart';
import 'package:fyp/features/community/models/comment_model.dart';
import 'package:fyp/features/community/screens/comments/widgets/comment_card.dart';
import 'package:fyp/utils/constants/sizes.dart';

class FCommentsList extends StatelessWidget {
  final List<Comment> comments;
  final String postId;

  const FCommentsList({
    super.key,
    required this.comments,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(FSizes.defaultSpace),
        child: const Center(
          child: Text('No comments yet'),
        ),
      );
    }

    return Column(
      children: comments.map((comment) => FCommentCard(
        postId: postId,
        comment: comment,
      )).toList(),
    );
  }
}