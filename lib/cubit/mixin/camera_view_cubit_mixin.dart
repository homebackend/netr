/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/camera.dart';
import '../../models/credential.dart';
import '../viewer/camera_view_cubit.dart';
import '../viewer/camera_view_state.dart';
import '../viewer/view_state.dart';

abstract class CameraPlayerStream {
  Stream<bool> get buffering;
  Stream<bool> get playing;
  Stream<dynamic> get error;
  Stream<int?> get width;
  Stream<int?> get height;
}

mixin CameraViewCubitMixin on Cubit<CameraViewState>
    implements CameraViewCubit {
  List<StreamSubscription> subscribe(CameraPlayerStream playerStream) {
    if (state is CameraViewInitialState) {
      List<StreamSubscription> l = [];

      l.add(playerStream.buffering.listen((buffering) {
        double done = buffering ? 50.0 : 100.0;
        emit(CameraViewBufferingState(done, buffering, _data()));
      }, onError: (error) {
        log('Error during buffering: $error');
        emit(CameraViewErrorState(error, _data()));
      }, onDone: () {
        emit(CameraViewBufferingState(100.0, true, _data()));
      }));

      l.add(playerStream.playing.listen((playing) {
        emit(CameraViewPlayingState(playing, _data()));
      }, onError: (error) {
        log('Error during playing: $error');
        emit(CameraViewErrorState(error, _data()));
      }, onDone: () {
        emit(CameraViewDoneState());
      }));

      l.add(playerStream.error.listen((error) {
        log('Error reported: $error');
        emit(CameraViewErrorState(error, _data()));
      }));

      l.add(playerStream.width.listen((width) {
        if (width == null) {
          return;
        }

        log('Width is $width');
        emit(CameraViewVideoState(_data(), width: width.toDouble()));
      }));

      l.add(playerStream.height.listen((height) {
        if (height == null) {
          return;
        }

        log('Height is $height');
        emit(CameraViewVideoState(_data(), height: height.toDouble()));
      }));

      return l;
    }

    return [];
  }

  CameraViewData _data() {
    return (state as CameraViewInitialState).state;
  }

  Future<void> closeStreams(List<StreamSubscription> subscriptions) async {
    for (var subscription in subscriptions) {
      await subscription.cancel();
    }

    return super.close();
  }

  String _getProtocol() {
    if (state is CameraViewInitialState) {
      switch ((state as CameraViewInitialState).state.camera.cameraType) {
        case CameraType.hikvision:
          return 'rtsp';
      }
    }
    return '';
  }

  String _getCredential() {
    if (state is CameraViewInitialState) {
      Credential credential =
          (state as CameraViewInitialState).state.credential;
      if (credential.user.isNotEmpty && credential.password.isNotEmpty) {
        return '${Uri.encodeComponent(credential.user)}:${Uri.encodeComponent(credential.password)}@';
      }
    }

    return '';
  }

  String _getHost() {
    if (state is CameraViewInitialState) {
      return (state as CameraViewInitialState).state.camera.host;
    }

    return '';
  }

  String _getPort() {
    if (state is CameraViewInitialState) {
      return (state as CameraViewInitialState).state.camera.port.toString();
    }

    return '';
  }

  @override
  String getUrlPath() {
    if (state is CameraViewInitialState) {
      CameraViewInitialState s = state as CameraViewInitialState;
      return switch (s.state.quality) {
        StreamQuality.high => getHighPath(),
        StreamQuality.low => getLowPath(),
      };
    }

    return '';
  }

  @protected
  String getHighPath();

  @protected
  String getLowPath();

  @protected
  Camera getCamera(ViewUpdatedState state);

  @protected
  Credential getCredential(ViewUpdatedState state);

  @override
  Future<void> updateStreamQuality(StreamQuality streamQuality) async {
    if (state is CameraViewInitialState) {
      CameraViewInitialState s = state as CameraViewInitialState;
      emit(s.copyWith(quality: streamQuality));
    }
  }

  @override
  Future<void> updateCamera(ViewUpdatedState vuState,
      {DateTime? startDateTime}) async {
    if (state is CameraViewInitialState) {
      CameraViewInitialState s = state as CameraViewInitialState;
      emit(s.copyWith(
        cameraName: vuState.selectedCamera!.name,
        locationName: vuState.selectedLocation!.name,
        camera: getCamera(vuState),
        location: vuState.selectedLocation!,
        credential: getCredential(vuState),
        cameraInddex: vuState.selectedCamera!.archiveIndex,
        quality: vuState.streamQuality,
        startDateTime: startDateTime ?? s.state.startDateTime,
      ));
    }

    await getStreamUrl();
  }

  @override
  void emitUrlState(
      {String? cameraName, String? locationName, String? host, int? port}) {
    if (state is CameraViewInitialState) {
      CameraViewInitialState s = state as CameraViewInitialState;
      String url =
          '${_getProtocol()}://${_getCredential()}${host ?? _getHost()}:${port ?? _getPort()}${getUrlPath()}';
      log('Url: $url');
      emit(CameraViewUpdatedState(url, cameraName ?? s.state.cameraName,
          locationName ?? s.state.locationName, s.state));
    }
  }

  @override
  Future<void> getStreamUrl({String? cameraName, String? locationName}) async {
    if (state is CameraViewInitialState) {
      CameraViewInitialState s = state as CameraViewInitialState;
      Camera c = s.state.camera;
      // Handle the case where camera is available locally
      if (c.locationName == s.state.physicalLocationName ||
          c.ipLocationNames.any((l) => l == s.state.physicalLocationName)) {
        emitUrlState(cameraName: cameraName, locationName: locationName);
      } else {
        // Handle the case where camera is accessed via SSH
        s.state.sshCubit.getLocalPort(
          s.state.camera.locationName,
          s.state.camera.host,
          s.state.camera.port,
        );
      }
    }
  }
}
