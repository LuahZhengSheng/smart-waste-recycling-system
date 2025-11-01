import 'package:flutter/material.dart';
import 'package:fyp/features/community/controllers/posts/create_post_controller.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:video_player/video_player.dart';

class MediaLightbox extends StatefulWidget {
  final int initialIndex;

  const MediaLightbox({
    super.key,
    required this.initialIndex,
  });

  @override
  State<MediaLightbox> createState() => _MediaLightboxState();
}

class _MediaLightboxState extends State<MediaLightbox> {
  late PageController _pageController;
  late int _currentIndex;
  final controller = Get.find<CreatePostController>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Media PageView
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: controller.mediaFiles.length,
            itemBuilder: (context, index) {
              final media = controller.mediaFiles[index];
              return Center(
                child: media.type == MediaType.image
                    ? InteractiveViewer(
                  child: Image.file(
                    media.file,
                    fit: BoxFit.contain,
                  ),
                )
                    : _VideoPlayerWidget(media: media),
              );
            },
          ),

          // Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                left: 8,
                right: 8,
                bottom: 8,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  Text(
                    '${_currentIndex + 1}/${controller.mediaFiles.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      controller.removeMediaFile(
                        controller.mediaFiles[_currentIndex].id,
                      );
                      if (controller.mediaFiles.isEmpty) {
                        Navigator.pop(context);
                      } else if (_currentIndex >= controller.mediaFiles.length) {
                        setState(() {
                          _currentIndex = controller.mediaFiles.length - 1;
                        });
                        _pageController.jumpToPage(_currentIndex);
                      }
                    },
                    icon: const Icon(
                      Iconsax.trash,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Page Indicator
          if (controller.mediaFiles.length > 1)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  controller.mediaFiles.length,
                      (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index
                          ? FColors.primary
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _VideoPlayerWidget extends StatefulWidget {
  final MediaFile media;

  const _VideoPlayerWidget({required this.media});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  bool _isPlaying = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    widget.media.videoController?.addListener(_videoListener);
  }

  @override
  void dispose() {
    widget.media.videoController?.removeListener(_videoListener);
    super.dispose();
  }

  void _videoListener() {
    if (mounted) {
      setState(() {
        _isPlaying = widget.media.videoController?.value.isPlaying ?? false;
      });
    }
  }

  void _togglePlayPause() {
    if (widget.media.videoController?.value.isPlaying ?? false) {
      widget.media.videoController?.pause();
    } else {
      widget.media.videoController?.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.media.videoController;

    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: FColors.primary),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _showControls = !_showControls;
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          ),
          if (_showControls)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: IconButton(
                  onPressed: _togglePlayPause,
                  icon: Icon(
                    _isPlaying ? Iconsax.pause_circle : Iconsax.play_circle,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ),
            ),
          if (_showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: ValueListenableBuilder(
                  valueListenable: controller,
                  builder: (context, VideoPlayerValue value, child) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              _formatDuration(value.position),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            Expanded(
                              child: Slider(
                                value: value.position.inMilliseconds.toDouble(),
                                max: value.duration.inMilliseconds.toDouble(),
                                onChanged: (newValue) {
                                  controller.seekTo(
                                    Duration(milliseconds: newValue.toInt()),
                                  );
                                },
                                activeColor: FColors.primary,
                                inactiveColor: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            Text(
                              _formatDuration(value.duration),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
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