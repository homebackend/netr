/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'settings_item.dart';

enum CameraType {
  hikvision('Hikvision');

  const CameraType(this.label);
  final String label;
}

enum StreamQuality {
  high,
  low;
}

class Camera extends SettingsItem {
  static final String _keyName = 'name';
  static final String _keyCameraType = 'cameraType';
  static final String _keyProtocol = 'protocol';
  static final String _keyHost = 'host';
  static final String _keyPort = 'port';
  static final String _keyIpLocationNames = 'ipLocationNames';
  static final String _keyLocationName = 'locationName';
  static final String _keyCredentialName = 'credentialName';
  static final String _keyArchiveName = 'archiveName';

  CameraType cameraType;
  String protocol;
  String host;
  int port;
  List<String> ipLocationNames;
  String locationName;
  String credentialName;
  String archiveName;

  Camera(
    super.name, {
    this.cameraType = CameraType.hikvision,
    this.protocol = '',
    this.host = '',
    this.port = 0,
    ipLocationNames = const <String>[],
    this.locationName = '',
    this.credentialName = '',
    this.archiveName = '',
  }) : ipLocationNames = List<String>.from(ipLocationNames);

  factory Camera.fromJson(Map<String, dynamic> map) {
    return Camera(
      map[_keyName] ?? '',
      cameraType: CameraType.values[map[_keyCameraType] ?? 0],
      protocol: map[_keyProtocol] ?? '',
      host: map[_keyHost] ?? '',
      port: map[_keyPort] ?? '',
      ipLocationNames:
          List<String>.from(map[_keyIpLocationNames] ?? <String>[]),
      locationName: map[_keyLocationName] ?? '',
      credentialName: map[_keyCredentialName] ?? '',
      archiveName: map[_keyArchiveName] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      _keyName: name,
      _keyCameraType: cameraType.index,
      _keyProtocol: protocol,
      _keyHost: host,
      _keyPort: port,
      _keyIpLocationNames: ipLocationNames,
      _keyLocationName: locationName,
      _keyCredentialName: credentialName,
      _keyArchiveName: archiveName,
    };
  }

  @override
  SettingsItem copySelf() {
    return Camera(
      name,
      cameraType: cameraType,
      protocol: protocol,
      host: host,
      port: port,
      ipLocationNames: ipLocationNames,
      locationName: locationName,
      credentialName: credentialName,
      archiveName: archiveName,
    );
  }
}
