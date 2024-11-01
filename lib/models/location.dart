/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'settings_item.dart';

enum LocationDistance {
  oneMeter(1),
  fiveMeter(5),
  tenMeter(10),
  fiftyMeter(50),
  hundredMeter(100),
  oneKiloMeter(1000),
  fiveKiloMeter(5000),
  tenKiloMeter(10000);

  const LocationDistance(this.value);
  final num value;

  String get name {
    switch (this) {
      case LocationDistance.oneMeter:
        return '1m';
      case LocationDistance.fiveMeter:
        return '5m';
      case LocationDistance.tenMeter:
        return '10m';
      case LocationDistance.fiftyMeter:
        return '50m';
      case LocationDistance.hundredMeter:
        return '100m';
      case LocationDistance.oneKiloMeter:
        return '1km';
      case LocationDistance.fiveKiloMeter:
        return '5km';
      case LocationDistance.tenKiloMeter:
        return '10km';
    }
  }
}

class Location extends SettingsItem {
  static final String _keyName = 'name';
  static final String _keyLongitude = 'longitude';
  static final String _keyLatitude = 'latitude';
  static final String _keyDistance = 'distance';
  static final String _keySupportsSsh = 'supportsSssh';
  static final String _keyUseSshForNonLocal = 'useSshForNonLocal';
  static final String _keySshHost = 'sshHost';
  static final String _keySshPort = 'sshPort';
  static final String _keySshUser = 'sshUser';
  static final String _keySshPrivateKey = 'sshPrivateKey';

  double longitude;
  double latitude;
  LocationDistance distance;
  bool supportsSsh;
  bool useSshForNonLocal;
  String? sshHost;
  int? sshPort;
  String? sshUser;
  String? sshPrivateKey;

  Location(
    super.name, {
    this.longitude = 0.0,
    this.latitude = 0.0,
    this.distance = LocationDistance.tenMeter,
    this.supportsSsh = false,
    this.useSshForNonLocal = false,
    this.sshHost,
    this.sshPort = 22,
    this.sshUser,
    this.sshPrivateKey,
  });

  @override
  Location copySelf() {
    return Location(
      name,
      longitude: longitude,
      latitude: latitude,
      distance: distance,
      useSshForNonLocal: useSshForNonLocal,
      sshHost: sshHost,
      sshPort: sshPort,
      sshUser: sshUser,
      sshPrivateKey: sshPrivateKey,
    );
  }

  factory Location.fromJson(Map<String, dynamic> locMap) {
    return Location(
      locMap[_keyName] ?? '',
      longitude: locMap[_keyLongitude],
      latitude: locMap[_keyLatitude],
      distance: LocationDistance.values[locMap[_keyDistance] ?? 0],
      useSshForNonLocal: locMap[_keyUseSshForNonLocal],
      supportsSsh: locMap[_keySupportsSsh],
      sshHost: locMap[_keySshHost],
      sshPort: locMap[_keySshPort],
      sshUser: locMap[_keySshUser],
      sshPrivateKey: locMap[_keySshPrivateKey],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      _keyName: name,
      _keyLongitude: longitude,
      _keyLatitude: latitude,
      _keyDistance: distance.index,
      _keyUseSshForNonLocal: useSshForNonLocal,
      _keySupportsSsh: supportsSsh,
      _keySshHost: sshHost,
      _keySshPort: sshPort,
      _keySshUser: sshUser,
      _keySshPrivateKey: sshPrivateKey,
    };
  }
}
