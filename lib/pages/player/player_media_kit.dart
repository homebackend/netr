/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../cubit/mixin/camera_view_cubit_mixin.dart';
import '../../cubit/viewer/video_player_cubit.dart';
import '../../helpers/thumbnail_manager.dart';
import 'lib_helper.dart';

class CameraPlayerStreamMediaKit extends CameraPlayerStream {
  final PlayerStream stream;

  CameraPlayerStreamMediaKit(this.stream);

  @override
  Stream<bool> get buffering => stream.buffering;

  @override
  Stream<dynamic> get error => stream.error;

  @override
  Stream<int?> get height => stream.height;

  @override
  Stream<bool> get playing => stream.playing;

  @override
  Stream<int?> get width => stream.width;
}

mixin PlayerMediaKit implements LibHelper {
  late Player _player;
  late VideoController _videoController;

  @override
  void initLibHelper(BuildContext context) {
    PlayerConfiguration playerConfiguration = PlayerConfiguration(
      logLevel: MPVLogLevel.info,
      title: playerTitle,
      bufferSize: 1024 * 32,
      osc: true,
    );
    _player = Player(configuration: playerConfiguration);
    _videoController = VideoController(_player);

    startThumbnailGeneration(cameraName, locationName);
  }

  @override
  void disposeLibHelper() {
    _player.dispose();
  }

  @override
  void startThumbnailGeneration(String cameraName, String locationName) {
    if (_player.state.width == null || _player.state.width == 0) {
      log('Thumbnail generation skipped');
      return;
    }

    ThumbnailManager.generateCctvThumbnail(
      cameraName,
      locationName,
      () => _player.screenshot(format: 'image/jpeg'),
    );
  }

  @override
  CameraPlayerStream get stream => CameraPlayerStreamMediaKit(_player.stream);

  @override
  Future<void> open(BuildContext context, String url) async {
    await _player.stop();
    await _player.open(Media(url), play: true);
  }

  @override
  Future<void> stop(BuildContext context) async {
    await _player.stop();
  }

  @override
  Future<void> togglePlay() async {
    await _player.playOrPause();
  }

  @override
  Widget createVideoWidget(BuildContext context, VideoPlayerState state) {
    if (state.width > 0 && state.height > 0) {
      return SizedBox(
        width: maxWidth,
        height: maxHeight,
        child: Center(
          child: AspectRatio(
            aspectRatio: state.aspectRatio,
            child: Video(
              controller: _videoController,
              controls: null,
            ),
          ),
        ),
      );
    } else {
      initCamera(context);
      return SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: CircularProgressIndicator(
            semanticsLabel: 'Waiting for video',
          ),
        ),
      );
    }
  }
}
