import 'dart:developer';
import 'dart:ui';

import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:netr/controllers/video_player_controller_interface.dart';

class MediaKitController implements VideoPlayerControllerInterface {
  MediaKitController(dataSource, {autoPlay = false})
      : playing = true,
        player = Player() {
    player.stream.buffering.listen(
        (buffering) {
          log('Buffering: $buffering');
          return _bufferingListener?.call(50);
        },
        onError: _errorHandler,
        onDone: () {
          log('Buffering complete');
          _bufferingListener?.call(100);
        });
    player.stream.playing.listen(
        (playing) {
          if (playing) {
            _bufferingListener?.call(100);
            return _playingListener?.call();
          } else {
            return _stoppedListener?.call();
          }
        },
        onError: _errorHandler,
        onDone: () {
          log("playback done");
          _stoppedListener?.call();
        });

    player.stream.error.listen((error) {
      log("Error during play: $error");
      _errorListener?.call("Unknown error: $error");
    });

    controller = VideoController(player);
    setMediaFromNetwork(dataSource, autoPlay: autoPlay);
  }

  bool playing;
  Player player;
  late VideoController controller;
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
    player.open(Media(dataSource), play: autoPlay ?? false);
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
