import 'package:flutter/material.dart';
import 'package:fyp/features/community/controllers/posts/comment_controller.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:get/get.dart';

class FWriteCommentInput extends StatelessWidget {
  final String postId; 

  const FWriteCommentInput({
    super.key,
    required this.postId, 
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CommentController>();

    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: FSizes.md,
        right: FSizes.md,
        top: FSizes.sm,
        bottom: MediaQuery.of(context).padding.bottom + FSizes.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // User avatar
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(
              controller.getUserAvatar(controller.getCurrentUserId()),
            ),
          ),

          const SizedBox(width: FSizes.sm),

          // Input field - 使用 Expanded 防止溢出
          Expanded(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: 100, // 限制最大高度
              ),
              child: TextField(
                controller: controller.commentController,
                decoration: InputDecoration(
                  hintText: 'Write a comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: FSizes.md,
                    vertical: FSizes.sm,
                  ),
                  isCollapsed: true, // 防止内部 padding 问题
                ),
                maxLines: null, // 允许多行
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSubmit(controller),
              ),
            ),
          ),

          const SizedBox(width: FSizes.sm),

          // Send button - 移除 Obx，使用简单的条件判断
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller.commentController,
            builder: (context, value, child) {
              final isValid = value.text.trim().isNotEmpty;
              return GestureDetector(
                onTap: isValid ? () => _handleSubmit(controller) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isValid ? const Color(0xFF4CAF50) : Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleSubmit(CommentController controller) {
    if (controller.commentController.text.trim().isNotEmpty) {
      controller.addComment(postId);
    }
  }
}