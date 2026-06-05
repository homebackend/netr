/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart' as geocoder;
import 'package:geolocator/geolocator.dart';

part 'location_state.dart';

class LocationCubit extends Cubit<LocationStatus> {
  LocationCubit() : super(LocationStatus(LocationState.unknown));

  Future<void> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(LocationStatus(LocationState.locationServiceDisabled));
        return;
      }
    } catch (e) {
      log('Error checking for service: $e');
      emit(LocationStatus(LocationState.permissionDeniedForever));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        emit(LocationStatus(LocationState.permissionsDenied));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      emit(LocationStatus(LocationState.permissionDeniedForever));
      return;
    }

    Position position = await Geolocator.getCurrentPosition();

    if (await geocoder.isPresent()) {
      List<geocoder.Placemark> placemarks = await geocoder
          .placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        emit(LocationStatus(LocationState.locatedFully,
            longitude: position.longitude,
            latitude: position.latitude,
            altitude: position.altitude,
            country: placemarks[0].country,
            countryCode: placemarks[0].isoCountryCode,
            postalCode: placemarks[0].postalCode,
            locality: placemarks[0].locality,
            subLocality: placemarks[0].subLocality,
            administrativeArea: placemarks[0].administrativeArea,
            address: placemarks[0].toString()));
        return;
      }
    }

    emit(LocationStatus(LocationState.locatedWithCordinates,
        longitude: position.longitude,
        latitude: position.latitude,
        altitude: position.altitude));
  }
}
