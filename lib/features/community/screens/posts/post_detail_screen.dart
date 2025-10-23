// import 'package:flutter/material.dart';
// import 'package:fyp/features/community/models/comment_model.dart';
// import 'package:fyp/features/community/models/post_model.dart';
// import 'package:fyp/features/community/screens/posts/widgets/post_content.dart';
// import 'package:fyp/features/community/screens/posts/widgets/post_header.dart';
//
// class PostDetailScreen extends StatelessWidget {
//   final Post community;
//
//   const PostDetailScreen({super.key, required this.community});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black87,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         title: const Text('Post Details'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             PostHeader(community: community),
//             const SizedBox(height: 16),
//             PostContent(community: community),
//             const SizedBox(height: 16),
//             PostActions(community: community),
//             const SizedBox(height: 16),
//             const Divider(color: Colors.grey),
//             const SizedBox(height: 10),
//             const CommentSection(comments: [
//               Comment(
//                 username: "domin0master",
//                 comment:
//                 "There are some fantastic YouTube resources for this but I'd definitely recommend setting up safety gaps throughout your domino chains!",
//                 timeAgo: "Today at 2:14 PM",
//               ),
//               Comment(
//                 username: "RubeN00b",
//                 comment: "Oooooh that's smart! How big do you make your gaps?",
//                 timeAgo: "Today at 2:16 PM",
//                 isOp: true,
//               ),
//             ]),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class PostActions extends StatelessWidget {
//   final Post community;
//
//   const PostActions({super.key, required this.community});
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         _iconWithText(Icons.favorite, Colors.pinkAccent, '${community.likes}'),
//         const SizedBox(width: 15),
//         _iconWithText(Icons.comment, Colors.white70, '${community.comments}'),
//         const SizedBox(width: 15),
//         _iconWithText(Icons.share, Colors.white70, '${community.shares}'),
//         const Spacer(),
//       ],
//     );
//   }
//
//   Widget _iconWithText(IconData icon, Color color, String text) {
//     return Row(
//       children: [
//         Icon(icon, color: color),
//         const SizedBox(width: 5),
//         Text(text, style: const TextStyle(color: Colors.white70)),
//       ],
//     );
//   }
// }
//
// class CommentSection extends StatelessWidget {
//   final List<Comment> comments;
//
//   const CommentSection({super.key, required this.comments});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Comments',
//           style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 10),
//         for (var comment in comments)
//           CommentWidget(
//             username: comment.username,
//             comment: comment.comment,
//             timeAgo: comment.timeAgo,
//             isOp: comment.isOp,
//           ),
//       ],
//     );
//   }
// }
//
// class CommentWidget extends StatelessWidget {
//   final String username;
//   final String comment;
//   final String timeAgo;
//   final bool isOp;
//
//   const CommentWidget({super.key, required this.username, required this.comment, required this.timeAgo, this.isOp = false});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const CircleAvatar(
//             backgroundColor: Colors.grey,
//             child: Icon(Icons.person, color: Colors.white),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Text(username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                     if (isOp)
//                       Container(
//                         margin: const EdgeInsets.only(left: 8),
//                         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                         decoration: BoxDecoration(
//                           color: Colors.blue,
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         child: const Text('OP', style: TextStyle(color: Colors.white, fontSize: 10)),
//                       ),
//                   ],
//                 ),
//                 Text(comment, style: const TextStyle(color: Colors.white70)),
//                 const SizedBox(height: 4),
//                 Text(timeAgo, style: const TextStyle(color: Colors.grey, fontSize: 12)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
