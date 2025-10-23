// import 'package:flutter/material.dart';
// import 'package:fyp/common/widgets/appbar/appbar.dart';
// import 'package:fyp/features/community/controllers/posts/create_post_controller.dart';
// import 'package:fyp/features/community/screens/posts/widgets/upload_media.dart';
// import 'package:fyp/utils/constants/colors.dart';
// import 'package:fyp/utils/constants/sizes.dart';
// import 'package:get/get.dart';
//
// class CreatePostScreen extends StatelessWidget {
//   CreatePostScreen({super.key});
//
//   final CreatePostController controller = Get.put(CreatePostController());
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: FAppBar(
//         title: Text('Create Post', style: Theme.of(context).textTheme.headlineMedium),
//         showBackArrow: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(FSizes.defaultSpace),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // **标题输入框 (最多 50 个字符)**
//             TextField(
//               onChanged: (value) {
//                 if (value.length <= 50) {
//                   controller.title.value = value;
//                 }
//               },
//               maxLength: 50, // 限制最大字符数
//               style: const TextStyle(color: Colors.white),
//               decoration: inputDecoration("Enter community title..."),
//             ),
//             const SizedBox(height: 10),
//
//             // **内容输入框 (最多 300 个字符)**
//             TextField(
//               onChanged: (value) {
//                 if (value.length <= 300) {
//                   controller.content.value = value;
//                 }
//               },
//               maxLength: 300, // 限制最大字符数
//               maxLines: 5,
//               style: const TextStyle(color: Colors.white),
//               decoration: inputDecoration("Enter community content..."),
//             ),
//             const SizedBox(height: 10),
//
//             // **上传图片 / 视频组件**
//             UploadMedia(controller: controller),
//
//             const Spacer(),
//
//             // **提交按钮**
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: controller.submitPost,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blueAccent,
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                 ),
//                 child: const Text("Post", style: TextStyle(fontSize: 16, color: Colors.white)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // **通用输入框样式**
//   InputDecoration inputDecoration(String hintText) {
//     return InputDecoration(
//       hintText: hintText,
//       hintStyle: const TextStyle(color: Colors.white70),
//       filled: true,
//       fillColor: Colors.grey[900],
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide.none,
//       ),
//     );
//   }
// }
//
//
