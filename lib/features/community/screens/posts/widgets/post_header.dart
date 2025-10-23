// import 'package:flutter/material.dart';
// import 'package:fyp/features/community/models/post_model.dart';
//
// class PostHeader extends StatelessWidget {
//   final Post community;
//
//   const PostHeader({super.key, required this.community});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           community.title,
//           style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 8),
//         Row(
//           children: [
//             const CircleAvatar(
//               backgroundColor: Colors.grey,
//               child: Icon(Icons.person, color: Colors.white),
//             ),
//             const SizedBox(width: 10),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(community.user.displayName ?? 'Unknown User', style: const TextStyle(color: Colors.white)),
//                 Text(community.timeAgo, style: const TextStyle(color: Colors.grey, fontSize: 12)),
//               ],
//             ),
//             const Spacer(),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: Colors.blue,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Text('OP', style: TextStyle(color: Colors.white, fontSize: 12)),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }