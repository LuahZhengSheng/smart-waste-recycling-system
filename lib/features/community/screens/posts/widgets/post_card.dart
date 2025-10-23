// import 'package:flutter/material.dart';
// import 'package:fyp/features/community/models/post_model.dart';
// import 'package:fyp/features/community/screens/posts/post_detail_screen.dart';
// import 'package:get/get.dart';
//
// class PostCard extends StatelessWidget {
//   final Post community;
//   const PostCard({super.key, required this.community});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => Get.to(PostDetailScreen(community: community)),
//       child: Card(
//         color: Colors.grey[900],
//         margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         child: Padding(
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   /// **如果有图片，显示缩略图**
//                   // if (community.imageUrl!.isNotEmpty)
//                   //   ClipRRect(
//                   //     borderRadius: BorderRadius.circular(8),
//                   //     child: Image.network(community.imageUrl!, width: 50, height: 50, fit: BoxFit.cover),
//                   //   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         /// **标题自动换行**
//                         Text(
//                           community.title,
//                           style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
//                           softWrap: true,
//                         ),
//                         const SizedBox(height: 4),
//                         /// **描述（最多 2 行）**
//                         Text(
//                           community.caption,
//                           style: const TextStyle(color: Colors.white70, fontSize: 14),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   /// **点赞、评论数**
//                   Row(
//                     children: [
//                       const Icon(Icons.star, color: Colors.yellow, size: 16),
//                       const SizedBox(width: 5),
//                       Text('${community.likes}', style: const TextStyle(color: Colors.white70)),
//                       const SizedBox(width: 10),
//                       const Icon(Icons.comment, color: Colors.white70, size: 16),
//                       const SizedBox(width: 5),
//                       Text('${community.comments}', style: const TextStyle(color: Colors.white70)),
//                     ],
//                   ),
//                   /// **时间**
//                   Text(community.timeAgo, style: const TextStyle(color: Colors.white70, fontSize: 12)),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }