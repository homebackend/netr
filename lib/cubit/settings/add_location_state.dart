/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

part of 'add_location_cubit.dart';

enum SshConnectionStatus {
  untested,
  successful,
  failed,
}

sealed class AddLocationState extends SettingsCommonItemState {
  final String longitude;
  final String latitude;
  final bool locationFromAddress;
  final bool fetchingLocationFromAddress;
  final String locationFromAddressError;
  final String address;
  final LocationDistance distance;
  final bool useSshForNonLocal;
  final String sshHost;
  final String sshPort;
  final String sshUser;
  final String sshPrivateKey;
  final bool testingSshConnection;
  final SshConnectionStatus sshConnectionStatus;

  AddLocationState({
    super.autovalidateMode,
    super.index,
    super.name,
    this.longitude = '',
    this.latitude = '',
    this.locationFromAddress = false,
    this.fetchingLocationFromAddress = false,
    this.locationFromAddressError = '',
    this.address = '',
    this.distance = LocationDistance.tenMeter,
    this.useSshForNonLocal = false,
    this.sshHost = '',
    this.sshPort = '',
    this.sshUser = '',
    this.sshPrivateKey = '',
    this.testingSshConnection = false,
    this.sshConnectionStatus = SshConnectionStatus.untested,
  }) : super('location');

  AddLocationState copyWith({
    AutovalidateMode? autovalidateMode,
    int? index,
    String? name,
    String? longitude,
    String? latitude,
    bool? locationFromAddress,
    bool? fetchingLocationFromAddress,
    String? locationFromAddressError,
    String? address,
    LocationDistance? distance,
    bool? useSshForNonLocal,
    String? sshHost,
    String? sshPort,
    String? sshUser,
    String? sshPrivateKey,
    bool? testingSshConnection,
    SshConnectionStatus? sshConnectionStatus,
  });
}

final class AddLocationUpdateState extends AddLocationState {
  AddLocationUpdateState({
    super.autovalidateMode,
    super.index,
    super.name,
    super.longitude,
    super.latitude,
    super.locationFromAddress,
    super.fetchingLocationFromAddress,
    super.locationFromAddressError,
    super.address,
    super.distance,
    super.useSshForNonLocal,
    super.sshHost,
    super.sshPort,
    super.sshUser,
    super.sshPrivateKey,
    super.testingSshConnection,
    super.sshConnectionStatus,
  });

  @override
  AddLocationState copyWith({
    AutovalidateMode? autovalidateMode,
    int? index,
    String? name,
    String? longitude,
    String? latitude,
    bool? locationFromAddress,
    bool? fetchingLocationFromAddress,
    String? locationFromAddressError,
    String? address,
    LocationDistance? distance,
    bool? useSshForNonLocal,
    String? sshHost,
    String? sshPort,
    String? sshUser,
    String? sshPrivateKey,
    bool? testingSshConnection,
    SshConnectionStatus? sshConnectionStatus,
  }) {
    return AddLocationUpdateState(
      autovalidateMode: autovalidateMode ?? this.autovalidateMode,
      index: index ?? this.index,
      name: name ?? this.name,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      locationFromAddress: locationFromAddress ?? this.locationFromAddress,
      fetchingLocationFromAddress:
          fetchingLocationFromAddress ?? this.fetchingLocationFromAddress,
      locationFromAddressError:
          locationFromAddressError ?? this.locationFromAddressError,
      address: address ?? this.address,
      distance: distance ?? this.distance,
      useSshForNonLocal: useSshForNonLocal ?? this.useSshForNonLocal,
      sshHost: sshHost ?? this.sshHost,
      sshPort: sshPort ?? this.sshPort,
      sshUser: sshUser ?? this.sshUser,
      sshPrivateKey: sshPrivateKey ?? this.sshPrivateKey,
      testingSshConnection: testingSshConnection ?? this.testingSshConnection,
      sshConnectionStatus: sshConnectionStatus ?? this.sshConnectionStatus,
    );
  }
}
