import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config.dart';
import '../helpers/stream_camera_helper.dart';
import 'direct_video_viewer.dart';

class DirectArchiveVideoViewerHome extends DirectVideoViewerHome {
  const DirectArchiveVideoViewerHome(StreamCameraHelper streamCameraHelper,
      selectedVideoCamera, location, this.archiveDateTime, callback,
      {Key? key})
      : super(
          streamCameraHelper,
          selectedVideoCamera,
          'archive',
          location,
          callback,
          key: key,
        );

  final DateTime archiveDateTime;

  @override
  DirectArchiveVideoViewerHomeState createState() =>
      DirectArchiveVideoViewerHomeState();
}

class DirectArchiveVideoViewerHomeState<T extends DirectArchiveVideoViewerHome>
    extends DirectVideoViewerHomeState<T> {
  @override
  String getPath() {
    return properties['cameras'][selectedVideoCamera]['archive']['path'] +
        DateFormat("yyyyMMdd'T'kkmm'00z'").format(widget.archiveDateTime);
  }

  @override
  String getHost(String camera) {
    return properties['cameras'][camera]['archive']['access-points']
        [widget.location]['host'];
  }

  @override
  int getPort(String camera) {
    return properties['cameras'][camera]['archive']['access-points']
        [widget.location]['port'];
  }
}
