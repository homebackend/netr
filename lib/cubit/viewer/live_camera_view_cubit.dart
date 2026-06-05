/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart';

import '../../models/camera.dart';
import '../../models/credential.dart';
import '../../models/location.dart';

part 'live_camera_view_state.dart';

class LiveCameraViewCubit extends Cubit<LiveCameraViewState> {
  PlayerStream playerStream;
  Camera camera;
  Location location;
  Credential credential;
  Camera? archive;
  StreamQuality quality;
  int width = 0;
  int height = 0;

  late StreamSubscription bufferingStream;
  late StreamSubscription playingStream;
  late StreamSubscription errorStream;
  late StreamSubscription widthStream;
  late StreamSubscription heightStream;

  LiveCameraViewCubit(
    this.playerStream,
    this.camera,
    this.location,
    this.credential,
    this.quality, {
    this.archive,
  }) : super(LiveCameraViewState()) {
    bufferingStream = playerStream.buffering.listen((buffering) {
      if (buffering) {
        emit(LiveCameraViewBufferingState(50.0, false));
      } else {
        emit(LiveCameraViewBufferingState(100.0, true));
      }
    }, onError: (error) {
      emit(LiveCameraViewErrorState(error));
    }, onDone: () {
      emit(LiveCameraViewBufferingState(100.0, true));
    });

    playingStream = playerStream.playing.listen((playing) {
      emit(LiveCameraViewPlayingState(playing));
    }, onError: (error) {
      emit(LiveCameraViewErrorState(error));
    }, onDone: () {
      emit(LiveCameraViewDoneState());
    });

    errorStream = playerStream.error.listen((error) {
      emit(LiveCameraViewErrorState(error));
    });

    widthStream = playerStream.width.listen((width) {
      if (width == null) {
        return;
      }

      log('Width is $width');
      this.width = width;
      emit(LiveCameraViewVideoState(width, height));
    });

    heightStream = playerStream.height.listen((height) {
      if (height == null) {
        return;
      }

      log('Height is $height');
      this.height = height;
      emit(LiveCameraViewVideoState(width, height));
    });
  }

  @override
  Future<void> close() {
    bufferingStream.cancel();
    playingStream.cancel();
    errorStream.cancel();
    widthStream.cancel();
    heightStream.cancel();

    return super.close();
  }

  String _getProtocol() {
    switch (camera.cameraType) {
      case CameraType.hikvision:
        return 'rtsp';
    }
  }

  String _getHighPath() {
    switch (camera.cameraType) {
      case CameraType.hikvision:
        return '/Streaming/Channels/101/';
    }
  }

  String _getLowPath() {
    switch (camera.cameraType) {
      case CameraType.hikvision:
        return '/Streaming/Channels/102/';
    }
  }

  Future<void> updateCamera(
    Camera camera,
    Location location,
    Credential credential,
    Camera? archive,
  ) async {
    this.camera = camera;
    this.location = location;
    this.credential = credential;
    this.archive = archive;

    await getStreamUrl();
  }

  Future<void> getStreamUrl() async {
    String url = '${_getProtocol()}://';
    if (credential.user.isNotEmpty && credential.password.isNotEmpty) {
      url +=
          '${Uri.encodeComponent(credential.user)}:${Uri.encodeComponent(credential.password)}@';
    }

    String path = switch (quality) {
      StreamQuality.high => _getHighPath(),
      StreamQuality.low => _getLowPath(),
    };

    url += '${camera.host}:${camera.port}$path';
    log('Url: $url');
    emit(LiveCameraViewUpdatedState(url));
  }
}
