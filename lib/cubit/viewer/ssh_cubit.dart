/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:dartssh2_plus/dartssh2.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/camera.dart';
import 'live_view_cubit.dart';
import 'view_state.dart';

part 'ssh_state.dart';

class SshConfig {
  final String host;
  final int port;
  final String username;
  final String keyPem;
  SshConfig(this.host, this.port, this.username, this.keyPem);
}

class SshCubit extends Cubit<SshState> {
  final Map<String, SshConfig> _configRegistry = {};
  final Map<String, SSHClient> _activeClients = {};

  ServerSocket? _currentLocalServer;
  late final StreamSubscription _liveViewSubscription;
  final List<StreamSubscription> _activeSubscriptions = [];

  SshCubit(LiveViewCubit cubit) : super(SshState.initial()) {
    if (cubit.state is ViewUpdatedState) {
      _registerState(cubit.state as ViewUpdatedState);
    }

    _liveViewSubscription = cubit.stream.listen((state) {
      if (state is ViewUpdatedState) {
        _registerState(state);
      }
    });
  }

  void _registerState(ViewUpdatedState state) {
    for (var location in state.locations.where((l) => l.useSshForNonLocal)) {
      register(location.name, location.sshHost!, location.sshPort!,
          location.sshUser!, location.sshPrivateKey!);
    }
  }

  void register(String locationName, String sshHost, int sshPort,
      String sshUser, String sshKey) {
    if (_configRegistry.containsKey(locationName)) return;
    _configRegistry[locationName] =
        SshConfig(sshHost, sshPort, sshUser, sshKey);
  }

  Future<void> getLocalPort(Camera camera) async {
    for (var locationName in [camera.locationName, ...camera.ipLocationNames]) {
      if (!_configRegistry.containsKey(locationName)) {
        continue;
      }

      await _clearActiveForwarderOnly();

      final config = _configRegistry[locationName]!;
      SSHClient? client = _activeClients[locationName];
      bool isReused = false;

      emit(state.copyWith(
          status: SshStatus.sshConnecting, locationName: locationName));

      if (client != null) {
        try {
          await client.ping();
          isReused = true;
        } catch (_) {
          _activeClients.remove(locationName);
          client = null;
        }
      }

      if (client == null) {
        try {
          final keyPair = SSHKeyPair.fromPem(config.keyPem);
          client = SSHClient(
            await SSHSocket.connect(config.host, config.port),
            username: config.username,
            identities: keyPair,
          );
          await client.authenticated;
          _activeClients[locationName] = client;
          isReused = false;
        } catch (e) {
          emit(state.copyWith(
              status: SshStatus.failure,
              errorMessage: 'SSH Connection Failed: $e'));
          return;
        }
      }

      emit(state.copyWith(
          status: SshStatus.sshConnected, isReusedConnection: isReused));
      emit(state.copyWith(status: SshStatus.forwardingPort));

      try {
        _currentLocalServer = await ServerSocket.bind('localhost', 0);
        final int allocatedLocalPort = _currentLocalServer!.port;

        _currentLocalServer!.listen((Socket localSocket) async {
          try {
            final SSHForwardChannel forwardChannel = await client!.forwardLocal(
              camera.host,
              camera.port,
              localHost: 'localhost',
              localPort: allocatedLocalPort,
            );

            final sub1 = localSocket.listen(
              (data) {
                try {
                  forwardChannel.sink.add(data);
                } catch (_) {}
              },
              onDone: () => forwardChannel.sink.close(),
              onError: (error) {
                log('forwardChannel.sink.add error: $error');
                forwardChannel.sink.close();
                localSocket.destroy();
              },
              cancelOnError: true,
            );

            final sub2 = forwardChannel.stream.listen(
              (data) {
                try {
                  localSocket.add(data);
                } catch (_) {}
              },
              onDone: () => localSocket.close(),
              onError: (error) {
                log('localSocket.add error: $error');
                localSocket.close();
                localSocket.destroy();
              },
              cancelOnError: true,
            );

            _activeSubscriptions.addAll([sub1, sub2]);
          } catch (_) {
            localSocket.close();
            localSocket.destroy();
          }
        });

        emit(state.copyWith(
          status: SshStatus.portForwarded,
          localPort: allocatedLocalPort,
        ));
      } catch (e) {
        emit(state.copyWith(
            status: SshStatus.failure, errorMessage: 'Forwarding Error: $e'));
      }

      return;
    }

    emit(state.copyWith(
      status: SshStatus.noSshConnectionConfigured,
      errorMessage: 'No SSH configuration found for: ${camera.name}',
    ));
  }

  Future<void> _clearActiveForwarderOnly() async {
    for (var sub in _activeSubscriptions) {
      await sub.cancel();
    }
    _activeSubscriptions.clear();
    if (_currentLocalServer != null) {
      await _currentLocalServer!.close();
      _currentLocalServer = null;
    }
  }

  @override
  Future<void> close() async {
    _liveViewSubscription.cancel();
    await _clearActiveForwarderOnly();
    for (var client in _activeClients.values) {
      client.close();
    }
    _activeClients.clear();
    return super.close();
  }
}
