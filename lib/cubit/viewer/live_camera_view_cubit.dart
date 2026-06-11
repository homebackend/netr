/*
 * Copyright (c) 2024-26 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart';
import 'package:netr/models/credential.dart';

import '../../models/camera.dart';
import '../mixin/camera_view_cubit_mixin.dart';
import 'camera_view_state.dart';
import 'view_state.dart';

class LiveCameraViewCubit extends Cubit<CameraViewState>
    with CameraViewCubitMixin {
  late List<StreamSubscription> subscriptions;
  LiveCameraViewCubit(PlayerStream playerStream, CameraViewData data)
      : super(CameraViewInitialState(data)) {
    subscriptions = subscribe(playerStream);
  }

  @override
  String get cubitName => 'LiveCameraViewCubit';

  @override
  Future<void> close() {
    for (var subscription in subscriptions) {
      subscription.cancel();
    }
    return super.close();
  }

  @override
  String getHighPath() {
    if (state is CameraViewInitialState) {
      switch ((state as CameraViewInitialState).state.camera.cameraType) {
        case CameraType.hikvision:
          return '/Streaming/Channels/101/';
      }
    }

    return '';
  }

  @override
  String getLowPath() {
    if (state is CameraViewInitialState) {
      switch ((state as CameraViewInitialState).state.camera.cameraType) {
        case CameraType.hikvision:
          return '/Streaming/Channels/102/';
      }
    }

    return '';
  }

  @override
  Camera getCamera(ViewUpdatedState state) {
    return state.selectedCamera!;
  }

  @override
  Credential getCredential(ViewUpdatedState state) {
    return state.cameraCredential(state.selectedCamera!)!;
  }
}
