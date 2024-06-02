import 'package:flutter/material.dart';
import 'package:netr/viewers/base_viewer.dart';
import 'package:netr/tool.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

abstract class BaseCameraViewer extends BaseViewer {
  const BaseCameraViewer(selectedVideoCamera, selectedVideoQuality,
      String location, ViewerCallback callback, {Key? key})
      : super(selectedVideoCamera, selectedVideoQuality, location, callback,
            key: key);
}

abstract class BaseCameraViewerState<T extends BaseCameraViewer>
    extends BaseViewerState<T> {
  String? selectedVideoCameraPrevious;
  String? selectedVideoCameraNext;

  @override
  void initState() {
    super.initState();
    selectedVideoCameraPrevious = getPreviousCamera(widget.selectedVideoCamera);
    selectedVideoCameraNext = getNextCamera(widget.selectedVideoCamera);

    setState(() {});
  }

  List<String> getCameras();

  @override
  Widget getSelectionView() {
    List<String> cameras = getCameras();

    return ScrollablePositionedList.separated(
      itemScrollController: ItemScrollController(),
      itemCount: cameras.length,
      initialAlignment: 0.5,
      initialScrollIndex: selectedVideoCamera == null
          ? 0
          : cameras.indexOf(selectedVideoCamera!),
      itemBuilder: (context, index) {
        var camera = cameras[index];
        return createButton(
          "${index + 1}. ${toDisplayText(camera)}",
          () async {
            Navigator.pop(context);
            await finishCameraConnection();
            selectedVideoCameraPrevious = getPreviousCamera(camera);
            selectedVideoCamera = camera;
            selectedVideoCameraNext = getNextCamera(camera);
            await initCameraConnection();
          },
          getPopupItemStyle(),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(height: 0);
      },
    );
  }

  String? getPreviousCamera(camera) {
    var cameras = getCameras();
    for (int i = 0; i < cameras.length; i++) {
      if (camera == cameras[i]) {
        if (i == 0) {
          return cameras[cameras.length - 1];
        } else {
          return cameras[i - 1];
        }
      }
    }

    return null;
  }

  String? getNextCamera(camera) {
    var cameras = getCameras();
    for (int i = 0; i < cameras.length; i++) {
      if (camera == cameras[i]) {
        if (i == cameras.length - 1) {
          return cameras[0];
        } else {
          return cameras[i + 1];
        }
      }
    }

    return null;
  }

  Future<void> initCameraConnection() async {}

  Future<void> finishCameraConnection() async {}

  @override
  Future<void> next() async {
    var camera = selectedVideoCamera;
    if (selectedVideoCameraNext == null) {
      showSnackBar(context, '${toDisplayText(camera!)} is the last camera');
      return;
    }

    await finishCameraConnection();
    selectedVideoCameraPrevious = camera;
    selectedVideoCamera = selectedVideoCameraNext!;
    selectedVideoCameraNext = getNextCamera(selectedVideoCamera);
    await initCameraConnection();
  }

  @override
  Future<void> previous() async {
    var camera = selectedVideoCamera;
    if (selectedVideoCameraPrevious == null) {
      showSnackBar(context, '${toDisplayText(camera!)} is the first camera');
      return;
    }

    await finishCameraConnection();
    selectedVideoCameraNext = camera;
    selectedVideoCamera = selectedVideoCameraPrevious!;
    selectedVideoCameraPrevious = getPreviousCamera(selectedVideoCamera);
    await initCameraConnection();
  }
}
