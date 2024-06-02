import 'package:flutter/material.dart';
import 'package:netr/config.dart';
import 'package:netr/helpers/stream_camera_helper.dart';
import 'package:netr/viewers/video_viewer.dart';

class DirectVideoViewerHome extends VideoViewerHome {
  const DirectVideoViewerHome(StreamCameraHelper streamCameraHelper,
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
  DirectVideoViewerHomeState createState() => DirectVideoViewerHomeState();
}

class DirectVideoViewerHomeState<T extends DirectVideoViewerHome>
    extends VideoViewerHomeState<T> {

  @override
  void initState() {
    super.initState();
    setState(() {
      isInitialized = true;
    });
  }

  @override
  String getHost(String camera) {
    return properties['cameras'][camera]['streams']['access-points']
        [widget.location]['host'];
  }

  @override
  int getPort(String camera) {
    return properties['cameras'][camera]['streams']['access-points']
        [widget.location]['port'];
  }
}
