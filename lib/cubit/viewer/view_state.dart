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
sealed class ViewState {}

final class ViewInitialState extends ViewState {}

final class ViewUpdatedState extends ViewState {
  final List<Location> locations;
  final List<Credential> credentials;
  final List<Camera> cameras;
  final List<Camera> nvrs;
  final bool isFreshState;

  final Camera? selectedCamera;
  final Location? selectedLocation;
  final bool archiveView;
  final bool fullScreen;

  final List<Camera> camerasWithoutLocation = [];

  final Map<Location, List<Camera>> _mapLocationCamera = {};
  final Map<String, Location> _mapLocations = {};
  final Map<String, Credential> _mapCredentials = {};
  final Map<String, Camera> _mapCameras = {};
  final Map<String, Camera> _mapNvrs = {};

  ViewUpdatedState(
    this.locations,
    this.credentials,
    this.cameras,
    this.nvrs, {
    this.isFreshState = true,
    this.selectedCamera,
    this.selectedLocation,
    this.archiveView = false,
    this.fullScreen = false,
  }) {
    for (Location location in locations) {
      _mapLocations[location.name] = location;
      _mapLocationCamera[location] = [];
    }

    for (Camera c in cameras) {
      if (_mapLocations.containsKey(c.locationName)) {
        _mapLocationCamera[_mapLocations[c.locationName]!]?.add(c);
      } else {
        camerasWithoutLocation.add(c);
      }
    }

    for (Location location in locations) {
      _mapLocations[location.name] = location;
    }

    for (Credential credential in credentials) {
      _mapCredentials[credential.name] = credential;
    }

    for (Camera camera in cameras) {
      _mapCameras[camera.name] = camera;
    }

    for (Camera nvr in nvrs) {
      _mapNvrs[nvr.name] = nvr;
    }
  }

  List<Camera> locationCamera(Location location) {
    return _mapLocationCamera[location]!;
  }

  Location? cameraLocation(Camera camera) {
    return _mapLocations[camera.locationName];
  }

  Credential? cameraCredential(Camera camera) {
    return _mapCredentials[camera.credentialName];
  }

  Camera? cameraNvr(Camera camera) {
    return _mapNvrs[camera.archiveName];
  }

  Credential? cameraNvrCredential(Camera camera) {
    return cameraCredential(cameraNvr(selectedCamera!)!);
  }

  ViewUpdatedState copyWith({
    bool? isFreshState,
    Camera? camera,
    Location? location,
    bool? archiveView,
    bool? fullScreen,
    bool listView = false,
  }) {
    return ViewUpdatedState(
      locations,
      credentials,
      cameras,
      nvrs,
      isFreshState: listView ? true : isFreshState ?? this.isFreshState,
      selectedCamera: listView ? null : camera ?? selectedCamera,
      selectedLocation: listView ? null : location ?? selectedLocation,
      archiveView: archiveView ?? this.archiveView,
      fullScreen: fullScreen ?? this.fullScreen,
    );
  }
}
