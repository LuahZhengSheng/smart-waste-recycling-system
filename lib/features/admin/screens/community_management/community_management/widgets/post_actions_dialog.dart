import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/features/community/models/post_model.dart';
import 'package:fyp/features/admin/controllers/community_management/community_management_controller.dart';

// class DisablePostDialog extends StatelessWidget {
//   final PostModel post;
//
//   const DisablePostDialog({super.key, required this.post});
//
//   @override
//   Widget build(BuildContext context) {
//     final dark = FHelperFunctions.isDarkMode(context);
//
//     return AlertDialog(
//       backgroundColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
//       ),
//       title: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(FSizes.sm),
//             decoration: BoxDecoration(
//               color: (dark ? FColors.adminDarkError : FColors.adminLightError).withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Iconsax.close_circle,
//               color: dark ? FColors.adminDarkError : FColors.adminLightError,
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: FSizes.md),
//           Text(
//             'Disable Post',
//             style: TextStyle(
//               color: dark ? FColors.adminDarkText : FColors.adminLightText,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Are you sure you want to disable this post?',
//             style: TextStyle(
//               color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
//             ),
//           ),
//           const SizedBox(height: FSizes.md),
//           Container(
//             padding: const EdgeInsets.all(FSizes.md),
//             decoration: BoxDecoration(
//               color: dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
//               borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
//               border: Border.all(
//                 color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildInfoRow('Post ID:', post.postId, dark),
//                 const SizedBox(height: FSizes.xs),
//                 _buildInfoRow('Type:', post.postType.toUpperCase(), dark),
//                 const SizedBox(height: FSizes.xs),
//                 _buildInfoRow(
//                   'Content:',
//                   post.content.length > 50
//                       ? '${post.content.substring(0, 50)}...'
//                       : post.content,
//                   dark,
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: FSizes.md),
//           Container(
//             padding: const EdgeInsets.all(FSizes.md),
//             decoration: BoxDecoration(
//               color: (dark ? FColors.adminDarkError : FColors.adminLightError).withOpacity(0.1),
//               borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
//               border: Border.all(
//                 color: dark ? FColors.adminDarkError : FColors.adminLightError,
//               ),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   Iconsax.warning_2,
//                   color: dark ? FColors.adminDarkError : FColors.adminLightError,
//                   size: 20,
//                 ),
//                 const SizedBox(width: FSizes.sm),
//                 Expanded(
//                   child: Text(
//                     'This post will be hidden from users and marked as disabled.',
//                     style: TextStyle(
//                       color: dark ? FColors.adminDarkError : FColors.adminLightError,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Get.back(),
//           child: Text(
//             'Cancel',
//             style: TextStyle(
//               color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
//             ),
//           ),
//         ),
//         ElevatedButton(
//           onPressed: () async {
//             Get.back();
//             final controller = CommunityManagementController.instance;
//             await controller.togglePostStatus(post);
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: dark ? FColors.adminDarkError : FColors.adminLightError,
//             padding: const EdgeInsets.symmetric(horizontal: FSizes.lg, vertical: FSizes.md),
//           ),
//           child: const Text('Disable Post', style: TextStyle(color: Colors.white)),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildInfoRow(String label, String value, bool dark) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontWeight: FontWeight.w600,
//             color: dark ? FColors.adminDarkText : FColors.adminLightText,
//             fontSize: 13,
//           ),
//         ),
//         const SizedBox(width: FSizes.xs),
//         Expanded(
//           child: Text(
//             value,
//             style: TextStyle(
//               color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
//               fontSize: 13,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class RecoverPostDialog extends StatelessWidget {
//   final PostModel post;
//
//   const RecoverPostDialog({super.key, required this.post});
//
//   @override
//   Widget build(BuildContext context) {
//     final dark = FHelperFunctions.isDarkMode(context);
//
//     return AlertDialog(
//       backgroundColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
//       ),
//       title: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(FSizes.sm),
//             decoration: BoxDecoration(
//               color: (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess).withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Iconsax.refresh,
//               color: dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess,
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: FSizes.md),
//           Text(
//             'Recover Post',
//             style: TextStyle(
//               color: dark ? FColors.adminDarkText : FColors.adminLightText,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Are you sure you want to recover this post?',
//             style: TextStyle(
//               color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
//             ),
//           ),
//           const SizedBox(height: FSizes.md),
//           Container(
//             padding: const EdgeInsets.all(FSizes.md),
//             decoration: BoxDecoration(
//               color: dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
//               borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
//               border: Border.all(
//                 color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildInfoRow('Post ID:', post.postId, dark),
//                 const SizedBox(height: FSizes.xs),
//                 _buildInfoRow('Type:', post.postType.toUpperCase(), dark),
//                 const SizedBox(height: FSizes.xs),
//                 _buildInfoRow(
//                   'Content:',
//                   post.content.length > 50
//                       ? '${post.content.substring(0, 50)}...'
//                       : post.content,
//                   dark,
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: FSizes.md),
//           Container(
//             padding: const EdgeInsets.all(FSizes.md),
//             decoration: BoxDecoration(
//               color: (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess).withOpacity(0.1),
//               borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
//               border: Border.all(
//                 color: dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess,
//               ),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   Iconsax.tick_circle,
//                   color: dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess,
//                   size: 20,
//                 ),
//                 const SizedBox(width: FSizes.sm),
//                 Expanded(
//                   child: Text(
//                     'This post will be visible to users again.',
//                     style: TextStyle(
//                       color: dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Get.back(),
//           child: Text(
//             'Cancel',
//             style: TextStyle(
//               color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
//             ),
//           ),
//         ),
//         ElevatedButton(
//           onPressed: () async {
//             Get.back();
//             final controller = CommunityManagementController.instance;
//             await controller.togglePostStatus(post);
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess,
//             padding: const EdgeInsets.symmetric(horizontal: FSizes.lg, vertical: FSizes.md),
//           ),
//           child: const Text('Recover Post', style: TextStyle(color: Colors.white)),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildInfoRow(String label, String value, bool dark) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontWeight: FontWeight.w600,
//             color: dark ? FColors.adminDarkText : FColors.adminLightText,
//             fontSize: 13,
//           ),
//         ),
//         const SizedBox(width: FSizes.xs),
//         Expanded(
//           child: Text(
//             value,
//             style: TextStyle(
//               color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
//               fontSize: 13,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }