import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:netr/config.dart';
import 'package:netr/controllers/video_controller.dart';
import 'package:netr/controllers/video_player_controller_interface.dart';
import 'package:netr/helpers/stream_camera_helper.dart';
import 'package:netr/tool.dart';
import 'package:netr/viewers/base_camera_viewer.dart';
import 'package:netr/widgets/video_player.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:window_manager/window_manager.dart';

abstract class VideoViewerHome extends BaseCameraViewer {
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
    extends BaseCameraViewerState<T> with WidgetsBindingObserver {
  late VideoPlayerControllerInterface videoPlayerController;
  OverlayEntry? entry;
  double bufferPercentage = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (isDesktopPlatform()) {
      _initWindow();
    }
  }

  Future<void> _initWindow() async {
    await windowManager.setFullScreen(true);
  }

  @override
  void dispose() {
    if (isDesktopPlatform()) {
      _restoreWindow();
    }

    WidgetsBinding.instance.removeObserver(this);
    videoPlayerController.removeListener();
    videoPlayerController.dispose();
    _hideBufferingOverlay();
    super.dispose();
  }

  Future<void> _restoreWindow() async {
    await windowManager.setFullScreen(false);
    await windowManager.center();
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

    String url = '$protocol://';
    if (user.isNotEmpty && password.isNotEmpty) {
      url += '${Uri.encodeComponent(user)}:${Uri.encodeComponent(password)}@';
    }

    url += '$host:$port$path';

    return url;
  }

  void _showMessage(context, message) {
    showSnackBar(context, message);
  }

  VideoPlayerControllerInterface getVideoPlayerControllerInternal(String url) {
    VideoPlayerControllerInterface videoPlayerController =
        VideoController(url, true);

    videoPlayerController.addListener(() {
      _showMessage(context,
          'Remote streaming url for ${toDisplayText(selectedVideoCamera!)}: $url');
    }, (double bufferingProgress) {
      if (bufferPercentage < 0) {
        _showMessage(context, 'Buffering ...');
      }

      if (bufferingProgress == 100) {
        bufferPercentage = -1;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        return _hideBufferingOverlay();
      }

      bufferPercentage = bufferingProgress;
      _hideBufferingOverlay();
      _showBufferingOverlay();
    }, () {
      lockScreen();
      _showMessage(context, 'Started playing');
    }, () {
      unlockScreen();
      _showMessage(context, 'Stopped playing');
    }, (error) {
      _showMessage(context, 'Play error: $error');
    });

    return videoPlayerController;
  }

  VideoPlayerControllerInterface getVlcPlayerController() {
    String url = getStreamUrl(selectedVideoCamera);
    log('Url: $url');

    return getVideoPlayerControllerInternal(url);
  }

  @override
  Future<void> backButtonCleanup(context) async {
    if (videoPlayerController.isInitialized()) {
      bool? isPlaying = await videoPlayerController.isPlaying();
      if (isPlaying != null && isPlaying) {
        await videoPlayerController.stop();
      }
    }

    await finishCameraConnection();
    unlockScreen();
  }

  Widget getPlayButton(context) {
    return createNavigatorButton(Icons.play_arrow, () async {
      Navigator.pop(context);
      try {
        await videoPlayerController.play();
      } on Exception catch (_) {
        showSnackBar(context, 'Error during play: $_');
      }
    });
  }

  Widget getStopButton(context) {
    return createNavigatorButton(Icons.stop, () async {
      Navigator.pop(context);
      try {
        await videoPlayerController.stop();
      } on Exception catch (_) {
        showSnackBar(context, 'Error during stop: $_');
      }
    });
  }

  @override
  Future<void> togglePlay() async {
    bool isPlaying = await videoPlayerController.isPlaying() ?? false;
    if (isPlaying) {
      videoPlayerController.stop();
    } else {
      videoPlayerController.play();
    }
  }

  @override
  List<String> getCameras() {
    return widget.streamCameraHelper.getCameras(widget.selectedVideoQuality);
  }

  @override
  void initializeViewer(BuildContext context) {
    if (isInitialized) {
      videoPlayerController = getVlcPlayerController();
    }
  }

  @override
  Future<void> initCameraConnection() async {
    if (isInitialized) {
      await videoPlayerController
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
    return createVideoPlayer(videoPlayerController);
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

  void _showBufferingOverlay() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    SfRadialGauge radialGauge = SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(minimum: 0, maximum: 100, ranges: <GaugeRange>[
          GaugeRange(startValue: 0, endValue: 40, color: Colors.red),
          GaugeRange(startValue: 41, endValue: 80, color: Colors.orange),
          GaugeRange(startValue: 81, endValue: 100, color: Colors.green)
        ], pointers: <GaugePointer>[
          NeedlePointer(
            value: bufferPercentage,
          )
        ], annotations: const <GaugeAnnotation>[
          GaugeAnnotation(
              widget: Text('Buffering',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              angle: 90,
              positionFactor: 0.5)
        ]),
      ],
    );

    entry = OverlayEntry(
      builder: (context) => Positioned(
          left: width / 2 - 100,
          top: height / 2 - 100,
          child: SizedBox(
            width: 200,
            height: 200,
            child: Container(
              color: Colors.white,
              child: radialGauge,
            ),
          )),
    );

    final overlay = Overlay.of(context);
    overlay.insert(entry!);
  }

  void _hideBufferingOverlay() {
    entry?.remove();
    entry = null;
  }
}
