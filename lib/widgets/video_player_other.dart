import 'package:flutter/material.dart';
import 'package:netr/controllers/dart_vlc_controller.dart';
import 'package:netr/controllers/flutter_vlc_controller.dart';
import 'package:netr/controllers/video_player_controller_interface.dart';
import 'package:netr/tool.dart';
import 'package:netr/widgets/dart_vlc_player.dart';
import 'package:netr/widgets/flutter_vlc_player.dart';

Widget createPlayer(VideoPlayerControllerInterface controller) {
  if (isMobilePlatform()) {
    return FlutterVlcVideoPlayer(
      videoPlayerController: controller as FlutterVlcVideoPlayerController,
      aspectRatio: 16 / 9,
      placeholder: getBusyIndicator(),
    );
  } else if (isDesktopPlatform()) {
    return DartVlcVideoPlayer(
      videoPlayerController: controller as DartVlcVideoPlayerController,
    );
  } else {
    return const Text('Cannot create a Player for your platform.');
  }
}
