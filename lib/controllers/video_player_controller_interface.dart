import 'dart:ui';

typedef ErrorCallback = void Function(String error);
typedef DoubleCallback = void Function(double value);

abstract class VideoPlayerControllerInterface {
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  bool isInitialized();
  Future<bool?> isPlaying();
  Future<void> dispose();
  Future<void> setMediaFromNetwork(String dataSource, {bool? autoPlay});
  void addListener(
      VoidCallback onInitListener,
      DoubleCallback bufferingListener,
      VoidCallback playingListener,
      VoidCallback stoppedListener,
      ErrorCallback errorListener);
  void removeListener();
}
