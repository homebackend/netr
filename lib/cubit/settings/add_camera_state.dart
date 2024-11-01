/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

part of 'add_camera_cubit.dart';

sealed class AddCameraState extends SettingsCommonItemState {
  CameraType cameraType;
  String protocol;
  String host;
  String port;
  List<String> ipLocationNames;
  String locationName;
  String credentialName;
  String archiveName;

  AddCameraState(
    super.stateName, {
    super.autovalidateMode,
    super.index,
    super.name,
    this.cameraType = CameraType.hikvision,
    this.protocol = '',
    this.host = '',
    this.port = '',
    this.ipLocationNames = const [],
    this.locationName = '',
    this.credentialName = '',
    this.archiveName = '',
  });

  @override
  Future<void> loadDefaults() async {
    await super.loadDefaults();
    cameraType = await loadEnum('$stateName.cameraType', CameraType.values);
    protocol = await loadString('$stateName.protocol') ?? '';
    host = await loadString('$stateName.host') ?? '';
    port = await loadString('$stateName.port') ?? '';
    ipLocationNames = await loadStringList('$stateName.ipLocationNames');
    locationName = await loadString('$stateName.locationName') ?? '';
    credentialName = await loadString('$stateName.credentialName') ?? '';
    archiveName = await loadString('$stateName.archiveName') ?? '';
  }

  @override
  Future<void> saveDefaults() async {
    await super.saveDefaults();
    await saveEnum('$stateName.cameraType', cameraType);
    await saveString('$stateName.protocol', protocol);
    await saveString('$stateName.host', host);
    await saveString('$stateName.port', port);
    await saveStringList('$stateName.ipLocationNames', ipLocationNames);
    await saveString('$stateName.locationName', locationName);
    await saveString('$stateName.credentialName', credentialName);
    await saveString('$stateName.archiveName', archiveName);
  }

  AddCameraState copyWith({
    AutovalidateMode? autovalidateMode,
    int? index,
    String? name,
    CameraType? cameraType,
    String? protocol,
    String? host,
    String? port,
    List<String>? ipLocationNames,
    String? locationName,
    String? credentialName,
    String? archiveName,
  });
}

final class AddCameraUpdateState extends AddCameraState {
  AddCameraUpdateState(
    super.stateName, {
    shouldLoadDefault = false,
    super.autovalidateMode,
    super.index,
    super.name,
    super.cameraType,
    super.protocol,
    super.host,
    super.port,
    super.ipLocationNames,
    super.locationName,
    super.credentialName,
    super.archiveName,
  });

  @override
  AddCameraState copyWith({
    AutovalidateMode? autovalidateMode,
    int? index,
    String? name,
    CameraType? cameraType,
    String? protocol,
    String? host,
    String? port,
    List<String>? ipLocationNames,
    String? locationName,
    String? credentialName,
    String? archiveName,
  }) {
    return AddCameraUpdateState(
      stateName,
      autovalidateMode: autovalidateMode ?? this.autovalidateMode,
      index: index ?? this.index,
      name: name ?? this.name,
      cameraType: cameraType ?? this.cameraType,
      protocol: protocol ?? this.protocol,
      host: host ?? this.host,
      port: port ?? this.port,
      ipLocationNames: ipLocationNames ?? this.ipLocationNames,
      locationName: locationName ?? this.locationName,
      credentialName: credentialName ?? this.credentialName,
      archiveName: archiveName ?? this.archiveName,
    );
  }
}
