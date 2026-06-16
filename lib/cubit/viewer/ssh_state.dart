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
  connecting,
  connected,
  forwardingPort,
  portForwarded,
  disconnecting,
  disconnected,
  failure
}

class SshState extends Equatable {
  final SshStatus status;
  final String? errorMessage;
  final int? localPort;
  final int? remotePort;
  final String? forwardedHost;

  const SshState({
    required this.status,
    this.errorMessage,
    this.localPort,
    this.remotePort,
    this.forwardedHost,
  });

  factory SshState.initial() => const SshState(status: SshStatus.initial);

  SshState copyWith({
    required SshStatus status,
    String? errorMessage,
    int? localPort,
    int? remotePort,
    String? forwardedHost,
  }) {
    return SshState(
      status: status,
      errorMessage: errorMessage,
      localPort: (status == SshStatus.portForwarded)
          ? (localPort ?? this.localPort)
          : null,
      remotePort: (status == SshStatus.portForwarded)
          ? (remotePort ?? this.remotePort)
          : null,
      forwardedHost: (status == SshStatus.portForwarded)
          ? (forwardedHost ?? this.forwardedHost)
          : null,
    );
  }

  @override
  List<Object?> get props =>
      [status, errorMessage, localPort, remotePort, forwardedHost];
}
