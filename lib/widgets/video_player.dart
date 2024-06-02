import 'package:flutter/material.dart';
import 'package:netr/controllers/video_controller.dart';
import 'package:netr/controllers/video_player_controller_interface.dart';
import 'package:netr/widgets/video_player_stub.dart'
    if (dart.library.io) 'package:netr/widgets/video_player_other.dart'
    if (dart.library.html) 'package:netr/widgets/video_player_web.dart';

Widget createVideoPlayer(VideoPlayerControllerInterface controller) {
  VideoController videoController = controller as VideoController;
  return createPlayer(videoController.videoController);
}
