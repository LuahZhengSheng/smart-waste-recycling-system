// import 'package:flutter/material.dart';
// import 'package:fyp/features/community/controllers/posts/my_post_controller.dart';
// import 'package:fyp/features/community/models/post_enums.dart';
// import 'package:fyp/features/community/models/post_model.dart';
// import 'package:fyp/features/community/screens/view_post/post_detail.dart';
// import 'package:fyp/features/community/screens/view_post/widgets/post_action.dart';
// import 'package:fyp/features/community/screens/view_post/widgets/post_media.dart';
// import 'package:fyp/utils/constants/colors.dart';
// import 'package:fyp/utils/constants/sizes.dart';
// import 'package:fyp/utils/helpers/helper_functions.dart';
// import 'package:get/get.dart';
// import 'package:iconsax/iconsax.dart';
//
// import '../../../../../utils/formatters/formatter.dart';
// import '../../common_post_widgets/common_post_widgets.dart';
//
// class FMyPostCard extends StatelessWidget {
//   final PostModel post;
//
//   const FMyPostCard({
//     super.key,
//     required this.post,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<MyPostsController>();
//     final currentUserId = controller.getCurrentUserId();
//     final dark = FHelperFunctions.isDarkMode(context);
//     final postType = PostType.fromString(post.postType);
//
//     return GestureDetector(
//       onTap: post.isDisabled
//           ? null
//           : () {
//               Get.to(() => PostDetailsScreen(postId: post.postId));
//             },
//       child: Container(
//         padding: const EdgeInsets.all(FSizes.md),
//         margin: const EdgeInsets.only(bottom: FSizes.spaceBtwItems),
//         decoration: BoxDecoration(
//           color: post.isDisabled
//               ? (dark
//                   ? FColors.communityDarkSurface.withOpacity(0.5)
//                   : FColors.grey.withOpacity(0.15))
//               : (dark ? FColors.communityDarkSurface : FColors.white),
//           borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
//           border: Border.all(
//             color: post.isDisabled
//                 ? FColors.error.withOpacity(0.3)
//                 : (dark
//                     ? FColors.communityDarkBorder
//                     : FColors.grey.withOpacity(0.2)),
//             width: post.isDisabled ? 1.5 : 1,
//           ),
//           boxShadow: post.isDisabled
//               ? null
//               : dark
//                   ? null
//                   : [
//                       BoxShadow(
//                         color: FColors.grey.withOpacity(0.1),
//                         spreadRadius: 1,
//                         blurRadius: 5,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // User Info & Status Badge
//             Row(
//               children: [
//                 Expanded(
//                   child: Opacity(
//                     opacity: post.isDisabled ? 0.6 : 1.0,
//                     child: FUserInfo(
//                       userId: post.userId,
//                       timeAgo: FFormatter.formatTimeAgo(post.createdAt),
//                       postType: postType,
//                     ),
//                   ),
//                 ),
//                 // Violated Badge
//                 if (post.isDisabled)
//                   _buildViolatedBadge(context)
//                 else
//                   FMenuButton(
//                     onPressed: () => _showPostOptions(context, post, dark),
//                   ),
//               ],
//             ),
//             const SizedBox(height: FSizes.spaceBtwItems),
//
//             // Post Content
//             Opacity(
//               opacity: post.isDisabled ? 0.6 : 1.0,
//               child: Text(
//                 post.content,
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                       height: 1.4,
//                       color: dark ? FColors.darkText : FColors.black,
//                     ),
//               ),
//             ),
//
//             // Post Media
//             if (post.media.isNotEmpty) ...[
//               const SizedBox(height: FSizes.spaceBtwItems),
//               Opacity(
//                 opacity: post.isDisabled ? 0.6 : 1.0,
//                 child: FPostMedia(mediaUrls: post.media),
//               ),
//             ],
//
//             const SizedBox(height: FSizes.spaceBtwItems),
//
//             // Violated Notice or Action Buttons
//             if (post.isDisabled)
//               _buildViolatedNotice(context, dark)
//             else
//               Row(
//                 children: [
//                   const Spacer(),
//                   Obx(() {
//                     final currentPost = controller.myPosts.firstWhere(
//                       (p) => p.postId == post.postId,
//                       orElse: () => post,
//                     );
//                     final isLiked = currentPost.likes.contains(currentUserId);
//
//                     return FPostActions(
//                       post: currentPost,
//                       isLiked: isLiked,
//                       onLikePressed: () => controller.toggleLike(post.postId),
//                       onCommentPressed: () =>
//                           Get.to(() => PostDetailsScreen(postId: post.postId)),
//                     );
//                   }),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildViolatedBadge(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 12,
//         vertical: 6,
//       ),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             FColors.error,
//             FColors.error.withOpacity(0.8),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: FColors.error.withOpacity(0.3),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Icon(
//             Iconsax.warning_25,
//             color: FColors.white,
//             size: 14,
//           ),
//           const SizedBox(width: 6),
//           Text(
//             'VIOLATED',
//             style: Theme.of(context).textTheme.labelSmall?.copyWith(
//                   color: FColors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 11,
//                   letterSpacing: 0.5,
//                 ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildViolatedNotice(BuildContext context, bool dark) {
//     return Container(
//       padding: const EdgeInsets.all(FSizes.md),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             FColors.error.withOpacity(0.08),
//             FColors.error.withOpacity(0.05),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: FColors.error.withOpacity(0.2),
//           width: 1,
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: FColors.error.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: const Icon(
//               Iconsax.info_circle5,
//               size: 20,
//               color: FColors.error,
//             ),
//           ),
//           const SizedBox(width: FSizes.sm),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Community Guidelines Violation',
//                   style: Theme.of(context).textTheme.labelMedium?.copyWith(
//                         color: FColors.error,
//                         fontWeight: FontWeight.w600,
//                         fontSize: 13,
//                       ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   'This post has been disabled for violating our community standards',
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                         color: dark
//                             ? FColors.darkTextSecondary
//                             : FColors.textSecondary,
//                         fontSize: 12,
//                         height: 1.3,
//                       ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showPostOptions(BuildContext context, PostModel post, bool dark) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) => Container(
//         decoration: BoxDecoration(
//           color: dark ? FColors.communityDarkSurface : FColors.white,
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//         ),
//         padding: const EdgeInsets.symmetric(vertical: 24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Edit Option
//             _buildOption(
//               context: context,
//               icon: Iconsax.edit,
//               iconColor: FColors.primary,
//               title: 'Edit Post',
//               dark: dark,
//               onTap: () {
//                 Get.back();
//                 Get.toNamed('/create-post', arguments: post);
//               },
//             ),
//
//             // Delete Option
//             _buildOption(
//               context: context,
//               icon: Iconsax.trash,
//               iconColor: FColors.error,
//               title: 'Delete Post',
//               titleColor: FColors.error,
//               dark: dark,
//               onTap: () {
//                 Get.back();
//                 _showDeleteConfirmation(context, post, dark);
//               },
//             ),
//
//             const SizedBox(height: 12),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildOption({
//     required BuildContext context,
//     required IconData icon,
//     required Color iconColor,
//     required String title,
//     Color? titleColor,
//     required bool dark,
//     required VoidCallback onTap,
//   }) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         child: Container(
//           padding: const EdgeInsets.symmetric(
//             horizontal: FSizes.defaultSpace,
//             vertical: 16,
//           ),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: iconColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(
//                   icon,
//                   color: iconColor,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Text(
//                   title,
//                   style: TextStyle(
//                     color: titleColor ?? (dark ? FColors.white : FColors.black),
//                     fontSize: 15,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//               Icon(
//                 Iconsax.arrow_right_3,
//                 color: titleColor?.withOpacity(0.5) ??
//                     (dark ? FColors.darkTextSecondary : FColors.grey),
//                 size: 20,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _showDeleteConfirmation(
//       BuildContext context, PostModel post, bool dark) {
//     Get.dialog(
//       AlertDialog(
//         backgroundColor: dark ? FColors.communityDarkSurface : FColors.white,
//         surfaceTintColor: Colors.transparent,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         title: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: FColors.error.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Icon(
//                 Iconsax.trash,
//                 color: FColors.error,
//                 size: 24,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Text(
//               'Delete Post',
//               style: TextStyle(
//                 color: dark ? FColors.white : FColors.black,
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         content: Text(
//           'Are you sure you want to delete this post? This action cannot be undone.',
//           style: TextStyle(
//             color: dark ? FColors.darkTextSecondary : FColors.grey,
//             fontSize: 15,
//             height: 1.4,
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             style: TextButton.styleFrom(
//               foregroundColor:
//                   dark ? FColors.darkTextSecondary : FColors.grey,
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             ),
//             child: Text(
//               'Cancel',
//               style: TextStyle(
//                 color: dark ? FColors.darkTextSecondary : FColors.grey,
//                 fontSize: 15,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   FColors.error,
//                   FColors.error.withOpacity(0.8),
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: FColors.error.withOpacity(0.3),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: TextButton(
//               onPressed: () {
//                 Get.back();
//                 Get.find<MyPostsController>().deletePost(post.postId);
//               },
//               style: TextButton.styleFrom(
//                 foregroundColor: FColors.white,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: const Text(
//                 'Delete',
//                 style: TextStyle(
//                   color: FColors.white,
//                   fontSize: 15,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//         ],
//         actionsAlignment: MainAxisAlignment.spaceBetween,
//         contentPadding: const EdgeInsets.fromLTRB(FSizes.defaultSpace,
//             FSizes.sm, FSizes.defaultSpace, FSizes.defaultSpace),
//         titlePadding: const EdgeInsets.all(FSizes.defaultSpace),
//       ),
//       barrierDismissible: true,
//     );
//   }
// }
