/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'dart:async';
import 'dart:io';
import 'package:dartssh2_plus/dartssh2.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'ssh_state.dart';

class SshCubit extends Cubit<SshState> {
  final String host;
  final int port;
  final String username;
  final String privateKeyPem;

  SSHClient? _client;
  ServerSocket? _localServer;
  final List<StreamSubscription> _socketSubscriptions = [];

  SshCubit({
    required this.host,
    required this.port,
    required this.username,
    required this.privateKeyPem,
  }) : super(SshState.initial());

  Future<void> connect() async {
    emit(state.copyWith(status: SshStatus.connecting));
    try {
      await _cleanupSession();

      final keyPair = SSHKeyPair.fromPem(privateKeyPem);
      _client = SSHClient(
        await SSHSocket.connect(host, port),
        username: username,
        identities: keyPair,
      );

      await _client!.authenticated;
      emit(state.copyWith(status: SshStatus.connected));
    } catch (e) {
      emit(state.copyWith(
          status: SshStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> forwardPort({
    required String remoteHost,
    required int remotePort,
    required int localPort,
    String localHost = 'localhost',
  }) async {
    if (_client == null) {
      emit(state.copyWith(
          status: SshStatus.failure, errorMessage: 'No active SSH session.'));
      return;
    }

    emit(state.copyWith(status: SshStatus.forwardingPort));

    try {
      await _closeActiveForwarder();
      _localServer = await ServerSocket.bind(localHost, localPort);
      _localServer!.listen((Socket localSocket) async {
        try {
          final SSHForwardChannel forwardChannel = await _client!.forwardLocal(
            remoteHost,
            remotePort,
            localHost: localHost,
            localPort: localPort,
          );

          final sub1 = localSocket.listen(
            (data) => forwardChannel.sink.add(data),
            onDone: () => forwardChannel.sink.close(),
            onError: (_) => forwardChannel.sink.close(),
          );

          final sub2 = forwardChannel.stream.listen(
            (data) => localSocket.add(data),
            onDone: () => localSocket.close(),
            onError: (_) => localSocket.close(),
          );

          _socketSubscriptions.addAll([sub1, sub2]);
        } catch (e) {
          localSocket.close();
        }
      });

      emit(state.copyWith(
        status: SshStatus.portForwarded,
        localPort: _localServer!.port,
        remotePort: remotePort,
        forwardedHost: remoteHost,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SshStatus.failure,
        errorMessage: 'Port Forwarding Failed: $e',
      ));
    }
  }

  Future<void> _closeActiveForwarder() async {
    for (var sub in _socketSubscriptions) {
      await sub.cancel();
    }
    _socketSubscriptions.clear();

    if (_localServer != null) {
      await _localServer!.close();
      _localServer = null;
    }
  }

  Future<void> closeActiveWithUiUpdate() async {
    await _closeActiveForwarder();
    emit(state.copyWith(status: SshStatus.connected));
  }

  Future<void> disconnect() async {
    emit(state.copyWith(status: SshStatus.disconnecting));
    await _cleanupSession();
    emit(state.copyWith(status: SshStatus.disconnected));
  }

  Future<void> _cleanupSession() async {
    await _closeActiveForwarder();
    if (_client != null) {
      _client!.close();
      await _client!.done;
      _client = null;
    }
  }

  @override
  Future<void> close() async {
    await _cleanupSession();
    return super.close();
  }
}
