/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controllers/full_screen_controller.dart';
import '../../models/camera.dart';
import '../../models/credential.dart';
import '../../models/location.dart';
import '../viewer/view_cubit.dart';
import '../viewer/view_state.dart';

mixin ViewCubitMixin on Cubit<ViewState> implements ViewCubit {
  @override
  void emitState(
    List<Location> locations,
    List<Camera> cameras,
    List<Camera> nvrs,
    List<Credential> credentials,
  ) {
    emit(ViewUpdatedState(locations, credentials, cameras, nvrs));
  }

  @override
  void updateSelectedCameraAndLocation(
    Camera camera,
    Location location,
    bool isFreshState, {
    bool? fullScreen,
    bool? archiveView,
  }) {
    if (state is ViewUpdatedState) {
      if (fullScreen ?? false) {
        FullScreenController.enter();
      }

      ViewUpdatedState state = this.state as ViewUpdatedState;
      log('$cubitName: ${camera.name}');
      emit(state.copyWith(
        camera: camera,
        location: location,
        isFreshState: isFreshState,
        fullScreen: fullScreen ?? state.fullScreen,
        archiveView: archiveView ?? state.archiveView,
      ));
    }
  }

  void _adjCamera(int step, bool Function(Location l, Camera c)? criteria) {
    if (state is ViewUpdatedState) {
      ViewUpdatedState state = this.state as ViewUpdatedState;
      if (state.selectedLocation == null || state.selectedCamera == null) {
        return;
      }

      int cameraIndex = state.cameras.indexOf(state.selectedCamera!);
      int cameraLength = state.cameras.length;
      // Try all other cameras to see if any one satisfies criteria
      // If none satisfy do not emit
      for (int i = 1; i < cameraLength; i++) {
        int index = (step * i + cameraIndex) % cameraLength;
        Camera nextCamera = state.cameras[index];
        Location nextLocation = state.cameraLocation(nextCamera)!;
        if (criteria == null || criteria(nextLocation, nextCamera)) {
          emit(state.copyWith(
            camera: nextCamera,
            location: nextLocation,
            isFreshState: false,
          ));
          return;
        }
      }
    }
  }

  @protected
  void nextCamera({bool Function(Location l, Camera c)? criteria}) {
    _adjCamera(1, criteria);
  }

  @protected
  void previousCamera({bool Function(Location l, Camera c)? criteria}) {
    _adjCamera(-1, criteria);
  }

  @override
  void back() {
    if (state is ViewUpdatedState) {
      ViewUpdatedState state = this.state as ViewUpdatedState;
      if (state.fullScreen) {
        FullScreenController.exit();
      }
      emit(state.copyWith(listView: true, fullScreen: false));
    }
  }

  @override
  void toggleFullScreen() {
    if (state is ViewUpdatedState) {
      ViewUpdatedState state = this.state as ViewUpdatedState;
      if (state.fullScreen) {
        FullScreenController.exit();
      } else {
        FullScreenController.enter();
      }
      emit(state.copyWith(fullScreen: !state.fullScreen, isFreshState: true));
    }
  }
}
