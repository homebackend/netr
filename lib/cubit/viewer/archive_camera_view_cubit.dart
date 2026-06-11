/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:media_kit/media_kit.dart';
import 'package:netr/models/credential.dart';

import '../../models/camera.dart';
import '../mixin/camera_view_cubit_mixin.dart';
import 'camera_view_state.dart';
import 'view_state.dart';

class ArchiveCameraViewCubit extends Cubit<CameraViewState>
    with CameraViewCubitMixin {
  late List<StreamSubscription> subscriptions;
  ArchiveCameraViewCubit(PlayerStream playerStream, CameraViewData data)
      : super(CameraViewInitialState(data)) {
    subscriptions = subscribe(playerStream);
  }

  @override
  String get cubitName => 'ArchiveCameraViewCubit';

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
      CameraViewInitialState s = state as CameraViewInitialState;
      switch (s.state.camera.cameraType) {
        case CameraType.hikvision:
          return '/Streaming/tracks/${s.state.cameraIndex}01?starttime=${DateFormat("yyyyMMdd'T'kkmm'00z'").format(s.state.startDateTime!)}';
      }
    }

    return '';
  }

  @override
  String getLowPath() {
    return getHighPath();
  }

  @override
  Camera getCamera(ViewUpdatedState state) {
    return state.cameraNvr(state.selectedCamera!)!;
  }

  @override
  Credential getCredential(ViewUpdatedState state) {
    return state.cameraNvrCredential(state.selectedCamera!)!;
  }
}
