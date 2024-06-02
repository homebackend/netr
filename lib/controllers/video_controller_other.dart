import 'package:dart_vlc/dart_vlc.dart';
import 'package:netr/controllers/dart_vlc_controller.dart'
    as dart_vlc_controller;
import 'package:netr/controllers/dummy_vlc_controller.dart';
import 'package:netr/controllers/flutter_vlc_controller.dart'
    as flutter_vlc_controller;
import 'package:netr/controllers/video_player_controller_interface.dart';
import 'package:netr/tool.dart';

void initializeController() {
  if (isDesktopPlatform()) {
    DartVLC.initialize();
  }
}

VideoPlayerControllerInterface createController(
    String dataSource, bool autoPlay) {
  if (isDesktopPlatform()) {
    return dart_vlc_controller.createController(dataSource, autoPlay);
  } else if (isMobilePlatform()) {
    return flutter_vlc_controller.createController(dataSource, autoPlay);
  }

  return DummyVlcController();
}
