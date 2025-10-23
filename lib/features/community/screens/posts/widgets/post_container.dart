// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:fyp/features/community/models/post_model.dart';
//
// class PostContainer extends StatelessWidget {
//   final Post community;
//
//   const PostContainer({
//     Key key,
//     @required this.community,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(
//         vertical: 5.0,
//         horizontal: 0.0,
//       ),
//       elevation: 0.0,
//       shape: null,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         color: Colors.white,
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   _PostHeader(community: community),
//                   const SizedBox(height: 4.0),
//                   Text(community.caption),
//                   community.imageUrl != null
//                       ? const SizedBox.shrink()
//                       : const SizedBox(height: 6.0),
//                 ],
//               ),
//             ),
//             community.imageUrl != null
//                 ? Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8.0),
//               child: CachedNetworkImage(imageUrl: community.imageUrl),
//             )
//                 : const SizedBox.shrink(),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12.0),
//               child: _PostStats(community: community),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _PostHeader extends StatelessWidget {
//   final Post community;
//
//   const _PostHeader({
//     required Key key,
//     required this.community,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         ProfileAvatar(imageUrl: community.user.imageUrl),
//         const SizedBox(width: 8.0),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 community.user.name,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               Row(
//                 children: [
//                   Text(
//                     '${community.timeAgo} • ',
//                     style: TextStyle(
//                       color: Colors.grey[600],
//                       fontSize: 12.0,
//                     ),
//                   ),
//                   Icon(
//                     Icons.public,
//                     color: Colors.grey[600],
//                     size: 12.0,
//                   )
//                 ],
//               ),
//             ],
//           ),
//         ),
//         IconButton(
//           icon: const Icon(Icons.more_horiz),
//           onPressed: () => print('More'),
//         ),
//       ],
//     );
//   }
// }
//
// class _PostStats extends StatelessWidget {
//   final Post community;
//
//   const _PostStats({
//     Key key,
//     @required this.community,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(4.0),
//               decoration: BoxDecoration(
//                 color: Palette.facebookBlue,
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.thumb_up,
//                 size: 10.0,
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(width: 4.0),
//             Expanded(
//               child: Text(
//                 '${community.likes}',
//                 style: TextStyle(
//                   color: Colors.grey[600],
//                 ),
//               ),
//             ),
//             Text(
//               '${community.comments} Comments',
//               style: TextStyle(
//                 color: Colors.grey[600],
//               ),
//             ),
//             const SizedBox(width: 8.0),
//             Text(
//               '${community.shares} Shares',
//               style: TextStyle(
//                 color: Colors.grey[600],
//               ),
//             )
//           ],
//         ),
//         const Divider(),
//         Row(
//           children: [
//             _PostButton(
//               icon: Icon(
//                 MdiIcons.thumbUpOutline,
//                 color: Colors.grey[600],
//                 size: 20.0,
//               ),
//               label: 'Like',
//               onTap: () => print('Like'),
//             ),
//             _PostButton(
//               icon: Icon(
//                 MdiIcons.commentOutline,
//                 color: Colors.grey[600],
//                 size: 20.0,
//               ),
//               label: 'Comment',
//               onTap: () => print('Comment'),
//             ),
//             _PostButton(
//               icon: Icon(
//                 MdiIcons.shareOutline,
//                 color: Colors.grey[600],
//                 size: 25.0,
//               ),
//               label: 'Share',
//               onTap: () => print('Share'),
//             )
//           ],
//         ),
//       ],
//     );
//   }
// }
//
// class _PostButton extends StatelessWidget {
//   final Icon icon;
//   final String label;
//   final Function onTap;
//
//   const _PostButton({
//     required Key key,
//     required this.icon,
//     required this.label,
//     required this.onTap,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Material(
//         color: Colors.white,
//         child: InkWell(
//           onTap: onTap,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12.0),
//             height: 25.0,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 icon,
//                 const SizedBox(width: 4.0),
//                 Text(label),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }