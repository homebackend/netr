import 'dart:ui';

import 'package:netr/controllers/video_player_controller_interface.dart';

class DummyVlcController extends VideoPlayerControllerInterface {
  @override
  void addListener(
      VoidCallback onInitListener,
      DoubleCallback bufferingListener,
      VoidCallback playingListener,
      VoidCallback stoppedListener,
      ErrorCallback errorListener) {
    // TODO: implement addListener
  }

  @override
  Future<void> dispose() {
    // TODO: implement dispose
    throw UnimplementedError();
  }

  @override
  bool isInitialized() {
    // TODO: implement isInitialized
    throw UnimplementedError();
  }

  @override
  Future<bool?> isPlaying() {
    // TODO: implement isPlaying
    throw UnimplementedError();
  }

  @override
  Future<void> pause() {
    // TODO: implement pause
    throw UnimplementedError();
  }

  @override
  Future<void> play() {
    // TODO: implement play
    throw UnimplementedError();
  }

  @override
  void removeListener() {
    // TODO: implement removeListener
  }

  @override
  Future<void> setMediaFromNetwork(String dataSource, {bool? autoPlay}) {
    // TODO: implement setMediaFromNetwork
    throw UnimplementedError();
  }

  @override
  Future<void> stop() {
    // TODO: implement stop
    throw UnimplementedError();
  }
}