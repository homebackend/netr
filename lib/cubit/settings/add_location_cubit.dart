/*
 * Copyright (c) 2024-26 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'dart:developer';
import 'dart:io';

import 'package:dartssh2_plus/dartssh2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

import '../../models/location.dart';
import 'settings_common_item_cubit.dart';
import 'settings_common_item_state.dart';

part 'add_location_state.dart';

class AddLocationCubit
    extends SettingsCommonItemCubit<AddLocationState, Location> {
  AddLocationCubit() : super(AddLocationUpdateState()) {
    loadStateDefaults();
  }

  AddLocationCubit.from(Location location)
      : super(AddLocationUpdateState(
          name: location.name,
          useSshForNonLocal: location.useSshForNonLocal,
          sshHost: location.sshHost ?? '',
          sshPort: location.sshPort.toString(),
          sshUser: location.sshUser ?? '',
          sshPrivateKey: location.sshPrivateKey ?? '',
        ));

  @override
  void editData(int index, Location item) {
    emit(state.copyWith(
      index: index,
      name: item.name,
      longitude: item.longitude.toString(),
      latitude: item.latitude.toString(),
      locationFromAddress: false,
      fetchingLocationFromAddress: false,
      locationFromAddressError: '',
      address: '',
      distance: item.distance,
      useSshForNonLocal: item.useSshForNonLocal,
      sshHost: item.sshHost,
      sshPort: item.sshPort.toString(),
      sshUser: item.sshUser,
      sshPrivateKey: item.sshPrivateKey,
    ));
  }

  @override
  void copyData(int index, Location item) {
    editData(index, item);
    emit(state.copyWith(index: -1, name: 'New Location'));
  }

  @override
  void updateAutovalidateMode(AutovalidateMode? autovalidateMode) {
    emit(state.copyWith(autovalidateMode: autovalidateMode));
  }

  @override
  void updateName(String? name) {
    emit(state.copyWith(name: name));
  }

  void updateLongitude(String? longitude) {
    emit(state.copyWith(longitude: longitude ?? ''));
  }

  void updateLatitude(String? latitude) {
    emit(state.copyWith(latitude: latitude ?? ''));
  }

  void updateLocationFromAddress(bool? locationFromAddress) {
    emit(state.copyWith(locationFromAddress: locationFromAddress));
  }

  void updateAddress(String? address) {
    emit(state.copyWith(address: address));
  }

  void updateLocation() async {
    try {
      emit(state.copyWith(fetchingLocationFromAddress: true));
      List<geocoding.Location> locations = await geocoding.locationFromAddress(
        state.address,
      );

      emit(state.copyWith(
        fetchingLocationFromAddress: false,
        longitude: locations[0].longitude.toString(),
        latitude: locations[0].latitude.toString(),
        locationFromAddressError: '',
      ));
    } catch (e) {
      log('Error getting locationFromAddress: $e');
      emit(state.copyWith(
        fetchingLocationFromAddress: false,
        locationFromAddressError:
            'Error fetching location data. Please retry later.',
      ));
    }
  }

  void updateDistance(double value) {
    emit(state.copyWith(
      distance: LocationDistance.values[value.round() - 1],
    ));
  }

  void updateUseSshForNonLocal(bool? useSshForNonLocal) {
    emit(state.copyWith(useSshForNonLocal: useSshForNonLocal));
  }

  void updateSshHost(String? sshHost) {
    emit(state.copyWith(sshHost: sshHost));
  }

  void updateSshPort(String? sshPort) {
    emit(state.copyWith(sshPort: sshPort ?? '22'));
  }

  void updateSshUser(String? sshUser) {
    emit(state.copyWith(sshUser: sshUser));
  }

  void addSshPrivateKey() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        dialogTitle: 'Please select a SSH private key file',
        lockParentWindow: true,
      );

      if (result != null) {
        emit(state.copyWith(
          sshConnectionStatus: SshConnectionStatus.untested,
        ));

        File file = File(result.files.single.path!);
        String text = await file.readAsString();
        emit(state.copyWith(sshPrivateKey: text));
      } else {
        emit(state.copyWith(sshPrivateKey: ''));
      }
    } catch (e) {
      log('Error reading private key: $e');
      emit(state.copyWith(sshPrivateKey: ''));
    }
  }

  void updateSshPrivateKey(String? sshPrivateKey) {
    emit(state.copyWith(sshPrivateKey: sshPrivateKey));
  }

  void testSshConnection() async {
    emit(state.copyWith(testingSshConnection: true));
    try {
      final socket = await SSHSocket.connect(
        state.sshHost,
        int.parse(state.sshPort),
      );

      final sshClient = SSHClient(
        socket,
        username: state.sshUser,
        identities: [...SSHKeyPair.fromPem(state.sshPrivateKey)],
      );

      await sshClient.authenticated;

      sshClient.close();
      await sshClient.done;

      emit(state.copyWith(
        testingSshConnection: false,
        sshConnectionStatus: SshConnectionStatus.successful,
      ));
    } catch (e) {
      log('Failure testing connection with ${state.sshHost}:${state.sshPort} -> $e');
      emit(state.copyWith(
        testingSshConnection: false,
        sshConnectionStatus: SshConnectionStatus.failed,
      ));
    }
  }

  @override
  void reset() {
    emit(AddLocationUpdateState());
    loadStateDefaults();
  }

  @override
  Future<void> loadStateDefaults() async {
    await state.loadDefaults();
    emit(state);
  }
}
