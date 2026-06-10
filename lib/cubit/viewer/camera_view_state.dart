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
  final int width;
  final int height;

  CameraViewData(
    this.location,
    this.camera,
    this.credential, {
    this.quality = StreamQuality.high,
    this.width = 0,
    this.height = 0,
    this.archive,
  });

  CameraViewData copyWith({
    Location? location,
    Camera? camera,
    Credential? credential,
    StreamQuality? quality,
    int? width,
    int? height,
  }) {
    return CameraViewData(
      location ?? this.location,
      camera ?? this.camera,
      credential ?? this.credential,
      quality: quality ?? this.quality,
      width: width ?? this.width,
      height: height ?? this.height,
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
    int? width,
    int? height,
  }) {
    CameraViewData d = state.copyWith(
      location: location,
      camera: camera,
      credential: credential,
      quality: quality,
      width: width,
      height: height,
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
  CameraViewVideoState(CameraViewData state, {int? width, int? height})
      : super(state.copyWith(width: width, height: height));

  @override
  CameraViewVideoState instantiateWith(CameraViewData d) =>
      CameraViewVideoState(d);
}

final class CameraViewDoneState extends CameraViewState {
  @override
  CameraViewState copyWith() => CameraViewDoneState();
}
