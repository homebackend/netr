/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

part of 'ssh_cubit.dart';

enum SshStatus {
  initial,
  sshConnecting,
  sshConnected,
  forwardingPort,
  portForwarded,
  noSshConnectionConfigured,
  failure
}

class SshState extends Equatable {
  final SshStatus status;
  final String? errorMessage;
  final int? localPort;
  final String? locationName;
  final bool isReusedConnection;

  const SshState({
    required this.status,
    this.errorMessage,
    this.localPort,
    this.locationName,
    this.isReusedConnection = false,
  });

  factory SshState.initial() {
    return const SshState(
      status: SshStatus.initial,
      errorMessage: null,
      localPort: null,
      locationName: null,
      isReusedConnection: false,
    );
  }

  SshState copyWith({
    required SshStatus status,
    String? errorMessage,
    int? localPort,
    String? locationName,
    bool? isReusedConnection,
  }) {
    return SshState(
      status: status,
      errorMessage: (status == SshStatus.failure ||
              status == SshStatus.noSshConnectionConfigured)
          ? (errorMessage ?? this.errorMessage)
          : null,
      locationName: locationName ?? this.locationName,
      isReusedConnection: isReusedConnection ?? false,
      localPort: (status == SshStatus.portForwarded)
          ? (localPort ?? this.localPort)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        localPort,
        locationName,
        isReusedConnection,
      ];
}
