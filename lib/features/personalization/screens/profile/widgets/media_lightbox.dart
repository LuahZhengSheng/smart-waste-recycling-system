import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:fyp/utils/constants/colors.dart';

class MediaLightbox extends StatelessWidget {
  final List<String> mediaUrls;
  final int initialIndex;
  final bool isNetworkImage;

  const MediaLightbox({
    super.key,
    required this.mediaUrls,
    this.initialIndex = 0,
    this.isNetworkImage = true,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MediaLightboxController(
      mediaUrls: mediaUrls,
      initialIndex: initialIndex,
    ));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Photo Gallery
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: isNetworkImage
                    ? NetworkImage(mediaUrls[index])
                    : FileImage(File(mediaUrls[index])) as ImageProvider,
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 4.0,
                heroAttributes: PhotoViewHeroAttributes(tag: mediaUrls[index]),
              );
            },
            itemCount: mediaUrls.length,
            loadingBuilder: (context, event) => Center(
              child: CircularProgressIndicator(
                value: event == null
                    ? 0
                    : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
                color: FColors.primary,
              ),
            ),
            pageController: controller.pageController,
            onPageChanged: controller.onPageChanged,
          ),

          // Close Button (Top Left)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Get.back(),
                  ),
                ),
              ),
            ),
          ),

          // Image Counter (Top Right) - Only show if multiple images
          if (mediaUrls.length > 1)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Obx(() => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${controller.currentIndex.value + 1} / ${mediaUrls.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MediaLightboxController extends GetxController {
  final List<String> mediaUrls;
  final int initialIndex;

  MediaLightboxController({
    required this.mediaUrls,
    required this.initialIndex,
  });

  late final PageController pageController;
  final currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    currentIndex.value = initialIndex;
    pageController = PageController(initialPage: initialIndex);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
  }
}

// Helper function to show media lightbox
void showMediaLightbox(
    List<String> mediaUrls, {
      int initialIndex = 0,
      bool isNetworkImage = true,
    }) {
  Get.to(
        () => MediaLightbox(
      mediaUrls: mediaUrls,
      initialIndex: initialIndex,
      isNetworkImage: isNetworkImage,
    ),
    transition: Transition.fadeIn,
    duration: const Duration(milliseconds: 200),
  );
}