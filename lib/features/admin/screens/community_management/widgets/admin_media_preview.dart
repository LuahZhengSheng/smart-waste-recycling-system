import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:video_player/video_player.dart';

/// Admin Media Lightbox
class AdminMediaLightbox extends StatefulWidget {
  final Uint8List? imageBytes;
  final List<String> mediaUrls;
  final int initialIndex;
  final bool dark;

  const AdminMediaLightbox({
    super.key,
    this.imageBytes,
    this.mediaUrls = const [],
    this.initialIndex = 0,
    required this.dark,
  });

  @override
  State<AdminMediaLightbox> createState() => _AdminMediaLightboxState();
}

class _AdminMediaLightboxState extends State<AdminMediaLightbox> {
  late int currentIndex;
  late PageController _pageController;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoPlaying = false;
  bool _isInitializing = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    print('=== AdminMediaLightbox initState ===');
    print('Total media URLs: ${widget.mediaUrls.length}');
    print('Initial index: ${widget.initialIndex}');

    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // Print all media URLs
    for (int i = 0; i < widget.mediaUrls.length; i++) {
      final url = widget.mediaUrls[i];
      final isVideo = _isVideoUrl(url);
      print('Media $i: $url');
      print('  -> Is video: $isVideo');
    }

    // Initialize video if current page is video
    if (widget.mediaUrls.isNotEmpty && _isVideoUrl(widget.mediaUrls[currentIndex])) {
      print('Current media is video, initializing...');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeVideo(widget.mediaUrls[currentIndex]);
      });
    } else {
      print('Current media is NOT video or no media');
    }
  }

  void _startHideControlsTimer() {
    print('🕐 Starting hide controls timer...');
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(Duration(seconds: 1), () {
      print('⏰ Timer fired! _isVideoPlaying: $_isVideoPlaying, mounted: $mounted');
      if (mounted && _isVideoPlaying) {
        setState(() {
          _showControls = false;
        });
        print('✓ Controls hidden after 3 seconds');
      }
    });
  }

  void _showControlsTemporarily() {
    print('👁️ Showing controls temporarily...');
    if (mounted) {
      setState(() {
        _showControls = true;
      });
      print('✓ Controls shown, _isVideoPlaying: $_isVideoPlaying');
      if (_isVideoPlaying) {
        _startHideControlsTimer();
      }
    }
  }

  Future<void> _initializeVideo(String url) async {
    if (_isInitializing) {
      print('⚠️ Already initializing, skipping...');
      return;
    }

    _isInitializing = true;
    print('\n=== _initializeVideo START ===');
    print('URL: $url');
    print('Is video URL: ${_isVideoUrl(url)}');

    // Dispose previous controller
    if (_videoController != null) {
      print('Disposing previous video controller...');
      try {
        await _videoController?.dispose();
      } catch (e) {
        print('Error disposing controller: $e');
      }
      _videoController = null;
    }

    print('Creating new VideoPlayerController...');
    _videoController = VideoPlayerController.networkUrl(Uri.parse(url));

    try {
      print('Initializing video controller...');
      await _videoController!.initialize();
      print('✓ Video controller initialized successfully!');
      print('Video duration: ${_videoController!.value.duration}');
      print('Video aspect ratio: ${_videoController!.value.aspectRatio}');
      print('Video size: ${_videoController!.value.size}');

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
          _showControls = true;
        });
        print('✓ Set _isVideoInitialized = true, _showControls = true');

        print('Starting video playback...');
        _videoController!.play();
        print('✓ Video play() called');

        setState(() {
          _isVideoPlaying = true;
        });
        print('✓ Set _isVideoPlaying = true');

        // Start timer AFTER all setState calls
        print('📍 About to start hide timer...');
        _startHideControlsTimer();
        print('📍 Hide timer started!');
      } else {
        print('✗ Widget not mounted, skipping setState');
      }
    } catch (error) {
      print('✗✗✗ ERROR initializing video: $error');
      print('Error type: ${error.runtimeType}');
      print('Stack trace:');
      print(StackTrace.current);

      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
    } finally {
      _isInitializing = false;
      print('=== _initializeVideo END ===\n');
    }
  }

  void _toggleVideoPlayback() {
    print('\n=== _toggleVideoPlayback ===');
    print('_videoController: $_videoController');
    print('_isVideoInitialized: $_isVideoInitialized');

    if (_videoController == null || !_isVideoInitialized) {
      print('✗ Cannot toggle: controller is null or not initialized');
      return;
    }

    print('Current playing state: ${_videoController!.value.isPlaying}');

    setState(() {
      if (_videoController!.value.isPlaying) {
        print('Pausing video...');
        _videoController!.pause();
        _isVideoPlaying = false;
        _showControls = true;
        _hideControlsTimer?.cancel();
        print('✓ Timer cancelled, controls will stay visible');
      } else {
        print('Playing video...');
        _videoController!.play();
        _isVideoPlaying = true;
        _showControls = true;
        _startHideControlsTimer();
        print('✓ Playing and timer started');
      }
    });
    print('New playing state: $_isVideoPlaying');
  }

  @override
  void dispose() {
    print('\n=== AdminMediaLightbox dispose ===');
    _hideControlsTimer?.cancel();
    _pageController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasImageBytes = widget.imageBytes != null;
    final hasMediaUrls = widget.mediaUrls.isNotEmpty;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(FSizes.md),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: widget.dark ? FColors.adminDarkDivider : FColors.adminLightDivider,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    hasImageBytes
                        ? 'Poster Preview'
                        : 'Media Preview (${currentIndex + 1} of ${widget.mediaUrls.length})',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Iconsax.close_circle,
                      color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Media content
            Expanded(
              child: hasImageBytes
                  ? _buildImageFromBytes()
                  : _buildMediaPageView(),
            ),

            // Navigation controls (only for multiple media)
            if (hasMediaUrls && widget.mediaUrls.length > 1)
              Container(
                padding: const EdgeInsets.all(FSizes.md),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: widget.dark ? FColors.adminDarkDivider : FColors.adminLightDivider,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: currentIndex > 0
                          ? () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                          : null,
                      icon: Icon(
                        Iconsax.arrow_left_2,
                        color: currentIndex > 0
                            ? (widget.dark ? FColors.adminDarkText : FColors.adminLightText)
                            : (widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
                      ),
                    ),
                    const SizedBox(width: FSizes.lg),
                    // Dots indicator
                    Row(
                      children: List.generate(
                        widget.mediaUrls.length,
                            (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: index == currentIndex
                                ? (widget.dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary)
                                : (widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: FSizes.lg),
                    IconButton(
                      onPressed: currentIndex < widget.mediaUrls.length - 1
                          ? () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                          : null,
                      icon: Icon(
                        Iconsax.arrow_right_3,
                        color: currentIndex < widget.mediaUrls.length - 1
                            ? (widget.dark ? FColors.adminDarkText : FColors.adminLightText)
                            : (widget.dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageFromBytes() {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      child: Center(
        child: Image.memory(
          widget.imageBytes!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        ),
      ),
    );
  }

  Widget _buildMediaPageView() {
    print('\n=== _buildMediaPageView ===');
    print('Building PageView with ${widget.mediaUrls.length} items');

    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) async {
        print('\n=== onPageChanged to index $index ===');
        print('Old index: $currentIndex');
        print('New URL: ${widget.mediaUrls[index]}');
        print('Is video: ${_isVideoUrl(widget.mediaUrls[index])}');

        // Cancel hide timer when changing pages
        _hideControlsTimer?.cancel();
        print('✓ Cancelled hide timer on page change');

        // Dispose old video controller first
        if (_videoController != null) {
          print('Disposing old video controller...');
          try {
            await _videoController?.dispose();
          } catch (e) {
            print('Error disposing: $e');
          }
          _videoController = null;
        }

        if (mounted) {
          setState(() {
            currentIndex = index;
            _isVideoInitialized = false;
            _isVideoPlaying = false;
            _isInitializing = false;
            _showControls = true;
          });
          print('Updated state: currentIndex=$currentIndex');
        }

        // 使用延迟确保状态更新后再初始化
        if (_isVideoUrl(widget.mediaUrls[index])) {
          print('Scheduling video initialization...');
          await Future.delayed(Duration(milliseconds: 100));
          if (mounted && currentIndex == index) {
            print('Starting video initialization...');
            _initializeVideo(widget.mediaUrls[index]);
          }
        } else {
          print('New media is image, no initialization needed');
        }
      },
      itemCount: widget.mediaUrls.length,
      itemBuilder: (context, index) {
        final mediaUrl = widget.mediaUrls[index];
        final isVideo = _isVideoUrl(mediaUrl);

        print('Building item $index: ${isVideo ? "VIDEO" : "IMAGE"}');

        return Container(
          padding: const EdgeInsets.all(FSizes.lg),
          child: Center(
            child: isVideo
                ? _buildVideoPlayer(mediaUrl)
                : _buildImagePlayer(mediaUrl),
          ),
        );
      },
    );
  }

  Widget _buildImagePlayer(String url) {
    print('Building image player for: $url');
    return Image.network(
      url,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          print('Image loaded successfully: $url');
          return child;
        }
        return _buildLoadingWidget(loadingProgress);
      },
      errorBuilder: (context, error, stackTrace) {
        print('✗ Error loading image: $error');
        return _buildErrorWidget();
      },
    );
  }

  Widget _buildVideoPlayer(String url) {
    print('\n=== _buildVideoPlayer (build) ===');
    print('_showControls: $_showControls');
    print('_isVideoPlaying: $_isVideoPlaying');

    if (_videoController == null || !_isVideoInitialized) {
      print('Showing loading widget (controller not ready)');
      return _buildLoadingWidget(null);
    }

    print('Building video player with aspect ratio: ${_videoController!.value.aspectRatio}');

    return AspectRatio(
      aspectRatio: _videoController!.value.aspectRatio,
      child: MouseRegion(
        onEnter: (_) {
          print('🖱️ Mouse entered video area');
          _showControlsTemporarily();
        },
        onExit: (_) {
          print('🖱️ Mouse exited video area');
          if (_isVideoPlaying) {
            _startHideControlsTimer();
          }
        },
        child: GestureDetector(
          onTap: () {
            print('👆 Video tapped!');
            _toggleVideoPlayback();
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Video player
              VideoPlayer(_videoController!),

              // Play/Pause button in center (with fade animation)
              IgnorePointer(
                ignoring: !_showControls,
                child: AnimatedOpacity(
                  opacity: _showControls ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 300),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isVideoPlaying ? Iconsax.pause : Iconsax.play,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // Video progress bar at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: VideoProgressIndicator(
                  _videoController!,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    playedColor: widget.dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                    bufferedColor: Colors.grey,
                    backgroundColor: Colors.grey.shade300,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget(ImageChunkEvent? loadingProgress) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: widget.dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
            value: loadingProgress?.expectedTotalBytes != null
                ? loadingProgress!.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
          ),
        ),
        const SizedBox(height: FSizes.md),
        Text(
          'Loading media...',
          style: TextStyle(
            color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Iconsax.close_circle,
          size: 64,
          color: widget.dark ? FColors.adminDarkError : FColors.adminLightError,
        ),
        const SizedBox(height: FSizes.md),
        Text(
          'Failed to load media',
          style: TextStyle(
            fontSize: 16,
            color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
          ),
        ),
      ],
    );
  }

  bool _isVideoUrl(String url) {
    final uri = Uri.parse(url);
    final path = uri.path.toLowerCase();

    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.webm'];
    final isVideo = videoExtensions.any((ext) => path.contains(ext));

    return isVideo;
  }
}

/// Admin Media Preview Widget
class AdminMediaPreview extends StatelessWidget {
  final List<String> mediaUrls;
  final bool dark;
  final double size;
  final int maxDisplay;

  const AdminMediaPreview({
    super.key,
    required this.mediaUrls,
    required this.dark,
    this.size = 40,
    this.maxDisplay = 2,
  });

  @override
  Widget build(BuildContext context) {
    if (mediaUrls.isEmpty) {
      return Text(
        'No media',
        style: TextStyle(
          color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
          fontStyle: FontStyle.italic,
          fontSize: 12,
        ),
      );
    }

    return SizedBox(
      height: size,
      child: Row(
        children: [
          // 第一个媒体预览
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: GestureDetector(
              onTap: () => _showMediaDialog(context, 0),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
                  border: Border.all(
                    color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusXs - 1),
                  child: _isImageUrl(mediaUrls[0])
                      ? Image.network(
                    mediaUrls[0],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Iconsax.image,
                      size: size * 0.5,
                      color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                    ),
                  )
                      : Icon(
                    Iconsax.video_play,
                    size: size * 0.5,
                    color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                  ),
                ),
              ),
            ),
          ),

          // 第二个媒体预览（如果有的话）
          if (mediaUrls.length >= 2)
            Stack(
              children: [
                // 第二个媒体背景
                GestureDetector(
                  onTap: () => _showMediaDialog(context, 1),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: dark ? FColors.adminDarkSurfaceVariant : FColors.adminLightSurfaceVariant,
                      borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
                      border: Border.all(
                        color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(FSizes.cardRadiusXs - 1),
                      child: _isImageUrl(mediaUrls[1])
                          ? Image.network(
                        mediaUrls[1],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Iconsax.image,
                          size: size * 0.5,
                          color: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                        ),
                      )
                          : Icon(
                        Iconsax.video_play,
                        size: size * 0.5,
                        color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                      ),
                    ),
                  ),
                ),

                // Overlay（如果超过2个媒体）
                if (mediaUrls.length > 2)
                  GestureDetector(
                    onTap: () => _showMediaDialog(context, 1),
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
                      ),
                      child: Center(
                        child: Text(
                          '+${mediaUrls.length - 2}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  bool _isImageUrl(String url) {
    final uri = Uri.parse(url);
    final path = uri.path.toLowerCase();

    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    return imageExtensions.any((ext) => path.contains(ext));
  }

  void _showMediaDialog(BuildContext context, int initialIndex) {
    print('\n=== AdminMediaPreview: Opening lightbox ===');
    print('Initial index: $initialIndex');
    print('Total media: ${mediaUrls.length}');

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) => AdminMediaLightbox(
        mediaUrls: mediaUrls,
        initialIndex: initialIndex,
        dark: dark,
      ),
    );
  }
}
