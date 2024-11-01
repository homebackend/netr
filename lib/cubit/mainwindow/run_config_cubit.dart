/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:great_circle_distance_calculator/great_circle_distance_calculator.dart';

import '../../mixin/preferences.dart';
import '../../models/camera.dart';
import '../../models/location.dart';

part 'run_config_state.dart';

class RunConfigCubit extends Cubit<RunConfigState> with Preferences {
  static const String _keyLocation = 'run.location';
  static const String _keyQuality = 'run.quality';
  static const String _keyArchiveDate = 'run.archiveDate';

  late List<Location> locations;

  RunConfigCubit() : super(RunConfigUpdatedState(archiveDate: DateTime.now())) {
    _load();
  }

  Future<void> _load() async {
    locations = await loadItems(Preferences.keyLocations, Location.fromJson);

    String? dateTimeString = await loadString(_keyArchiveDate);
    DateTime? archiveDate;

    if (dateTimeString == null) {
      archiveDate = state.archiveDate;
    } else {
      archiveDate = DateTime.tryParse(dateTimeString!);
    }

    emit(state.copyWith(
      location: await loadString(_keyLocation),
      locationSource: LocationSource.lastUsed,
      quality: await loadEnum(_keyQuality, StreamQuality.values),
      archiveDate: archiveDate,
    ));
  }

  Future<void> updateLocation(
    String location,
    LocationSource locationSource,
  ) async {
    await saveString(_keyLocation, location);
    emit(state.copyWith(
      location: location,
      locationSource: locationSource,
    ));
  }

  Future<void> updateGps(double longitude, double latitude) async {
    for (Location location in locations) {
      var gcd = GreatCircleDistance.fromDegrees(
        latitude1: location.latitude,
        longitude1: location.longitude,
        latitude2: latitude,
        longitude2: longitude,
      );

      double distance = gcd.sphericalLawOfCosinesDistance();
      log('Current location distance from ${location.name} is $distance.');

      if (location.distance.value >= distance) {
        log('Current location is detected as ${location.name}.');
        return await updateLocation(location.name, LocationSource.gps);
      }
    }
  }

  Future<void> updateQuality(StreamQuality quality) async {
    await saveEnum(_keyQuality, quality);
    emit(state.copyWith(quality: quality));
  }

  Future<void> updateArchiveDate(DateTime? date) async {
    if (date == null) {
      return;
    }

    DateTime archiveDate = DateTime(
      date.year,
      date.month,
      date.day,
      state.archiveDate.hour,
      state.archiveDate.minute,
    );

    await updateArchiveDateTime(archiveDate);
  }

  Future<void> updateArchiveTime(TimeOfDay? timeOfDay) async {
    if (timeOfDay == null) {
      return;
    }

    DateTime archiveDate = DateTime(
      state.archiveDate.year,
      state.archiveDate.month,
      state.archiveDate.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );

    if (archiveDate.isAfter(DateTime.now())) {
      archiveDate = DateUtils.dateOnly(archiveDate);
    }

    await updateArchiveDateTime(archiveDate);
  }

  Future<void> updateArchiveDateTime(DateTime? archiveDate) async {
    if (archiveDate == null) {
      return;
    }

    await saveString(_keyArchiveDate, archiveDate.toIso8601String());
    emit(state.copyWith(archiveDate: archiveDate));
  }
}
