/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter/material.dart';

import '../../models/camera.dart';
import '../../models/credential.dart';
import '../../models/location.dart';

@immutable
abstract class CameraViewState {
  CameraViewState copyWith();
}

class CameraViewData {
  final Camera camera;
  final Location location;
  final Credential credential;
  final Camera? archive;
  final StreamQuality quality;
  final int cameraIndex;
  final double width;
  final double height;
  final DateTime? startDateTime;

  CameraViewData(
    this.location,
    this.camera,
    this.credential, {
    this.quality = StreamQuality.high,
    this.cameraIndex = -1,
    this.width = 0,
    this.height = 0,
    this.archive,
    this.startDateTime,
  });

  CameraViewData copyWith({
    Location? location,
    Camera? camera,
    Credential? credential,
    StreamQuality? quality,
    int? cameraIndex,
    double? width,
    double? height,
    DateTime? startDateTime,
  }) {
    return CameraViewData(
      location ?? this.location,
      camera ?? this.camera,
      credential ?? this.credential,
      quality: quality ?? this.quality,
      cameraIndex: cameraIndex ?? this.cameraIndex,
      width: width ?? this.width,
      height: height ?? this.height,
      startDateTime: startDateTime ?? this.startDateTime,
    );
  }
}

final class CameraViewInitialState extends CameraViewState {
  final CameraViewData state;

  CameraViewInitialState(this.state);

  @override
  CameraViewState copyWith({
    Location? location,
    Camera? camera,
    Credential? credential,
    StreamQuality? quality,
    int? cameraInddex,
    double? width,
    double? height,
    DateTime? startDateTime,
  }) {
    CameraViewData d = state.copyWith(
      location: location,
      camera: camera,
      credential: credential,
      quality: quality,
      cameraIndex: cameraInddex,
      width: width,
      height: height,
      startDateTime: startDateTime,
    );
    return CameraViewInitialState(d);
  }

  CameraViewState instantiateWith(CameraViewData d) =>
      CameraViewInitialState(d);
}

final class CameraViewUpdatedState extends CameraViewInitialState {
  final String url;

  CameraViewUpdatedState(this.url, super.state);

  CameraViewUpdatedState copyWithLocal({String? url}) =>
      CameraViewUpdatedState(url ?? this.url, state);

  @override
  CameraViewState instantiateWith(CameraViewData d) =>
      CameraViewUpdatedState(url, d);
}

final class CameraViewErrorState extends CameraViewState {
  final String error;

  CameraViewErrorState(this.error);

  @override
  CameraViewState copyWith({String? error}) {
    return CameraViewErrorState(error ?? this.error);
  }
}

final class CameraViewBufferingState extends CameraViewInitialState {
  final double bufferingState;
  final bool bufferingDone;

  CameraViewBufferingState(
      this.bufferingState, this.bufferingDone, super.state);

  CameraViewState copyWithLocal({
    double? bufferingState,
    bool? bufferingDone,
  }) {
    return CameraViewBufferingState(
      bufferingState ?? this.bufferingState,
      bufferingDone ?? this.bufferingDone,
      state,
    );
  }

  @override
  CameraViewBufferingState instantiateWith(CameraViewData d) =>
      CameraViewBufferingState(bufferingState, bufferingDone, d);
}

final class CameraViewPlayingState extends CameraViewInitialState {
  final bool playing;

  CameraViewPlayingState(this.playing, super.state);

  CameraViewPlayingState copyWithLocal({bool? playing}) {
    return CameraViewPlayingState(playing ?? this.playing, state);
  }

  @override
  CameraViewPlayingState instantiateWith(CameraViewData d) =>
      CameraViewPlayingState(playing, d);
}

final class CameraViewVideoState extends CameraViewInitialState {
  CameraViewVideoState(CameraViewData state, {double? width, double? height})
      : super(state.copyWith(width: width, height: height));

  @override
  CameraViewVideoState instantiateWith(CameraViewData d) =>
      CameraViewVideoState(d);
}

final class CameraViewDoneState extends CameraViewState {
  @override
  CameraViewState copyWith() => CameraViewDoneState();
}
