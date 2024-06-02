import 'dart:developer';
import 'dart:io';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:netr/config.dart';
import 'package:netr/helpers/stream_camera_helper.dart';
import 'package:netr/tool.dart';
import 'package:netr/viewers/video_viewer.dart';

class SshVideoViewerHome extends VideoViewerHome {
  const SshVideoViewerHome(StreamCameraHelper streamCameraHelper,
      selectedVideoCamera, selectedVideoQuality, location, callback,
      {Key? key})
      : super(
          streamCameraHelper,
          selectedVideoCamera,
          selectedVideoQuality,
          location,
          callback,
          key: key,
        );

  @override
  SshVideoViewerHomeState createState() => SshVideoViewerHomeState();
}

class SshVideoViewerHomeState<T extends SshVideoViewerHome>
    extends VideoViewerHomeState<T> {
  int _serverSocketPort = 0;
  SSHClient? _remoteSshClient;
  ServerSocket? _serverSocket;

  @override
  void initState() {
    super.initState();
    _initSsh();
  }

  @override
  void dispose() {
    super.dispose();

    if (_serverSocket != null) {
      _serverSocket!.close();
    }

    if (_remoteSshClient != null) {
      _remoteSshClient!.close();
    }
  }

  void _initSsh() async {
    await _startSshConnectionAndForwardPort(context);
    setState(() {
      isInitialized = true;
    });
  }

  @override
  String getHost(String camera) {
    return 'localhost';
  }

  @override
  int getPort(String camera) {
    return _serverSocketPort;
  }

  String getRemoteHost() {
    return properties['cameras'][selectedVideoCamera]['streams']
        ['access-points'][widget.location]['host'];
  }

  int getRemotePort() {
    return properties['cameras'][selectedVideoCamera]['streams']
        ['access-points'][widget.location]['port'];
  }

  Future<bool> _startSshConnectionAndForwardPort(context) async {
    String rHost = getRemoteHost();
    String rPort = getRemotePort().toString();

    if (!await _startSshConnection(context)) {
      return false;
    }
    return await _forwardSshPort(context, rHost, rPort);
  }

  Future<bool> _startSshConnection(context) async {
    if (_remoteSshClient != null) {
      return false;
    }

    String host = properties['ssh'][widget.location]['host'];
    String port = properties['ssh'][widget.location]['port'];
    String user = properties['ssh'][widget.location]['user'];
    String privateKey = properties['ssh'][widget.location]['privateKey'];
    print('SSH connect to $user@$host:$port');
    print(privateKey);
    _remoteSshClient = SSHClient(await SSHSocket.connect(host, int.parse(port)),
        username: user, identities: [...SSHKeyPair.fromPem(privateKey)],
        onUserauthBanner: (String banner) {
      log("SSH Banner: $banner");
    });

    return true;
  }

  Future<bool> _forwardSshPort(context, String rHost, String rPort) async {
    if (_remoteSshClient == null) {
      showSnackBar(context, 'Remote connection not established');
      return false;
    }

    _serverSocket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    _serverSocketPort = _serverSocket?.port ?? 0;
    _processIncomingConnections(context, rHost, rPort);
    return true;
  }

  Future<void> _processIncomingConnections(
      context, String rHost, String rPort) async {
    if (_serverSocket == null) {
      return;
    }

    int port = int.parse(rPort);

    await for (final socket in _serverSocket!) {
      print("Remote host:port == $rHost:$rPort");
      final SSHForwardChannel? forward =
          await _remoteSshClient?.forwardLocal(rHost, port);
      if (forward == null) {
        showSnackBar(context, 'Failure to establish remote ssh channel');
        return;
      }

      forward.stream.cast<List<int>>().pipe(socket);
      socket.pipe(forward.sink);
      //showSnackBar(context, 'Ssh pipe established');
    }

    _stopSshConnection(context);
  }

  Future<void> _stopSshConnection(context) async {
    if (_remoteSshClient == null) {
      return;
    }

    _remoteSshClient?.close();
    await _remoteSshClient?.done;
    _remoteSshClient = null;
  }

  Future<void> _closeServerSocket() async {
    if (_serverSocket == null) {
      return;
    }

    await _serverSocket?.close();
    _serverSocket = null;
  }

  @override
  Future<void> finishCameraConnection() async {
    await _closeServerSocket();
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> initCameraConnection() async {
    if (!await _startSshConnectionAndForwardPort(context)) {
      showSnackBar(context, 'Failed in establishing remote connection');
    }

    await super.initCameraConnection();
  }
}
