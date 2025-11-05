// import 'package:flutter/material.dart';
// import 'package:fyp/features/community/controllers/posts/comment_controller.dart';
// import 'package:fyp/features/community/controllers/posts/reply_controller.dart';
// import 'package:fyp/features/community/models/reply_model.dart';
// import 'package:fyp/utils/constants/colors.dart';
// import 'package:fyp/utils/constants/sizes.dart';
// import 'package:fyp/utils/helpers/helper_functions.dart';
// import 'package:get/get.dart';
// import 'package:iconsax/iconsax.dart';
// import '../../../../../utils/formatters/formatter.dart';
// import '../../../../../utils/popups/loaders.dart';
//
// class FReplyCard extends StatelessWidget {
//   final Reply reply;
//
//   const FReplyCard({super.key, required this.reply});
//
//   @override
//   Widget build(BuildContext context) {
//     final commentController = Get.find<CommentController>();
//     final repliesController = Get.find<ReplyController>();
//     final dark = FHelperFunctions.isDarkMode(context);
//
//     return GestureDetector(
//       onLongPress: () => _showReplyContextMenu(context, commentController, repliesController, dark),
//       child: Container(
//         color: dark ? FColors.communityDarkBackground : FColors.white,
//         margin: const EdgeInsets.only(left: FSizes.lg),
//         padding: const EdgeInsets.symmetric(
//           horizontal: FSizes.md,
//           vertical: FSizes.sm,
//         ),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // User avatar - 使用缓存而不是 StreamBuilder
//             _buildUserAvatar(dark, commentController),
//             const SizedBox(width: FSizes.md),
//
//             // Reply content
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // User name and time - 使用缓存而不是 StreamBuilder
//                   _buildUserInfo(context, dark, commentController),
//                   const SizedBox(height: FSizes.md),
//
//                   // Reply content
//                   Text(
//                     reply.content,
//                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                       height: 1.3,
//                       color: dark ? FColors.communityDarkText : FColors.textPrimary,
//                     ),
//                   ),
//                   const SizedBox(height: FSizes.md),
//
//                   // Like button
//                   Row(
//                     children: [
//                       GestureDetector(
//                         onTap: () => repliesController.toggleReplyLike(reply.replyId),
//                         child: Row(
//                           children: [
//                             Obx(() {
//                               final currentUserId = commentController.getCurrentUserId();
//                               final currentReply = repliesController.replies.firstWhere(
//                                     (r) => r.replyId == reply.replyId,
//                                 orElse: () => reply,
//                               );
//                               final isLiked = currentReply.likes.contains(currentUserId);
//
//                               return Icon(
//                                 isLiked ? Iconsax.like_15 : Iconsax.like_1,
//                                 size: 16,
//                                 color: isLiked
//                                     ? FColors.primary
//                                     : (dark ? FColors.communityDarkTextSecondary : FColors.textSecondary),
//                               );
//                             }),
//                             const SizedBox(width: 4),
//                             Obx(() {
//                               final currentReply = repliesController.replies.firstWhere(
//                                     (r) => r.replyId == reply.replyId,
//                                 orElse: () => reply,
//                               );
//                               if (currentReply.likes.isEmpty) {
//                                 return const SizedBox.shrink();
//                               }
//                               return Text(
//                                 currentReply.likes.length.toString(),
//                                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                                   color: dark ? FColors.communityDarkTextSecondary : FColors.textSecondary,
//                                 ),
//                               );
//                             }),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildUserAvatar(bool dark, CommentController commentController) {
//     // 检查用户数据是否正在加载
//     if (commentController.isUserLoading(reply.userId)) {
//       return _buildLoadingAvatar(dark);
//     }
//
//     final profileImg = commentController.getProfileImage(reply.userId);
//
//     if (profileImg.isNotEmpty) {
//       return CircleAvatar(
//         radius: 14,
//         backgroundImage: NetworkImage(profileImg),
//         backgroundColor: Colors.transparent,
//         onBackgroundImageError: (exception, stackTrace) {
//           debugPrint('Failed to load profile image: $exception');
//         },
//       );
//     }
//
//     return _buildDefaultAvatar(dark);
//   }
//
//   Widget _buildLoadingAvatar(bool dark) {
//     return CircleAvatar(
//       radius: 14,
//       backgroundColor: dark ? FColors.darkGrey : FColors.grey.withOpacity(0.3),
//       child: SizedBox(
//         width: 14,
//         height: 14,
//         child: CircularProgressIndicator(
//           strokeWidth: 2,
//           color: dark ? FColors.white : FColors.darkGrey,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildUserInfo(BuildContext context, bool dark, CommentController commentController) {
//     final username = commentController.getUsername(reply.userId);
//
//     return Row(
//       children: [
//         // 显示加载状态
//         if (commentController.isUserLoading(reply.userId)) ...[
//           SizedBox(
//             width: 60,
//             height: 14,
//             child: LinearProgressIndicator(
//               backgroundColor: dark ? FColors.darkGrey : FColors.grey.withOpacity(0.3),
//               color: FColors.primary,
//             ),
//           ),
//           const SizedBox(width: FSizes.md),
//         ] else ...[
//           Text(
//             username,
//             style: Theme.of(context).textTheme.labelMedium?.copyWith(
//               fontWeight: FontWeight.bold,
//               color: dark ? FColors.communityDarkText : FColors.textPrimary,
//             ),
//           ),
//           const SizedBox(width: FSizes.md),
//         ],
//
//         Text(
//           FFormatter.formatTimeAgo(reply.createdAt),
//           style: Theme.of(context).textTheme.bodySmall?.copyWith(
//             color: dark ? FColors.communityDarkTextSecondary : FColors.textSecondary,
//           ),
//         ),
//         // Edited indicator
//         if (reply.updatedAt.isAfter(reply.createdAt.add(const Duration(minutes: 1)))) ...[
//           const SizedBox(width: FSizes.xs),
//           Text(
//             '(edited)',
//             style: Theme.of(context).textTheme.bodySmall?.copyWith(
//               color: dark ? FColors.communityDarkTextSecondary : FColors.textSecondary,
//               fontStyle: FontStyle.italic,
//             ),
//           ),
//         ],
//       ],
//     );
//   }
//
//   Widget _buildDefaultAvatar(bool dark) {
//     return CircleAvatar(
//       radius: 16,
//       backgroundColor: dark ? FColors.darkGrey : FColors.grey.withOpacity(0.3),
//       child: Icon(
//         Icons.person,
//         size: 16,
//         color: dark ? FColors.white : FColors.darkGrey,
//       ),
//     );
//   }
//
//   void _showReplyContextMenu(BuildContext context, CommentController commentController, ReplyController repliesController, bool dark) {
//     final canModify = repliesController.canModifyReply(reply);
//
//     FLoaders.showBottomSheet(
//       Container(
//         padding: const EdgeInsets.all(FSizes.defaultSpace),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Copy text option
//             ListTile(
//               leading: Icon(
//                 Iconsax.copy,
//                 color: dark ? FColors.communityDarkText : FColors.textPrimary,
//               ),
//               title: Text(
//                 'Copy Text',
//                 style: TextStyle(
//                   color: dark ? FColors.communityDarkText : FColors.textPrimary,
//                 ),
//               ),
//               onTap: () {
//                 Get.back();
//                 repliesController.copyReplyText(reply.content);
//               },
//             ),
//
//             // Owner-only options
//             if (canModify) ...[
//               ListTile(
//                 leading: Icon(
//                   Iconsax.edit_2,
//                   color: dark ? FColors.communityDarkText : FColors.textPrimary,
//                 ),
//                 title: Text(
//                   'Edit Reply',
//                   style: TextStyle(
//                     color: dark ? FColors.communityDarkText : FColors.textPrimary,
//                   ),
//                 ),
//                 onTap: () {
//                   Get.back();
//                   _showEditReplyDialog(context, repliesController, dark);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Iconsax.trash, color: FColors.error),
//                 title: const Text('Delete Reply', style: TextStyle(color: FColors.error)),
//                 onTap: () {
//                   Get.back();
//                   repliesController.deleteReply(reply.replyId);
//                 },
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showEditReplyDialog(BuildContext context, ReplyController controller, bool dark) {
//     final editController = TextEditingController(text: reply.content);
//
//     Get.dialog(
//       AlertDialog(
//         backgroundColor: dark ? FColors.communityDarkSurface : FColors.white,
//         title: Text(
//           'Edit Reply',
//           style: TextStyle(
//             color: dark ? FColors.white : FColors.textPrimary,
//           ),
//         ),
//         content: TextField(
//           controller: editController,
//           maxLines: null,
//           autofocus: true,
//           style: TextStyle(
//             color: dark ? FColors.communityDarkText : FColors.textPrimary,
//           ),
//           decoration: InputDecoration(
//             hintText: 'Edit your reply...',
//             hintStyle: TextStyle(
//               color: dark ? FColors.communityDarkTextSecondary : FColors.textSecondary,
//             ),
//             border: OutlineInputBorder(
//               borderSide: BorderSide(
//                 color: dark ? FColors.communityDarkBorder : FColors.borderPrimary,
//               ),
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: Text(
//               'Cancel',
//               style: TextStyle(
//                 color: dark ? FColors.communityDarkTextSecondary : FColors.textSecondary,
//               ),
//             ),
//           ),
//           TextButton(
//             onPressed: () {
//               final newContent = editController.text.trim();
//               if (newContent.isNotEmpty && newContent != reply.content) {
//                 controller.editReply(reply.replyId, newContent);
//                 Get.back();
//               } else {
//                 Get.back();
//               }
//             },
//             child: const Text('Save', style: TextStyle(color: FColors.primary)),
//           ),
//         ],
//       ),
//     );
//   }
// }