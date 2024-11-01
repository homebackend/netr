/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../mixin/preferences.dart';
import '../../models/camera.dart';
import '../../models/credential.dart';
import '../../models/location.dart';

part 'live_view_state.dart';

class LiveViewCubit extends Cubit<LiveViewState> with Preferences {
  late List<Camera> cameras;
  late List<Camera> nvrs;
  late List<Location> locations;
  late List<Credential> credentials;

  LiveViewCubit() : super(LiveViewInitialState()) {
    _load();
  }

  Future<void> _load() async {
    cameras = await loadItems(Preferences.keyCameras, Camera.fromJson);
    nvrs = await loadItems(Preferences.keyNvrs, Camera.fromJson);
    locations = await loadItems(Preferences.keyLocations, Location.fromJson);
    credentials =
        await loadItems(Preferences.keyCredentials, Credential.fromJson);

    emit(LiveViewUpdatedState(locations, credentials, cameras, nvrs));
  }

  void updateSelectedCameraAndLocation(Camera camera, Location location) {
    if (state is LiveViewUpdatedState) {
      emit((state as LiveViewUpdatedState).copyWith(
        camera: camera,
        location: location,
      ));
    }
  }

  void next() {
    if (state is LiveViewUpdatedState) {
      LiveViewUpdatedState state = this.state as LiveViewUpdatedState;
      if (state.selectedLocation == null || state.selectedCamera == null) {
        return;
      }

      Camera nextCamera = cameras[
          (cameras.indexOf(state.selectedCamera!) + 1) % cameras.length];
      Location nextLocation = state.cameraLocation(nextCamera)!;
      emit(state.copyWith(
        camera: nextCamera,
        location: nextLocation,
        isFreshState: false,
      ));
    }
  }

  void previous() {
    if (state is LiveViewUpdatedState) {
      LiveViewUpdatedState state = this.state as LiveViewUpdatedState;
      if (state.selectedLocation == null || state.selectedCamera == null) {
        return;
      }

      Camera prevCamera = cameras[
          (cameras.indexOf(state.selectedCamera!) - 1) % cameras.length];
      Location prevLocation = locations[
          (locations.indexOf(state.selectedLocation!) - 1) % locations.length];
      emit(state.copyWith(
        camera: prevCamera,
        location: prevLocation,
        isFreshState: false,
      ));
    }
  }
}
