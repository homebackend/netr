import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:netr/controllers/flutter_vlc_controller.dart';

class FlutterVlcVideoPlayer extends StatefulWidget {
  const FlutterVlcVideoPlayer({
    Key? key,
    required this.videoPlayerController,
    required this.aspectRatio,
    required this.placeholder,
  }) : super(key: key);

  final double aspectRatio;
  final Widget placeholder;
  final FlutterVlcVideoPlayerController videoPlayerController;

  @override
  State<FlutterVlcVideoPlayer> createState() => _FlutterVlcVideoPlayerState();
}

class _FlutterVlcVideoPlayerState extends State<FlutterVlcVideoPlayer> {
  @override
  void dispose() async {
    super.dispose();
    await widget.videoPlayerController.stop();
    await widget.videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VlcPlayer(
      controller: widget.videoPlayerController.playerController,
      aspectRatio: widget.aspectRatio,
      placeholder: widget.placeholder,
    );
  }
}
