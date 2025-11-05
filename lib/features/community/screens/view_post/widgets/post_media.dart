// import 'package:flutter/material.dart';
// import 'package:fyp/utils/constants/sizes.dart';
// import 'package:video_player/video_player.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:fyp/utils/constants/colors.dart';
// import 'package:get/get.dart';
//
// // Post media grid widgets
// class FPostMedia extends StatefulWidget {
//   final List<String> mediaUrls;
//   final int maxDisplay;
//   final Function(int)? onTap;
//
//   const FPostMedia({
//     super.key,
//     required this.mediaUrls,
//     this.maxDisplay = 5,
//     this.onTap,
//   });
//
//   @override
//   State<FPostMedia> createState() => _FPostMediaState();
// }
//
// class _FPostMediaState extends State<FPostMedia> {
//   @override
//   Widget build(BuildContext context) {
//     final displayUrls = widget.mediaUrls.take(widget.maxDisplay).toList();
//     final remainingCount = widget.mediaUrls.length - widget.maxDisplay;
//
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         return Wrap(
//           spacing: 4,
//           runSpacing: 4,
//           children: List.generate(displayUrls.length, (index) {
//             final url = displayUrls[index];
//             final isLast = index == displayUrls.length - 1;
//             final showOverlay = remainingCount > 0 && isLast;
//             final isVideo = _isVideoUrl(url);
//
//             return GestureDetector(
//               onTap: () {
//                 if (widget.onTap != null) {
//                   widget.onTap!(index);
//                 } else if (isVideo) {
//                   // 如果是视频且没有自定义 onTap，直接打开视频播放器
//                   _openVideoPlayer(context, url);
//                 } else {
//                   // 如果是图片且没有自定义 onTap，打开图片查看器
//                   _openImageViewer(context, url, index);
//                 }
//               },
//               child: SizedBox(
//                 width: _getImageWidth(constraints.maxWidth, displayUrls.length, index),
//                 height: 120,
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
//                   child: Stack(
//                     fit: StackFit.expand,
//                     children: [
//                       // 图片或视频内容
//                       if (isVideo)
//                         _VideoThumbnailWidget(videoUrl: url)
//                       else
//                         Image.network(
//                           url,
//                           fit: BoxFit.cover,
//                           loadingBuilder: (context, child, loadingProgress) {
//                             if (loadingProgress == null) return child;
//                             return Container(
//                               color: Colors.grey[300],
//                               child: Center(
//                                 child: CircularProgressIndicator(
//                                   value: loadingProgress.expectedTotalBytes != null
//                                       ? loadingProgress.cumulativeBytesLoaded /
//                                       loadingProgress.expectedTotalBytes!
//                                       : null,
//                                 ),
//                               ),
//                             );
//                           },
//                           errorBuilder: (context, error, stackTrace) {
//                             print('Image load error: $error');
//                             return Container(
//                               color: Colors.grey[300],
//                               child: const Icon(Icons.error, color: Colors.red),
//                             );
//                           },
//                         ),
//
//                       // 视频播放图标
//                       if (isVideo)
//                         Container(
//                           color: Colors.black.withOpacity(0.3),
//                           child: const Center(
//                             child: Icon(
//                               Iconsax.play_circle,
//                               color: Colors.white,
//                               size: 32,
//                             ),
//                           ),
//                         ),
//
//                       // 剩余数量遮罩
//                       if (showOverlay)
//                         Container(
//                           color: Colors.black.withOpacity(0.6),
//                           child: Center(
//                             child: Text(
//                               '+$remainingCount',
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           }),
//         );
//       },
//     );
//   }
//
//   bool _isVideoUrl(String url) {
//     final lowerUrl = url.toLowerCase();
//     return lowerUrl.contains('.mp4') ||
//         lowerUrl.contains('.mov') ||
//         lowerUrl.contains('.avi') ||
//         lowerUrl.contains('.webm') ||
//         lowerUrl.contains('.mkv') ||
//         lowerUrl.contains('.flv');
//   }
//
//   void _openVideoPlayer(BuildContext context, String videoUrl) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => _VideoPlayerScreen(videoUrl: videoUrl),
//       ),
//     );
//   }
//
//   void _openImageViewer(BuildContext context, String imageUrl, int index) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => _ImageViewerScreen(
//           imageUrls: widget.mediaUrls.where((url) => !_isVideoUrl(url)).toList(),
//           initialIndex: index,
//         ),
//       ),
//     );
//   }
//
//   // Calculate media width based on total media and position
//   double _getImageWidth(double containerWidth, int totalMedia, int index) {
//     const spacing = 4.0;
//
//     if (totalMedia == 1) {
//       return containerWidth; // Single media takes full width
//     }
//
//     if (totalMedia == 2) {
//       return (containerWidth - spacing) / 2; // Two media split width equally
//     }
//
//     if (totalMedia >= 3) {
//       // First row: Single media (index 0) takes full width
//       if (index == 0) {
//         return containerWidth;
//       }
//       // Second row: Two media (index 1 and 2) split width equally
//       else {
//         return (containerWidth - spacing) / 2;
//       }
//     }
//
//     return (containerWidth - spacing) / 2; // Default case
//   }
// }
//
// // 视频缩略图组件
// class _VideoThumbnailWidget extends StatefulWidget {
//   final String videoUrl;
//
//   const _VideoThumbnailWidget({required this.videoUrl});
//
//   @override
//   State<_VideoThumbnailWidget> createState() => _VideoThumbnailWidgetState();
// }
//
// class _VideoThumbnailWidgetState extends State<_VideoThumbnailWidget> {
//   late VideoPlayerController _controller;
//   bool _isInitialized = false;
//   bool _hasError = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeVideo();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   void _initializeVideo() async {
//     try {
//       _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
//       await _controller.initialize();
//       if (mounted) {
//         setState(() {
//           _isInitialized = true;
//         });
//       }
//     } catch (e) {
//       print('Failed to initialize video: $e');
//       if (mounted) {
//         setState(() {
//           _hasError = true;
//         });
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_hasError) {
//       return Container(
//         color: Colors.grey[300],
//         child: const Center(
//           child: Icon(Icons.error_outline, color: Colors.red, size: 32),
//         ),
//       );
//     }
//
//     if (!_isInitialized) {
//       return Container(
//         color: Colors.grey[300],
//         child: const Center(
//           child: CircularProgressIndicator(
//             strokeWidth: 2,
//             color: FColors.primary,
//           ),
//         ),
//       );
//     }
//
//     return VideoPlayer(_controller);
//   }
// }
//
// // 视频播放器全屏页面
// class _VideoPlayerScreen extends StatefulWidget {
//   final String videoUrl;
//
//   const _VideoPlayerScreen({required this.videoUrl});
//
//   @override
//   State<_VideoPlayerScreen> createState() => _VideoPlayerScreenState();
// }
//
// class _VideoPlayerScreenState extends State<_VideoPlayerScreen> {
//   late VideoPlayerController _controller;
//   bool _isInitialized = false;
//   bool _hasError = false;
//   bool _isPlaying = false;
//   bool _showControls = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeVideo();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   void _initializeVideo() async {
//     try {
//       _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
//       await _controller.initialize();
//       _controller.addListener(_videoListener);
//       if (mounted) {
//         setState(() {
//           _isInitialized = true;
//         });
//       }
//     } catch (e) {
//       print('Failed to initialize video: $e');
//       if (mounted) {
//         setState(() {
//           _hasError = true;
//         });
//       }
//     }
//   }
//
//   void _videoListener() {
//     if (mounted) {
//       setState(() {
//         _isPlaying = _controller.value.isPlaying;
//       });
//     }
//   }
//
//   void _togglePlayPause() {
//     if (_controller.value.isPlaying) {
//       _controller.pause();
//     } else {
//       _controller.play();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           // Video Player
//           Center(
//             child: _hasError
//                 ? const Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.error_outline, color: Colors.red, size: 64),
//                 SizedBox(height: 16),
//                 Text(
//                   'Failed to load video',
//                   style: TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//               ],
//             )
//                 : !_isInitialized
//                 ? const CircularProgressIndicator(color: FColors.primary)
//                 : GestureDetector(
//               onTap: () {
//                 setState(() {
//                   _showControls = !_showControls;
//                 });
//               },
//               child: AspectRatio(
//                 aspectRatio: _controller.value.aspectRatio,
//                 child: VideoPlayer(_controller),
//               ),
//             ),
//           ),
//
//           // Controls Overlay
//           if (_isInitialized && _showControls)
//             GestureDetector(
//               onTap: () {
//                 setState(() {
//                   _showControls = false;
//                 });
//               },
//               child: Container(
//                 color: Colors.black.withOpacity(0.3),
//                 child: Center(
//                   child: IconButton(
//                     onPressed: _togglePlayPause,
//                     icon: Icon(
//                       _isPlaying ? Iconsax.pause_circle : Iconsax.play_circle,
//                       color: Colors.white,
//                       size: 64,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//
//           // Top Bar
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               padding: EdgeInsets.only(
//                 top: MediaQuery.of(context).padding.top,
//                 left: 8,
//                 right: 8,
//                 bottom: 8,
//               ),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Colors.black.withOpacity(0.7),
//                     Colors.transparent,
//                   ],
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   IconButton(
//                     onPressed: () => Navigator.pop(context),
//                     icon: const Icon(
//                       Icons.close,
//                       color: Colors.white,
//                       size: 28,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           // Bottom Controls
//           if (_isInitialized && _showControls)
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.bottomCenter,
//                     end: Alignment.topCenter,
//                     colors: [
//                       Colors.black.withOpacity(0.7),
//                       Colors.transparent,
//                     ],
//                   ),
//                 ),
//                 child: ValueListenableBuilder(
//                   valueListenable: _controller,
//                   builder: (context, VideoPlayerValue value, child) {
//                     return Row(
//                       children: [
//                         Text(
//                           _formatDuration(value.position),
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 12,
//                           ),
//                         ),
//                         Expanded(
//                           child: Slider(
//                             value: value.position.inMilliseconds.toDouble().clamp(
//                               0.0,
//                               value.duration.inMilliseconds.toDouble(),
//                             ),
//                             max: value.duration.inMilliseconds.toDouble(),
//                             onChanged: (newValue) {
//                               _controller.seekTo(
//                                 Duration(milliseconds: newValue.toInt()),
//                               );
//                             },
//                             activeColor: FColors.primary,
//                             inactiveColor: Colors.white.withOpacity(0.3),
//                           ),
//                         ),
//                         Text(
//                           _formatDuration(value.duration),
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final minutes = twoDigits(duration.inMinutes.remainder(60));
//     final seconds = twoDigits(duration.inSeconds.remainder(60));
//     return '$minutes:$seconds';
//   }
// }
//
// // 图片查看器页面
// class _ImageViewerScreen extends StatefulWidget {
//   final List<String> imageUrls;
//   final int initialIndex;
//
//   const _ImageViewerScreen({
//     required this.imageUrls,
//     required this.initialIndex,
//   });
//
//   @override
//   State<_ImageViewerScreen> createState() => _ImageViewerScreenState();
// }
//
// class _ImageViewerScreenState extends State<_ImageViewerScreen> {
//   late PageController _pageController;
//   late int _currentIndex;
//
//   @override
//   void initState() {
//     super.initState();
//     _currentIndex = widget.initialIndex;
//     _pageController = PageController(initialPage: widget.initialIndex);
//   }
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           // Image PageView
//           PageView.builder(
//             controller: _pageController,
//             onPageChanged: (index) {
//               setState(() {
//                 _currentIndex = index;
//               });
//             },
//             itemCount: widget.imageUrls.length,
//             itemBuilder: (context, index) {
//               return Center(
//                 child: InteractiveViewer(
//                   child: Image.network(
//                     widget.imageUrls[index],
//                     fit: BoxFit.contain,
//                     loadingBuilder: (context, child, loadingProgress) {
//                       if (loadingProgress == null) return child;
//                       return Center(
//                         child: CircularProgressIndicator(
//                           value: loadingProgress.expectedTotalBytes != null
//                               ? loadingProgress.cumulativeBytesLoaded /
//                               loadingProgress.expectedTotalBytes!
//                               : null,
//                           color: FColors.primary,
//                         ),
//                       );
//                     },
//                     errorBuilder: (context, error, stackTrace) {
//                       return const Center(
//                         child: Icon(Icons.error_outline, color: Colors.red, size: 64),
//                       );
//                     },
//                   ),
//                 ),
//               );
//             },
//           ),
//
//           // Top Bar
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               padding: EdgeInsets.only(
//                 top: MediaQuery.of(context).padding.top,
//                 left: 8,
//                 right: 8,
//                 bottom: 8,
//               ),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Colors.black.withOpacity(0.7),
//                     Colors.transparent,
//                   ],
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   IconButton(
//                     onPressed: () => Navigator.pop(context),
//                     icon: const Icon(
//                       Icons.close,
//                       color: Colors.white,
//                       size: 28,
//                     ),
//                   ),
//                   Text(
//                     '${_currentIndex + 1}/${widget.imageUrls.length}',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(width: 48),
//                 ],
//               ),
//             ),
//           ),
//
//           // Page Indicator
//           if (widget.imageUrls.length > 1)
//             Positioned(
//               bottom: 40,
//               left: 0,
//               right: 0,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: List.generate(
//                   widget.imageUrls.length,
//                       (index) => Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 4),
//                     width: 8,
//                     height: 8,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: _currentIndex == index
//                           ? FColors.primary
//                           : Colors.white.withOpacity(0.5),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }