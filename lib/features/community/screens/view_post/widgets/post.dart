// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// class PostWidget extends StatelessWidget {
//   final String name;
//   final String timeAgo;
//   final String content;
//   final String profileImage;
//   final List<String>? postImages;
//   final String likes;
//   final String comments;
//
//   const PostWidget({
//     Key? key,
//     required this.name,
//     required this.timeAgo,
//     required this.content,
//     required this.profileImage,
//     this.postImages,
//     required this.likes,
//     required this.comments,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 20),
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(0),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // User info and Tips badge
//           Row(
//             children: [
//               CircleAvatar(
//                 radius: 20,
//                 backgroundImage: NetworkImage(profileImage),
//               ),
//               SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       name,
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                     Text(
//                       timeAgo,
//                       style: TextStyle(
//                         color: Colors.grey[600],
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: Color(0xFFE8F5E8),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   'Tips',
//                   style: TextStyle(
//                     color: Color(0xFF4CAF50),
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//
//           SizedBox(height: 12),
//
//           // Post content
//           Text(
//             content,
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.black87,
//               height: 1.4,
//             ),
//           ),
//
//           // Post images (if any)
//           if (postImages != null && postImages!.isNotEmpty) ...[
//             SizedBox(height: 16),
//             Container(
//               height: 120,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: postImages!.length,
//                 itemBuilder: (context, index) {
//                   return Container(
//                     width: 120,
//                     margin: EdgeInsets.only(right: 8),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12),
//                       gradient: LinearGradient(
//                         colors: _getGradientColors(index),
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//
//           SizedBox(height: 16),
//
//           // Like and comment buttons
//           Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: Color(0xFF4CAF50),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       Icons.thumb_up,
//                       color: Colors.white,
//                       size: 16,
//                     ),
//                     SizedBox(width: 6),
//                     Text(
//                       likes,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               SizedBox(width: 12),
//
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[200],
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       Icons.chat_bubble_outline,
//                       color: Colors.grey[600],
//                       size: 16,
//                     ),
//                     SizedBox(width: 6),
//                     Text(
//                       comments,
//                       style: TextStyle(
//                         color: Colors.grey[600],
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   List<Color> _getGradientColors(int index) {
//     switch (index % 3) {
//       case 0:
//         return [Color(0xFFFFB74D), Color(0xFFFF8A65), Color(0xFF81C784)];
//       case 1:
//         return [Color(0xFF64B5F6), Color(0xFF42A5F5), Color(0xFF29B6F6)];
//       case 2:
//         return [Color(0xFFBA68C8), Color(0xFFAB47BC), Color(0xFF42A5F5)];
//       default:
//         return [Color(0xFFFFB74D), Color(0xFFFF8A65)];
//     }
//   }
// }