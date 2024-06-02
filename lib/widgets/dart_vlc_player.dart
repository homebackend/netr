import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:netr/controllers/dart_vlc_controller.dart';

class DartVlcVideoPlayer extends StatefulWidget {
  const DartVlcVideoPlayer({Key? key, required this.videoPlayerController})
      : super(key: key);

  final DartVlcVideoPlayerController videoPlayerController;

  @override
  State<DartVlcVideoPlayer> createState() => _DartVlcVideoPlayerState();

}

class _DartVlcVideoPlayerState extends State<DartVlcVideoPlayer> {
  @override
  void dispose() {
    super.dispose();
    widget.videoPlayerController.stop();
    widget.videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Video(
      player: widget.videoPlayerController.player,
      scale: 1.0,
      showControls: false,
    );
  }
}
