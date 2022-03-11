import 'dart:developer';

import 'package:netr/helpers/swipedetector.dart';

import '../tool.dart';

import 'package:flutter/material.dart';

typedef ViewerCallback = void Function(bool showInstruction);

abstract class BaseViewer extends StatefulWidget {
  const BaseViewer(this.selectedVideoCamera, this.selectedVideoQuality,
      this.location, this.callback,
      {Key? key})
      : super(key: key);

  final String selectedVideoCamera;
  final String selectedVideoQuality;
  final String location;
  final ViewerCallback callback;
}

abstract class BaseViewerState<T extends BaseViewer> extends State<T> {
  String? selectedVideoCamera;
  String? selectedVideoCameraPrevious;
  String? selectedVideoCameraNext;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    selectedVideoCameraPrevious =
        getPreviousVideoCamera(widget.selectedVideoCamera);
    selectedVideoCameraNext = getNextVideoCamera(widget.selectedVideoCamera);

    setState(() {
      selectedVideoCamera = widget.selectedVideoCamera;
    });
  }

  Future<void> backButtonCleanup(context) async {}

  Future<void> initCameraConnection(context) async {}

  Future<void> finishCameraConnection(context) async {}

  List<String> getVideoCameras();

  String? getPreviousVideoCamera(camera) {
    var cameras = getVideoCameras();
    for (int i = 1; i < cameras.length; i++) {
      if (camera == cameras[i]) {
        return cameras[i - 1];
      }
    }

    return null;
  }

  String? getNextVideoCamera(camera) {
    var cameras = getVideoCameras();
    for (int i = 0; i < cameras.length - 1; i++) {
      if (camera == cameras[i]) {
        return cameras[i + 1];
      }
    }

    return null;
  }

  Future<void> next() async {
    var camera = selectedVideoCamera;
    if (selectedVideoCameraNext == null) {
      showSnackBar(context, '${toDisplayText(camera!)} is the last camera');
      return;
    }

    await finishCameraConnection(context);
    selectedVideoCameraPrevious = camera;
    selectedVideoCamera = selectedVideoCameraNext!;
    selectedVideoCameraNext = getNextVideoCamera(selectedVideoCamera);
    await initCameraConnection(context);
  }

  Future<void> previous() async {
    var camera = selectedVideoCamera;
    if (selectedVideoCameraPrevious == null) {
      showSnackBar(context, '${toDisplayText(camera!)} is the first camera');
      return;
    }

    await finishCameraConnection(camera);
    selectedVideoCameraNext = camera;
    selectedVideoCamera = selectedVideoCameraPrevious!;
    selectedVideoCameraPrevious = getPreviousVideoCamera(selectedVideoCamera);
    await initCameraConnection(context);
  }

  Future<void> close() async {
    await backButtonCleanup(context);
    widget.callback(false);
  }

  Future<void> togglePlay() async {}

  Widget getPreviousButton(context) {
    return createIconButton(Icons.arrow_back, () async {
      await previous();
    });
  }

  Widget getNextButton(context) {
    return createIconButton(Icons.arrow_forward, () async {
      await next();
    });
  }

  Widget getBackButton(context) {
    return createIconButton(Icons.settings_backup_restore, () async {
      await close();
    });
  }

  void initializeViewer(BuildContext context) {}

  List<Widget> getNavigators(BuildContext context);

  Widget getMainViewWidget(BuildContext context);

  @override
  Widget build(BuildContext context) {
    initializeViewer(context);
    List<Widget> navigators = getNavigators(context);
    navigators.add(getBackButton(context));
    String? swipeDirection;

    return WillPopScope(
      onWillPop: () async {
        await close();
        return false;
      },
      child: Scaffold(
        body: SwipeDetector(
          onSwipeLeft: previous,
          onSwipeRight: next,
          onTap: togglePlay,
          child: Stack(
            alignment: AlignmentDirectional.bottomEnd,
            children: <Widget>[
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: 640,
                    height: 480,
                    child: isInitialized
                        ? getMainViewWidget(context)
                        : getBusyIndicator(),
                  ),
                ),
              ),
              Positioned(
                child: Column(children: navigators),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
