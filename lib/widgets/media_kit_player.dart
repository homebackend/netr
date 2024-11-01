import 'package:media_kit_video/media_kit_video.dart';
import 'package:flutter/material.dart';
import 'package:netr/controllers/media_kit_controller.dart';

class MediaKitVideoPlayer extends StatefulWidget {
  const MediaKitVideoPlayer({super.key, required this.videoPlayerController});

  final MediaKitController videoPlayerController;

  @override
  State<MediaKitVideoPlayer> createState() => _MediaKitVideoPlayerState();
}

class _MediaKitVideoPlayerState extends State<MediaKitVideoPlayer> {
  @override
  void dispose() {
    super.dispose();
    widget.videoPlayerController.stop();
    widget.videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Video(
      controller: widget.videoPlayerController.controller,
      controls: null,
      //player: widget.videoPlayerController.player,
      //scale: 1.0,
      //showControls: false,
    );
  }
}
