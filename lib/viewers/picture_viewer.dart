import 'package:flutter/material.dart';
import 'package:netr/helpers/photo_camera_helper.dart';

import '../tool.dart';
import 'base_viewer.dart';

class PictureViewerHome extends BaseViewer {
  const PictureViewerHome(this.photoCameraHelper, selectedVideoCamera,
      selectedVideoQuality, location, callback, {Key? key})
      : super(selectedVideoCamera, selectedVideoQuality, location, callback,
            key: key);

  final PhotoCameraHelper photoCameraHelper;

  @override
  _PictureViewerHomeState createState() => _PictureViewerHomeState();
}

class _PictureViewerHomeState extends BaseViewerState<PictureViewerHome> {
  String? _imageUrl;

  @override
  void initState() {
    super.initState();

    setImageUrl();
  }

  void setImageUrl() async {
    _imageUrl =
        await widget.photoCameraHelper.getImageUrl(selectedVideoCamera!);
    setState(() {
      isInitialized = true;
    });
  }

  @override
  Future<void> initCameraConnection(context) async {
    _imageUrl =
        await widget.photoCameraHelper.getImageUrl(selectedVideoCamera!);
    setState(() {});
  }

  Widget getRefreshButton(context) {
    return createIconButton(Icons.refresh, () async {
      showSnackBar(context, 'Trying to reload image data');
      await widget.photoCameraHelper.reload();
      setState(() {});
    });
  }

  @override
  List<String> getVideoCameras() {
    return widget.photoCameraHelper.getCameras();
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
