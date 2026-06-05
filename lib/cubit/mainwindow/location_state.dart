/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

part of 'location_cubit.dart';

enum LocationState {
  unknown,
  locationServiceDisabled,
  permissionsDenied,
  permissionDeniedForever,
  locatedWithCordinates,
  locatedFully,
}

class LocationStatus {
  final LocationState state;
  double longitude;
  double latitude;
  double altitude;
  String? country;
  String? countryCode;
  String? postalCode;
  String? locality;
  String? subLocality;
  String? administrativeArea;
  String? address;
  LocationStatus(
    this.state, {
    this.longitude = 0.0,
    this.latitude = 0.0,
    this.altitude = 0.0,
    this.country,
    this.countryCode,
    this.postalCode,
    this.locality,
    this.subLocality,
    this.administrativeArea,
    this.address,
  });
}
