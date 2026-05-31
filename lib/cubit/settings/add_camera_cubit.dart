/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter/material.dart';

import '../../models/camera.dart';
import 'settings_common_item_cubit.dart';
import 'settings_common_item_state.dart';

part 'add_camera_state.dart';

class AddCameraCubit extends AddCameraCubitBase {
  AddCameraCubit() : super('camera');
}

class AddNvrCubit extends AddCameraCubitBase {
  AddNvrCubit() : super('nvr');
}

class AddCameraCubitBase
    extends SettingsCommonItemCubit<AddCameraState, Camera> {
  final String stateName;

  AddCameraCubitBase(this.stateName) : super(AddCameraUpdateState(stateName)) {
    loadStateDefaults();
  }

  @override
  void editData(int index, Camera item) {
    emit(state.copyWith(
      index: index,
      name: item.name,
      cameraType: item.cameraType,
      protocol: item.protocol,
      host: item.host,
      port: item.port.toString(),
      locationName: item.locationName,
      ipLocationNames: item.ipLocationNames,
      credentialName: item.credentialName,
      archiveName: item.archiveName,
    ));
  }

  @override
  void copyData(int index, Camera item) {
    editData(index, item);
    emit(
      state.copyWith(
        index: -1,
        name: 'New ${stateName[0].toUpperCase()}${stateName.substring(1)}',
      ),
    );
  }

  @override
  void reset() {
    emit(AddCameraUpdateState(stateName));
    loadStateDefaults();
  }

  @override
  void updateAutovalidateMode(AutovalidateMode? autovalidateMode) {
    emit(state.copyWith(autovalidateMode: autovalidateMode));
  }

  @override
  void updateName(String? name) {
    emit(state.copyWith(name: name));
  }

  void updateHost(String host) {
    emit(state.copyWith(host: host));
  }

  void updateCameraType(CameraType? type) {
    emit(state.copyWith(cameraType: type));
  }

  void updatePort(String? port) {
    emit(state.copyWith(port: port));
  }

  void addIpLocationName(String locationName) {
    emit(
      state.copyWith(ipLocationNames: state.ipLocationNames..add(locationName)),
    );
  }

  void removeIpLocationName(String locationName) {
    emit(
      state.copyWith(
          ipLocationNames: state.ipLocationNames..remove(locationName)),
    );
  }

  void updateLocationName(String? locationName) {
    emit(state.copyWith(locationName: locationName));
  }

  void updateCredentialName(String? credentialName) {
    emit(state.copyWith(credentialName: credentialName));
  }

  void updateArchiveName(String archiveName) {
    emit(state.copyWith(archiveName: archiveName));
  }

  @override
  Future<void> loadStateDefaults() async {
    await state.loadDefaults();
    emit(state);
  }
}
