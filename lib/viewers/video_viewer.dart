import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:netr/helpers/stream_camera_helper.dart';
import 'package:wakelock/wakelock.dart';

import '../tool.dart';
import 'base_viewer.dart';
import '../config.dart';

abstract class VideoViewerHome extends BaseViewer {
  const VideoViewerHome(this.streamCameraHelper, selectedVideoCamera,
      selectedVideoQuality, location, callback,
      {Key? key})
      : super(
          selectedVideoCamera,
          selectedVideoQuality,
          location,
          callback,
          key: key,
        );

  final StreamCameraHelper streamCameraHelper;
}

abstract class VideoViewerHomeState<T extends VideoViewerHome>
    extends BaseViewerState<T> with WidgetsBindingObserver {
  late VlcPlayerController vlcPlayerController;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  String getHost(String camera);
  int getPort(String camera);

  String getPath() {
    return properties['cameras'][selectedVideoCamera]['streams']['paths']
        [widget.selectedVideoQuality];
  }

  String getStreamUrl(camera) {
    String protocol, user, password, path;
    String host = getHost(camera);
    int port = getPort(camera);

    protocol = 'rtsp';
    user = properties['cameras'][camera]['user'];
    password = properties['cameras'][camera]['password'];
    path = getPath();

    String url = protocol + '://';
    if (user.isNotEmpty && password.isNotEmpty) {
      url +=
          Uri.encodeComponent(user) + ':' + Uri.encodeComponent(password) + '@';
    }

    url += host + ':' + port.toString() + path;

    return url;
  }

  VlcPlayerController getVlcPlayerControllerInternal(String url) {
    VlcPlayerController _vlcPlayerController = VlcPlayerController.network(url,
        autoPlay: true, options: VlcPlayerOptions());

    _vlcPlayerController.addOnInitListener(() {
      showSnackBar(context,
          'Remote streaming url for ${toDisplayText(selectedVideoCamera!)}: $url');
    });

    _vlcPlayerController.addListener(() {
      if (_vlcPlayerController.value.isInitialized) {
        if (_vlcPlayerController.value.isPlaying) {
          Wakelock.enable();
        } else {
          if (_vlcPlayerController.value.isBuffering) {
            showSnackBar(context, 'Buffering ...');
          } else if (_vlcPlayerController.value.hasError) {
            showSnackBar(context,
                'Play error: ${_vlcPlayerController.value.errorDescription}');
          }

          Wakelock.disable();
        }
      } else {
        Wakelock.disable();
      }
    });

    return _vlcPlayerController;
  }

  VlcPlayerController getVlcPlayerController() {
    String url = getStreamUrl(selectedVideoCamera);
    log('Url: $url');

    return getVlcPlayerControllerInternal(url);
  }

  @override
  Future<void> backButtonCleanup(context) async {
    if (vlcPlayerController.value.isInitialized) {
      bool? isPlaying = await vlcPlayerController.isPlaying();
      if (isPlaying != null && isPlaying) {
        await vlcPlayerController.stop();
      }
    }

    await finishCameraConnection(context);
    Wakelock.disable();
  }

  Widget getPlayButton(context) {
    return createIconButton(Icons.play_arrow, () async {
      try {
        await vlcPlayerController.play();
      } on Exception catch (_) {
        showSnackBar(context, 'Error during play: $_');
      }
    });
  }

  Widget getStopButton(context) {
    return createIconButton(Icons.stop, () async {
      try {
        await vlcPlayerController.stop();
      } on Exception catch (_) {
        showSnackBar(context, 'Error during stop: $_');
      }
    });
  }

  @override
  Future<void> togglePlay() async {
    bool isPlaying = await vlcPlayerController.isPlaying() ?? false;
    if (isPlaying) {
      vlcPlayerController.stop();
    } else {
      vlcPlayerController.play();
    }
  }

  @override
  List<String> getVideoCameras() {
    return widget.streamCameraHelper.getCameras();
  }

  @override
  void initializeViewer(BuildContext context) {
    if (isInitialized) {
      vlcPlayerController = getVlcPlayerController();
    }
  }

  @override
  Future<void> initCameraConnection(context) async {
    if (isInitialized) {
      await vlcPlayerController
          .setMediaFromNetwork(getStreamUrl(selectedVideoCamera));
    }
  }

  @override
  List<Widget> getNavigators(BuildContext context) {
    List<Widget> navigators = <Widget>[];
    navigators.add(getPlayButton(context));
    navigators.add(getStopButton(context));
    navigators.add(getPreviousButton(context));
    navigators.add(getNextButton(context));
    return navigators;
  }

  @override
  Widget getMainViewWidget(BuildContext context) {
    return VlcPlayer(
      controller: vlcPlayerController,
      aspectRatio: 16 / 9,
      placeholder: getBusyIndicator(),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        close();
        break;

      case AppLifecycleState.resumed:
        break;
    }
  }
}
