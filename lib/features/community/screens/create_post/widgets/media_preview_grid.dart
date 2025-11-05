import 'package:flutter/material.dart';
import 'package:fyp/features/community/controllers/posts/create_post_controller.dart';
import 'package:fyp/features/community/models/post_enums.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:video_player/video_player.dart';

import 'media_lightbox.dart';

class FMediaPreviewGrid extends StatelessWidget {
  const FMediaPreviewGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreatePostController>();
    final dark = FHelperFunctions.isDarkMode(context);

    return Obx(() {
      if (controller.mediaFiles.isEmpty) {
        return _buildEmptyState(context, dark);
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: FSizes.sm,
          mainAxisSpacing: FSizes.sm,
          childAspectRatio: 1,
        ),
        itemCount: controller.mediaFiles.length,
        itemBuilder: (context, index) {
          final media = controller.mediaFiles[index];
          return _MediaPreviewCard(
            media: media,
            dark: dark,
            onTap: () => _showMediaLightbox(context, index, controller),
            onRemove: () => controller.removeMediaFile(media.id),
          );
        },
      );
    });
  }

  Widget _buildEmptyState(BuildContext context, bool dark) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: dark ? FColors.communityDarkSurface : FColors.light,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        border: Border.all(
          color: (dark ? FColors.communityDarkBorder : FColors.grey).withOpacity(0.3),
          style: BorderStyle.solid,
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: (dark ? FColors.communityDarkBorder : FColors.grey).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.gallery_add,
                size: 40,
                color: dark ? FColors.darkTextSecondary : FColors.grey,
              ),
            ),
            const SizedBox(height: FSizes.md),
            Text(
              'No media added yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: dark ? FColors.darkTextSecondary : FColors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: FSizes.xs),
            Text(
              'Tap Camera or Gallery to add',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: (dark ? FColors.darkTextSecondary : FColors.grey).withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMediaLightbox(BuildContext context, int initialIndex, CreatePostController controller) {
    final mediaItems = controller.mediaFiles.map((media) {
      return UnifiedMediaItem.file(
        id: media.id,
        file: media.file,
        isVideo: media.type == MediaType.video,
      );
    }).toList();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UnifiedMediaLightbox(
          mediaItems: mediaItems,
          initialIndex: initialIndex,
          showDeleteButton: true,
          onDelete: (id) {
            controller.removeMediaFile(id);
          },
        ),
        fullscreenDialog: true,
      ),
    );
  }
}

class _MediaPreviewCard extends StatelessWidget {
  final MediaFile media;
  final bool dark;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _MediaPreviewCard({
    required this.media,
    required this.dark,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // Media Preview
          Container(
            decoration: BoxDecoration(
              color: dark ? FColors.communityDarkSurface : FColors.lightGrey,
              borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
              border: Border.all(
                color: dark ? FColors.communityDarkBorder : FColors.grey.withOpacity(0.3),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(FSizes.borderRadiusMd),
              child: media.type == MediaType.image
                  ? Image.file(
                media.file,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              )
                  : Stack(
                fit: StackFit.expand,
                children: [
                  if (media.videoController != null)
                    VideoPlayer(media.videoController!),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Iconsax.play_circle,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Remove Button
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: FColors.error,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),

          // Video Duration Badge
          if (media.type == MediaType.video &&
              media.videoController != null &&
              media.videoController!.value.isInitialized)
            Positioned(
              bottom: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Iconsax.video_square,
                      color: Colors.white,
                      size: 10,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDuration(media.videoController!.value.duration),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}