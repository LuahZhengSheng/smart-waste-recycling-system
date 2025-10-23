// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:fyp/common/widgets/appbar/appbar.dart';
// import 'package:fyp/features/community/models/post_model.dart';
// import 'package:fyp/features/community/screens/posts/create_post_screen.dart';
// import 'package:fyp/features/community/screens/posts/widgets/post_card.dart';
// import 'package:fyp/utils/constants/colors.dart';
// import 'package:fyp/utils/constants/image_strings.dart';
// import 'package:fyp/utils/constants/sizes.dart';
// import 'package:get/get.dart';
//
// class PostListScreen extends StatelessWidget {
//   final List<Post> posts = [
//     Post(
//       user: FirebaseAuth.instance.currentUser!,
//       title: 'MYSTERY Food Machine Contest 🏆',
//       caption: 'Attention inventors! We\'re planning on hosting an excellent week-long machine contest...',
//       timeAgo: '1d ago',
//       imageUrl: FImages.user,
//       likes: 17,
//       comments: 89,
//       shares: 10,
//     ),
//     Post(
//       user: FirebaseAuth.instance.currentUser!,
//       title: 'Crying over Spilled Milk',
//       caption: 'Does anyone have any tips on doing a liquid transfer without spilling? I\'ve done 13 tries but can’t seem to get...',
//       timeAgo: '2d ago',
//       likes: 32,
//       comments: 8,
//       shares: 5,
//     ),
//   ];
//
//   PostListScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black87,
//       appBar: FAppBar(title: Text('Posts', style: Theme.of(context).textTheme.headlineMedium!.apply(color: FColors.primary)), showBackArrow: false),
//       body: Column(
//         children: [
//           const SearchBar(),
//           const NewPostButton(),
//           const SizedBox(height: FSizes.spaceBtwSections),
//           Expanded(
//             child: ListView.builder(
//               itemCount: posts.length,
//               itemBuilder: (context, index) {
//                 return PostCard(community: posts[index]);
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// /// **搜索框**
// class SearchBar extends StatelessWidget {
//   const SearchBar({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       decoration: InputDecoration(
//         hintText: 'Search or create a community...',
//         hintStyle: const TextStyle(color: Colors.white70),
//         prefixIcon: const Icon(Icons.search, color: Colors.white70),
//         filled: true,
//         fillColor: Colors.grey[900],
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(30),
//           borderSide: BorderSide.none,
//         ),
//       ),
//       style: const TextStyle(color: Colors.white),
//     );
//   }
// }
//
// /// **新帖按钮**
// class NewPostButton extends StatelessWidget {
//   const NewPostButton({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(right: 16.0),
//       child: ElevatedButton(
//         onPressed: () => Get.to(CreatePostScreen()),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.blueAccent,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         ),
//         child: const Text('New Post'),
//       ),
//     );
//   }
// }
