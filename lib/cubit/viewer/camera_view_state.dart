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
  final String cameraName;
  final String locationName;
  final int count;
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
    this.count = 0,
    this.quality = StreamQuality.high,
    this.cameraIndex = -1,
    this.width = 0,
    this.height = 0,
    this.archive,
    this.startDateTime,
    String? cameraName,
    String? locationName,
  })  : cameraName = cameraName ?? camera.name,
        locationName = locationName ?? location.name;

  Map<String, dynamic> toJson() => {
        'location': location.toJson(),
        'camera': camera.toJson(),
        'credential': credential.toJson(),
        'count': count,
        'quality': quality.toString(),
        'cameraIndex': cameraIndex,
        'width': width,
        'height': height,
        'archive': archive == null ? '' : archive!.toJson(),
        'startDateTime': startDateTime.toString(),
      };

  CameraViewData copyWith({
    String? cameraName,
    String? locationName,
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
      cameraName: cameraName ?? (camera ?? this.camera).name,
      locationName: locationName ?? (location ?? this.location).name,
      count: count + 1,
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
    String? cameraName,
    String? locationName,
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
      cameraName: cameraName,
      locationName: locationName,
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

  Map<String, dynamic> toJson() => {'state': state.toJson()};
}

final class CameraViewUpdatedState extends CameraViewInitialState {
  final String url;
  final String cameraName;
  final String locationName;

  CameraViewUpdatedState(
      this.url, this.cameraName, this.locationName, super.state);

  CameraViewUpdatedState copyWithLocal(
          {String? url, String? locationName, String? cameraName}) =>
      CameraViewUpdatedState(url ?? this.url, cameraName ?? this.cameraName,
          locationName ?? this.locationName, state);

  @override
  CameraViewState instantiateWith(CameraViewData d) =>
      CameraViewUpdatedState(url, cameraName, locationName, d);
}

final class CameraViewErrorState extends CameraViewInitialState {
  final String error;

  CameraViewErrorState(this.error, super.state);

  CameraViewErrorState copyWithLocal({String? error}) =>
      CameraViewErrorState(error ?? this.error, state);

  @override
  CameraViewState instantiateWith(CameraViewData d) =>
      CameraViewErrorState(error, d);

  @override
  Map<String, dynamic> toJson() => {'error': error, ...super.toJson()};
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

  @override
  Map<String, dynamic> toJson() => {
        'bufferingState': bufferingState,
        'bufferingDone': bufferingDone,
        ...super.toJson()
      };
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

  @override
  Map<String, dynamic> toJson() => {'playing': playing, ...super.toJson()};
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
