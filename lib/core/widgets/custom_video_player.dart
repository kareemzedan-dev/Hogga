import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:hogga/core/utils/app_colors.dart';
import 'package:hogga/core/utils/image_helper.dart';

class CustomVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;

  const CustomVideoPlayer({
    super.key,
    required this.videoUrl,
    this.autoPlay = false,
  });

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    final sanitizedUrl = ImageHelper.sanitizeUrl(widget.videoUrl);
    _controller = VideoPlayerController.networkUrl(Uri.parse(sanitizedUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          if (widget.autoPlay) {
            _controller.play();
          }
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              if (_controller.value.isPlaying) {
                _controller.pause();
              } else {
                _controller.play();
              }
            });
          },
          child: Container(
            color: Colors.transparent,
            child: Center(
              child: Icon(
                _controller.value.isPlaying ? Icons.pause_circle : Icons.play_circle,
                size: 50,
                color: AppColors.cream.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
