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
import 'package:media_kit/media_kit.dart';

import '../../models/camera.dart';
import '../../models/credential.dart';
import '../viewer/camera_view_cubit.dart';
import '../viewer/camera_view_state.dart';
import '../viewer/view_state.dart';

mixin CameraViewCubitMixin on Cubit<CameraViewState>
    implements CameraViewCubit {
  List<StreamSubscription> subscribe(PlayerStream playerStream) {
    if (state is CameraViewInitialState) {
      CameraViewInitialState s = state as CameraViewInitialState;
      CameraViewData d = s.state;

      StreamSubscription bufferingStream =
          playerStream.buffering.listen((buffering) {
        if (buffering) {
          emit(CameraViewBufferingState(50.0, false, d));
        } else {
          emit(CameraViewBufferingState(100.0, true, d));
        }
      }, onError: (error) {
        emit(CameraViewErrorState(error));
      }, onDone: () {
        emit(CameraViewBufferingState(100.0, true, d));
      });

      StreamSubscription playingStream = playerStream.playing.listen((playing) {
        emit(CameraViewPlayingState(playing, d));
      }, onError: (error) {
        emit(CameraViewErrorState(error));
      }, onDone: () {
        emit(CameraViewDoneState());
      });

      StreamSubscription errorStream = playerStream.error.listen((error) {
        emit(CameraViewErrorState(error));
      });

      StreamSubscription widthStream = playerStream.width.listen((width) {
        if (width == null) {
          return;
        }

        log('Width is $width');
        emit(CameraViewVideoState(d, width: width.toDouble()));
      });

      StreamSubscription heightStream = playerStream.height.listen((height) {
        if (height == null) {
          return;
        }

        log('Height is $height');
        emit(CameraViewVideoState(d, height: height.toDouble()));
      });

      return [
        bufferingStream,
        playingStream,
        errorStream,
        widthStream,
        heightStream,
      ];
    }

    return [];
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
  Future<void> updateCamera(ViewUpdatedState vuState,
      {DateTime? startDateTime}) async {
    if (state is CameraViewInitialState) {
      CameraViewInitialState s = state as CameraViewInitialState;
      log('$cubitName: ${getCamera(vuState).name}');
      emit(s.copyWith(
        camera: getCamera(vuState),
        location: vuState.selectedLocation!,
        credential: getCredential(vuState),
        cameraInddex: vuState.selectedCamera!.archiveIndex,
        startDateTime: startDateTime ?? s.state.startDateTime,
      ));
    }

    await getStreamUrl();
  }

  @override
  Future<void> getStreamUrl() async {
    if (state is CameraViewInitialState) {
      String url =
          '${_getProtocol()}://${_getCredential()}${_getHost()}:${_getPort()}${getUrlPath()}';
      log('Url: $url');
      emit(
          CameraViewUpdatedState(url, (state as CameraViewInitialState).state));
    }
  }
}
