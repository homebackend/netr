/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

part of 'live_view_cubit.dart';

@immutable
sealed class LiveViewState {}

final class LiveViewInitialState extends LiveViewState {}

final class LiveViewUpdatedState extends LiveViewState {
  final List<Location> locations;
  final List<Credential> credentials;
  final List<Camera> cameras;
  final List<Camera> nvrs;
  final bool isFreshState;

  final Camera? selectedCamera;
  final Location? selectedLocation;
  final bool fullScreen;

  final List<Camera> camerasWithoutLocation = [];

  final Map<Location, List<Camera>> _mapLocationCamera = {};
  final Map<String, Location> _mapLocations = {};
  final Map<String, Credential> _mapCredentials = {};
  final Map<String, Camera> _mapCameras = {};
  final Map<String, Camera> _mapNvrs = {};

  LiveViewUpdatedState(
    this.locations,
    this.credentials,
    this.cameras,
    this.nvrs, {
    this.isFreshState = true,
    this.selectedCamera,
    this.selectedLocation,
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

  LiveViewUpdatedState copyWith({
    bool? isFreshState,
    Camera? camera,
    Location? location,
    bool listView = false,
    bool fullScreen = false,
  }) {
    return LiveViewUpdatedState(
      locations,
      credentials,
      cameras,
      nvrs,
      isFreshState:
          listView || fullScreen ? true : isFreshState ?? this.isFreshState,
      selectedCamera: listView ? null : camera ?? selectedCamera,
      selectedLocation: listView ? null : location ?? selectedLocation,
      fullScreen: fullScreen,
    );
  }
}
