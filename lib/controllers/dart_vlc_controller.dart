import 'dart:developer';
import 'dart:ui';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:netr/controllers/video_player_controller_interface.dart';

VideoPlayerControllerInterface createController(
        String dataSource, bool autoPlay) =>
    DartVlcVideoPlayerController.network(dataSource, autoPlay: autoPlay);

class DartVlcVideoPlayerController implements VideoPlayerControllerInterface {
  DartVlcVideoPlayerController.network(dataSource, {autoPlay = false})
      : playing = true,
        player = Player(
          id: 0,
          /* commandlineArguments: [
            '--rtsp-frame-buffer-size=500000'
          ] */
        ) {
    player.playbackStream.listen(
        (PlaybackState playbackState) {
          if (_playingListener != null && playbackState.isPlaying) {
            return _playingListener?.call();
          }

          if (_stoppedListener != null && playbackState.isCompleted) {
            return _stoppedListener?.call();
          }
        },
        onError: _errorHandler,
        onDone: () {
          log("playback done");
          _stoppedListener?.call();
        });
    player.bufferingProgressStream.listen(
        (double bufferingProgress) {
          log('Buffering: $bufferingProgress');
          // Don't notify until buffering has started
          if (bufferingProgress == 0) {
            return;
          }

          return _bufferingListener?.call(bufferingProgress);
        },
        onError: _errorHandler,
        onDone: () {
          log('Buffering complete');
          _bufferingListener?.call(100);
        });

    player.errorStream.listen((error) {
      log("Error during play: $error");
      _errorListener?.call("Unknown error: $error");
    });

    setMediaFromNetwork(dataSource, autoPlay: autoPlay);
  }

  bool playing;
  Player player;
  VoidCallback? _playingListener;
  DoubleCallback? _bufferingListener;
  VoidCallback? _stoppedListener;
  ErrorCallback? _errorListener;

  void _errorHandler(Object error, StackTrace trace) {
    log("Error [$error]: $trace");
    if (_errorListener != null) {
      if (error.runtimeType == String) {
        _errorListener!(error as String);
      } else {
        _errorListener!("Unknown error: $error");
      }
    }
  }

  @override
  bool isInitialized() {
    return true;
  }

  @override
  Future<void> play() async {
    playing = true;
    return player.play();
  }

  @override
  Future<void> pause() async {
    playing = false;
    return player.pause();
  }

  @override
  Future<void> stop() async {
    playing = false;
    return player.stop();
  }

  @override
  Future<bool?> isPlaying() async {
    return playing;
  }

  @override
  Future<void> setMediaFromNetwork(String dataSource, {bool? autoPlay}) async {
    player.open(Media.network(dataSource), autoStart: autoPlay ?? false);
    player.play();
  }

  @override
  void addListener(
      VoidCallback onInitListener,
      DoubleCallback bufferingListener,
      VoidCallback playingListener,
      VoidCallback stoppedListener,
      ErrorCallback errorListener) {
    _bufferingListener = bufferingListener;
    _playingListener = playingListener;
    _stoppedListener = stoppedListener;
    _errorListener = errorListener;
  }

  @override
  void removeListener() {
    _playingListener = null;
    _stoppedListener = null;
    _errorListener = null;
  }

  @override
  Future<void> dispose() async {
    return player.dispose();
  }
}
