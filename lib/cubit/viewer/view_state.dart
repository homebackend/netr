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
sealed class ViewState {
  Map<String, dynamic> toJson() => {};
}

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
  final StreamQuality streamQuality;

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
    this.streamQuality = StreamQuality.high,
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

  @override
  Map<String, dynamic> toJson() {
    return {
      'isFreshState': isFreshState,
      'selectedCamera':
          selectedCamera == null ? 'null' : selectedCamera!.toJson(),
      'selectedLocation':
          selectedLocation == null ? 'null' : selectedLocation!.toJson(),
      'archiveView': archiveView,
      'fullScreen': fullScreen,
      'streamQuality': streamQuality.toString(),
    };
  }

  Camera? nameCamera(String cameraName) => _mapCameras[cameraName];
  Location? nameLocation(String locationName) => _mapLocations[locationName];

  Location? cameraLocation(Camera camera) => nameLocation(camera.locationName);
  Camera? cameraNvr(Camera camera) => _mapNvrs[camera.archiveName];
  Credential? cameraCredential(Camera camera) =>
      _mapCredentials[camera.credentialName];
  Credential? cameraNvrCredential(Camera camera) =>
      cameraCredential(cameraNvr(selectedCamera!)!);

  List<Location> cameraIpLocations(Camera camera) => camera.ipLocationNames
      .map((l) => nameLocation(l))
      .whereType<Location>()
      .toList();
  List<Camera> locationCameras(Location location) =>
      _mapLocationCamera[location]!;

  ViewUpdatedState copyWith({
    bool? isFreshState,
    Camera? camera,
    Location? location,
    bool? archiveView,
    bool? fullScreen,
    bool listView = false,
    StreamQuality? streamQuality,
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
      streamQuality: streamQuality ?? this.streamQuality,
    );
  }
}
