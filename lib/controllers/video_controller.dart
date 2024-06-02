import 'dart:ui';

import 'package:netr/controllers/video_controller_stub.dart'
    if (dart.library.io) 'package:netr/controllers/video_controller_other.dart'
    if (dart.library.html) 'package:netr/controllers/video_controller_web.dart';
import 'package:netr/controllers/video_player_controller_interface.dart';

void initialize() {
  initializeController();
}

class VideoController extends VideoPlayerControllerInterface {
  VideoController(String dataSource, bool autoPlay)
      : videoController = createController(dataSource, autoPlay);

  final VideoPlayerControllerInterface videoController;

  @override
  void addListener(
      VoidCallback onInitListener,
      DoubleCallback bufferingListener,
      VoidCallback playingListener,
      VoidCallback stoppedListener,
      ErrorCallback errorListener) {
    videoController.addListener(onInitListener, bufferingListener,
        playingListener, stoppedListener, errorListener);
  }

  @override
  Future<void> dispose() {
    return videoController.dispose();
  }

  @override
  bool isInitialized() {
    return videoController.isInitialized();
  }

  @override
  Future<bool?> isPlaying() {
    return videoController.isPlaying();
  }

  @override
  Future<void> pause() {
    return videoController.pause();
  }

  @override
  Future<void> play() {
    return videoController.play();
  }

  @override
  void removeListener() {
    return videoController.removeListener();
  }

  @override
  Future<void> setMediaFromNetwork(String dataSource, {bool? autoPlay}) {
    return videoController.setMediaFromNetwork(dataSource, autoPlay: autoPlay);
  }

  @override
  Future<void> stop() {
    return videoController.stop();
  }
}
