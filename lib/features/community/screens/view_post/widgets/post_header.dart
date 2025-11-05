// import 'package:flutter/material.dart';
// import 'package:fyp/features/community/controllers/posts/post_controller.dart';
// import 'package:fyp/utils/constants/sizes.dart';
// import 'package:get/get.dart';
// import 'package:iconsax/iconsax.dart';
//
// import '../../create_post/create_post.dart';
// import '../../my_post/my_post.dart';
//
// class FPostsHeader extends StatelessWidget {
//   const FPostsHeader({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<PostsController>();
//
//     return Container(
//       padding: const EdgeInsets.all(FSizes.md),
//       child: Column(
//         children: [
//           FCustomButton(
//             text: 'My Post',
//             backgroundColor: const Color(0xFF4CAF50),
//             textColor: Colors.white,
//             onPressed: () {
//               Get.to(() => const MyPostsScreen());
//             },
//           ),
//           const SizedBox(height: FSizes.spaceBtwItems),
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(FSizes.md),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[200],
//                   borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
//                 ),
//                 child: GestureDetector(
//                   onTap: () {
//                     Get.to(() => const CreatePostScreen());
//                   },
//                   child: Text(
//                     "What's on your mind?",
//                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(width: FSizes.spaceBtwItems),
//
//               // Filter icon button
//               IconButton(
//                 onPressed: () => _showFilterBottomSheet(context),
//                 icon: Obx(() => Icon(
//                   Iconsax.filter,
//                   color: controller.selectedFilter.value != 'All'
//                       ? const Color(0xFF4CAF50)
//                       : Colors.grey[600],
//                 )),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Show filter bottom sheet
//   void _showFilterBottomSheet(BuildContext context) {
//     final controller = Get.find<PostsController>();
//
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(FSizes.borderRadiusLg)),
//       ),
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(FSizes.defaultSpace),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Filter Posts',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: FSizes.spaceBtwItems),
//
//             // Filter options
//             Obx(() => Column(
//               children: [
//                 _buildFilterOption('All', controller),
//                 _buildFilterOption('Tips', controller),
//                 _buildFilterOption('Question', controller),
//                 _buildFilterOption('Discussion', controller),
//               ],
//             )),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Build individual filter option
//   Widget _buildFilterOption(String filter, PostsController controller) {
//     final isSelected = controller.selectedFilter.value == filter;
//
//     return ListTile(
//       leading: Icon(
//         _getFilterIcon(filter),
//         color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[600],
//       ),
//       title: Text(
//         filter,
//         style: TextStyle(
//           color: isSelected ? const Color(0xFF4CAF50) : Colors.black87,
//           fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//         ),
//       ),
//       trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF4CAF50)) : null,
//       onTap: () {
//         controller.setFilter(filter);
//         Get.back();
//       },
//     );
//   }
//
//   // Get icon for filter type
//   IconData _getFilterIcon(String filter) {
//     switch (filter) {
//       case 'Tips':
//         return Iconsax.lamp;
//       case 'Question':
//         return Iconsax.message_question;
//       case 'Discussion':
//         return Iconsax.message_text;
//       default:
//         return Iconsax.category;
//     }
//   }
// }