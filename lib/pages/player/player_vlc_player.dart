/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_vlc_player_16kb/flutter_vlc_player.dart';
import 'package:netr/helpers/thumbnail_manager.dart';

import '../../cubit/mixin/camera_view_cubit_mixin.dart';
import '../../cubit/viewer/video_player_cubit.dart';
import 'lib_helper.dart';

class CameraPlayerStreamVlcPlayer extends CameraPlayerStream {
  final StreamController<bool> _bufferingController =
      StreamController<bool>.broadcast();
  final StreamController<bool> _playingController =
      StreamController<bool>.broadcast();
  final StreamController<dynamic> _errorController =
      StreamController<dynamic>.broadcast();
  final StreamController<int?> _widthController =
      StreamController<int?>.broadcast();
  final StreamController<int?> _heightController =
      StreamController<int?>.broadcast();

  @override
  Stream<bool> get buffering => _bufferingController.stream;
  @override
  Stream<bool> get playing => _playingController.stream;
  @override
  Stream<dynamic> get error => _errorController.stream;
  @override
  Stream<int?> get width => _widthController.stream;
  @override
  Stream<int?> get height => _heightController.stream;

  void dispose() {
    _bufferingController.close();
    _playingController.close();
    _errorController.close();
    _widthController.close();
    _heightController.close();
  }
}

mixin PlayerVlcPlayer implements LibHelper {
  bool _isVlcIntialized = false;
  late CameraPlayerStreamVlcPlayer _playerStream;
  VlcPlayerController? _videoPlayerController;

  @override
  void initLibHelper(BuildContext context) {
    _playerStream = CameraPlayerStreamVlcPlayer();
  }

  @override
  void disposeLibHelper() {
    if (_videoPlayerController != null) {
      _videoPlayerController!.removeListener(_playerListener);
      _videoPlayerController!.stopRendererScanning();
      _videoPlayerController!.dispose();
    }

    stream.dispose();
  }

  @override
  void startThumbnailGeneration(String cameraName, String locationName) {
    if (_isVlcIntialized && _videoPlayerController != null) {
      ThumbnailManager.generateCctvThumbnail(cameraName, locationName,
          () => _videoPlayerController!.takeSnapshot());
    }
  }

  @override
  CameraPlayerStreamVlcPlayer get stream => _playerStream;

  @override
  Future<void> open(BuildContext context, String url) async {
    if (!_isVlcIntialized || _videoPlayerController == null) {
      if (_videoPlayerController == null) {
        _videoPlayerController = VlcPlayerController.network(
          "",
          autoPlay: false,
          options: VlcPlayerOptions(),
        );
        _videoPlayerController!.addOnInitListener(() {
          _isVlcIntialized = true;
          _videoPlayerController!.setMediaFromNetwork(url, autoPlay: true);
          _videoPlayerController!.addListener(_playerListener);
        });
      }
      return;
    }

    _videoPlayerController!.setMediaFromNetwork(url, autoPlay: true);
  }

  @override
  Future<void> stop(BuildContext context) async {
    if (_isVlcIntialized && _videoPlayerController != null) {
      await _videoPlayerController!.stop();
    }
  }

  @override
  Future<void> togglePlay() async {
    if (_isVlcIntialized && _videoPlayerController != null) {
      if (await _videoPlayerController!.isPlaying() ?? false) {
        await _videoPlayerController!.stop();
      } else {
        await _videoPlayerController!.play();
      }
    }
  }

  @override
  Widget createVideoWidget(BuildContext context, VideoPlayerState state) {
    if (_videoPlayerController != null) {
      return VlcPlayer(
        controller: _videoPlayerController!,
        aspectRatio: 16 / 9,
        placeholder: _createPlaceholder(),
      );
    }

    initCamera(context);
    return _createPlaceholder();
  }

  Widget _createPlaceholder() => const Center(
        child: Column(
          children: [CircularProgressIndicator(), Text('Loading View')],
        ),
      );

  void _playerListener() {
    if (_isVlcIntialized && _videoPlayerController != null) {
      final value = _videoPlayerController!.value;

      _playerStream._playingController.add(value.isPlaying);

      final isBufferingNow = value.playingState == PlayingState.buffering;
      _playerStream._bufferingController.add(isBufferingNow);

      if (value.hasError) {
        _playerStream._errorController.add(value.errorDescription);
      }

      if (value.size.width > 0) {
        _playerStream._widthController.add(value.size.width.toInt());
        _playerStream._heightController.add(value.size.height.toInt());
      }
    }
  }
}
