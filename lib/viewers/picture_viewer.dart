import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:netr/helpers/photo_camera_helper.dart';
import 'package:netr/tool.dart';
import 'package:netr/viewers/base_camera_viewer.dart';
import 'package:window_manager/window_manager.dart';

class PictureViewerHome extends BaseCameraViewer {
  const PictureViewerHome(this.photoCameraHelper, selectedVideoCamera,
      selectedVideoQuality, location, callback, {Key? key})
      : super(selectedVideoCamera, selectedVideoQuality, location, callback,
            key: key);

  final PhotoCameraHelper photoCameraHelper;

  @override
  PictureViewerHomeState createState() => PictureViewerHomeState();
}

class PictureViewerHomeState<T extends PictureViewerHome>
    extends BaseCameraViewerState<T> {
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    if (isDesktopPlatform()) {
      _initWindow();
    }
    setImageUrl();
    lockScreen();
  }

  Future<void> _initWindow() async {
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    await windowManager.maximize();
  }

  void setImageUrl() async {
    _imageUrl =
        await widget.photoCameraHelper.getImageUrl(selectedVideoCamera!);
    log('Image url: $_imageUrl');
    setState(() {
      isInitialized = true;
    });
  }

  @override
  void dispose() {
    if (isDesktopPlatform()) {
      windowManager.unmaximize();
      windowManager.setTitleBarStyle(TitleBarStyle.normal);
      windowManager.center();
    }

    unlockScreen();
    super.dispose();
  }

  @override
  Future<void> initCameraConnection() async {
    _imageUrl =
        await widget.photoCameraHelper.getImageUrl(selectedVideoCamera!);
    setState(() {});
  }

  Widget getRefreshButton(context) {
    return createNavigatorButton(Icons.refresh, () async {
      Navigator.pop(context);
      showSnackBar(context, 'Trying to reload image data');
      await widget.photoCameraHelper.reload();
      setState(() {});
    });
  }

  @override
  List<String> getCameras() {
    return widget.photoCameraHelper.getCameras(widget.selectedVideoQuality);
  }

  @override
  Widget getMainViewWidget(BuildContext context) {
    return Image.network(_imageUrl!);
  }

  @override
  List<Widget> getNavigators(BuildContext context) {
    List<Widget> navigators = <Widget>[];
    navigators.add(getPreviousButton(context));
    navigators.add(getNextButton(context));
    navigators.add(getRefreshButton(context));
    return navigators;
  }
}
