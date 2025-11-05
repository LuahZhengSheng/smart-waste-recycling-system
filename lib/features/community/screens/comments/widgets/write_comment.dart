import 'package:flutter/material.dart';
import 'package:fyp/features/community/controllers/posts/comment_controller.dart';
import 'package:get/get.dart';

import '../../common_post_widgets/common_post_widgets.dart';

class FWriteCommentInput extends StatelessWidget {
  final String postId;

  const FWriteCommentInput({
    super.key,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CommentController>();

    return FInputField(
      controller: controller.commentController,
      focusNode: controller.commentFocusNode,
      isEnabled: !controller.isSubmitting.value,
      isSubmitting: controller.isSubmitting.value,
      hintText: 'Write a comment...',
      isEditMode: controller.isEditMode.value,
      onSubmit: () {
        if (controller.isEditMode.value) {
          controller.saveEdit();
        } else {
          controller.addComment(postId);
        }
      },
      onCancel: () => controller.cancelEdit(),
      isComment: true, // 明确标记这是评论输入框
    );
  }
}