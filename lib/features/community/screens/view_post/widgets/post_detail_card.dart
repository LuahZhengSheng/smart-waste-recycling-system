// import 'package:flutter/material.dart';
// import 'package:fyp/features/community/controllers/posts/post_detail_controller.dart';
// import 'package:fyp/features/community/models/post_model.dart';
// import 'package:fyp/features/community/screens/view_post/post_detail.dart';
// import 'package:fyp/features/community/screens/view_post/widgets/post_action.dart';
// import 'package:fyp/features/community/screens/view_post/widgets/post_media.dart';
// import 'package:fyp/features/community/screens/view_post/widgets/user_info.dart';
// import 'package:fyp/utils/constants/sizes.dart';
// import 'package:get/get.dart';
//
// import '../../common_post_widgets/common_post_widgets.dart';
//
// class FPostDetailsCard extends StatelessWidget {
//   final PostModel post;
//
//   const FPostDetailsCard({super.key, required this.post});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<PostDetailsController>();
//     final currentUserId = controller.getCurrentUserId();
//     final isLiked = post.likes.contains(currentUserId);
//
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.all(FSizes.md),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // User info
//           FUserInfo(
//             userId: post.userId,
//             timeAgo: _formatTimeAgo(post.createdAt),
//             postType: post.postType,
//           ),
//
//           const SizedBox(height: FSizes.spaceBtwItems),
//
//           // Post content
//           Text(
//             post.content,
//             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//               height: 1.4,
//             ),
//           ),
//
//           // Post media
//           if (post.media.isNotEmpty) ...[
//             const SizedBox(height: FSizes.spaceBtwItems),
//             FPostMedia(
//               mediaUrls: post.media,
//               onTap: (index) => _showMediaViewer(context, post.media, index),
//             ),
//           ],
//
//           const SizedBox(height: FSizes.spaceBtwItems),
//
//           // Action buttons
//           Obx(() => FPostActions(
//             post: controller.post.value,
//             isLiked: controller.post.value.likes.contains(currentUserId),
//             onLikePressed: () => controller.togglePostLike(),
//             onCommentPressed: () {}, // Already in comment screen
//             // showCommentButton: false,
//           )),
//         ],
//       ),
//     );
//   }
//
//   String _formatTimeAgo(DateTime dateTime) {
//     final now = DateTime.now();
//     final difference = now.difference(dateTime);
//
//     if (difference.inSeconds < 60) {
//       return '${difference.inSeconds}s ago';
//     } else if (difference.inMinutes < 60) {
//       return '${difference.inMinutes}m ago';
//     } else if (difference.inHours < 24) {
//       return '${difference.inHours}h ago';
//     } else if (difference.inDays < 30) {
//       return '${difference.inDays}d ago';
//     } else {
//       final months = (difference.inDays / 30).floor();
//       return '${months}mo ago';
//     }
//   }
//
//   void _showMediaViewer(BuildContext context, List<String> mediaUrls, int initialIndex) {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => FMediaViewer(
//           mediaUrls: mediaUrls,
//           initialIndex: initialIndex,
//         ),
//       ),
//     );
//   }
// }