import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:video_player/video_player.dart';

/// 媒体类型枚举
enum UnifiedMediaType { network, file }

/// 媒体项数据模型
class UnifiedMediaItem {
  final String id;
  final UnifiedMediaType type;
  final String? networkUrl;
  final File? file;
  final bool isVideo;

  UnifiedMediaItem.network({
    required this.id,
    required this.networkUrl,
    required this.isVideo,
  })  : type = UnifiedMediaType.network,
        file = null;

  UnifiedMediaItem.file({
    required this.id,
    required this.file,
    required this.isVideo,
  })  : type = UnifiedMediaType.file,
        networkUrl = null;

  String get displayPath {
    return type == UnifiedMediaType.network ? networkUrl! : file!.path;
  }
}

/// 统一的媒体查看器
class UnifiedMediaLightbox extends StatefulWidget {
  final List<UnifiedMediaItem> mediaItems;
  final int initialIndex;
  final bool showDeleteButton;
  final Function(String id)? onDelete;

  const UnifiedMediaLightbox({
    super.key,
    required this.mediaItems,
    required this.initialIndex,
    this.showDeleteButton = false,
    this.onDelete,
  });

  @override
  State<UnifiedMediaLightbox> createState() => _UnifiedMediaLightboxState();
}

class _UnifiedMediaLightboxState extends State<UnifiedMediaLightbox> {
  late PageController _pageController;
  late int _currentIndex;
  final Map<int, VideoPlayerController> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _pauseCurrentVideo() {
    final controller = _videoControllers[_currentIndex];
    if (controller?.value.isPlaying == true) {
      controller?.pause();
    }
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
              _pauseCurrentVideo();
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.mediaItems.length,
            itemBuilder: (context, index) {
              final mediaItem = widget.mediaItems[index];

              if (mediaItem.isVideo) {
                return _UnifiedVideoPlayerWidget(
                  mediaItem: mediaItem,
                  onControllerCreated: (controller) {
                    _videoControllers[index] = controller;
                  },
                );
              } else {
                return Center(
                  child: InteractiveViewer(
                    child: mediaItem.type == UnifiedMediaType.network
                        ? Image.network(
                      mediaItem.networkUrl!,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                            color: Colors.white,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 64,
                          ),
                        );
                      },
                    )
                        : Image.file(
                      mediaItem.file!,
                      fit: BoxFit.contain,
                      width: double.infinity,
                    ),
                  ),
                );
              }
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
                    '${_currentIndex + 1}/${widget.mediaItems.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (widget.showDeleteButton)
                    IconButton(
                      onPressed: () {
                        final currentItem = widget.mediaItems[_currentIndex];
                        widget.onDelete?.call(currentItem.id);
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Iconsax.trash,
                        color: Colors.red,
                        size: 24,
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          // Page Indicator
          if (widget.mediaItems.length > 1)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.mediaItems.length,
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

/// 统一的视频播放器组件
class _UnifiedVideoPlayerWidget extends StatefulWidget {
  final UnifiedMediaItem mediaItem;
  final Function(VideoPlayerController)? onControllerCreated;

  const _UnifiedVideoPlayerWidget({
    required this.mediaItem,
    this.onControllerCreated,
  });

  @override
  State<_UnifiedVideoPlayerWidget> createState() => _UnifiedVideoPlayerWidgetState();
}

class _UnifiedVideoPlayerWidgetState extends State<_UnifiedVideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _showControls = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initializeVideo() async {
    try {
      if (widget.mediaItem.type == UnifiedMediaType.network) {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.mediaItem.networkUrl!),
        );
      } else {
        _controller = VideoPlayerController.file(widget.mediaItem.file!);
      }

      await _controller.initialize();
      _controller.addListener(_videoListener);
      widget.onControllerCreated?.call(_controller);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Failed to initialize video: $e');
    }
  }

  void _videoListener() {
    if (mounted) {
      setState(() {
        _isPlaying = _controller.value.isPlaying;
      });
    }
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
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
      child: Center(
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(_controller),
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
                      valueListenable: _controller,
                      builder: (context, VideoPlayerValue value, child) {
                        return Row(
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
                                  _controller.seekTo(
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
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
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