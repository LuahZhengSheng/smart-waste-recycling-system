// import 'package:flutter/material.dart';
// import 'package:fyp/features/community/controllers/posts/post_controller.dart';
// import 'package:fyp/utils/constants/sizes.dart';
// import 'package:get/get.dart';
//
// // User info widgets
// class FUserInfo extends StatelessWidget {
//   final String userId;
//   final String timeAgo;
//   final String postType;
//
//   const FUserInfo({
//     super.key,
//     required this.userId,
//     required this.timeAgo,
//     required this.postType,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<PostsController>();
//
//     return Row(
//       children: [
//         // User avatar - fetch from controller
//         CircleAvatar(
//           radius: FSizes.iconMd,
//           backgroundColor: Colors.grey[300],
//           child: Icon(
//             Icons.person,
//             size: FSizes.iconMd,
//             color: Colors.grey[600],
//           ),
//         ),
//         const SizedBox(width: FSizes.spaceBtwItems),
//
//         // User info - 使用 Expanded 包装
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // User name
//               Text(
//                 _getDisplayName(userId),
//                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: FSizes.xs),
//               Text(
//                 timeAgo,
//                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                   color: Colors.grey[600],
//                 ),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(width: FSizes.spaceBtwItems),
//
//         // Post type tag - 确保标签不会太长
//         Container(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.25, // 限制最大宽度
//           ),
//           child: FCustomTag(
//             text: _getPostTypeDisplay(postType),
//             backgroundColor: _getTagBackgroundColor(postType),
//             textColor: _getTagTextColor(postType),
//           ),
//         ),
//       ],
//     );
//   }
//
//   String _getDisplayName(String userId) {
//     // TODO: 从控制器获取真实用户名
//     // return controller.getUserName(userId);
//     return 'User ${userId.substring(0, 6)}...';
//   }
//
//   String _getPostTypeDisplay(String postType) {
//     switch (postType.toLowerCase()) {
//       case 'tip':
//         return 'Tip';
//       case 'question':
//         return 'Q&A';
//       case 'discussion':
//         return 'Chat';
//       default:
//         return postType;
//     }
//   }
//
//   // Get tag background color based on community type
//   Color _getTagBackgroundColor(String postType) {
//     switch (postType.toLowerCase()) {
//       case 'tip':
//         return const Color(0xFFE8F5E8);
//       case 'question':
//         return const Color(0xFFF3E5F5);
//       case 'discussion':
//         return const Color(0xFFE3F2FD);
//       default:
//         return Colors.grey[200]!;
//     }
//   }
//
//   // Get tag text color based on community type
//   Color _getTagTextColor(String postType) {
//     switch (postType.toLowerCase()) {
//       case 'tip':
//         return const Color(0xFF4CAF50);
//       case 'question':
//         return const Color(0xFF9C27B0);
//       case 'discussion':
//         return const Color(0xFF2196F3);
//       default:
//         return Colors.grey[600]!;
//     }
//   }
// }