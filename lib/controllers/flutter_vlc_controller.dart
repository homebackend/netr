import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:netr/controllers/video_player_controller_interface.dart';

VideoPlayerControllerInterface createController(
        String dataSource, bool autoPlay) =>
    FlutterVlcVideoPlayerController.network(dataSource, autoPlay: autoPlay);

class FlutterVlcVideoPlayerController
    implements VideoPlayerControllerInterface {
  FlutterVlcVideoPlayerController.network(
    dataSource, {
    autoPlay,
  })  : _playEventSent = false,
        _stopEventSent = true,
        playerController = VlcPlayerController.network(dataSource,
            autoPlay: true, options: VlcPlayerOptions()) {
    playerController.addOnInitListener(() {
      if (_onInitListener != null) {
        _onInitListener!.call();
      }
    });
    playerController.addListener(() {
      if (playerController.value.isInitialized) {
        if (playerController.value.isPlaying) {
          if (!_playEventSent) {
            _playEventSent = true;
            _stopEventSent = false;
            _playingListener?.call();
          } else if (playerController.value.bufferPercent > 0) {
            return _bufferingListener?.call(
                playerController.value.bufferPercent);
          }
        } else if (!playerController.value.isPlaying && !_stopEventSent) {
          _playEventSent = false;
          _stopEventSent = true;
          _stoppedListener?.call();
        }

        if (playerController.value.hasError) {
          _errorListener?.call(playerController.value.errorDescription);
        }
      }
    });
  }

  bool _playEventSent;
  bool _stopEventSent;
  VlcPlayerController playerController;
  VoidCallback? _onInitListener;
  DoubleCallback? _bufferingListener;
  VoidCallback? _playingListener;
  VoidCallback? _stoppedListener;
  ErrorCallback? _errorListener;

  @override
  bool isInitialized() {
    return playerController.value.isInitialized;
  }

  @override
  Future<void> play() async {
    return playerController.play();
  }

  @override
  Future<void> pause() async {
    return playerController.pause();
  }

  @override
  Future<void> stop() async {
    return playerController.stop();
  }

  @override
  Future<bool?> isPlaying() async {
    return playerController.isPlaying();
  }

  @override
  Future<void> setMediaFromNetwork(String dataSource, {bool? autoPlay}) async {
    return playerController.setMediaFromNetwork(dataSource, autoPlay: autoPlay);
  }

  @override
  void addListener(
      VoidCallback onInitListener,
      DoubleCallback bufferingListener,
      VoidCallback playingListener,
      VoidCallback stoppedListener,
      ErrorCallback errorListener) {
    _onInitListener = onInitListener;
    _bufferingListener = bufferingListener;
    _playingListener = playingListener;
    _stoppedListener = stoppedListener;
    _errorListener = errorListener;
  }

  @override
  void removeListener() {
    _onInitListener = null;
    _bufferingListener = null;
    _playingListener = null;
    _stoppedListener = null;
    _errorListener = null;
  }

  @override
  Future<void> dispose() async {
    await playerController.stopRendererScanning();
    await playerController.dispose();
  }
}
