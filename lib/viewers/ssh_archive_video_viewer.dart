import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:netr/config.dart';
import 'package:netr/helpers/stream_camera_helper.dart';
import 'package:netr/viewers/ssh_video_viewer.dart';

class SshArchiveVideoViewerHome extends SshVideoViewerHome {
  const SshArchiveVideoViewerHome(StreamCameraHelper streamCameraHelper,
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
  SshArchiveVideoViewerHomeState createState() =>
      SshArchiveVideoViewerHomeState();
}

class SshArchiveVideoViewerHomeState
    extends SshVideoViewerHomeState<SshArchiveVideoViewerHome> {
  @override
  String getPath() {
    return properties['cameras'][selectedVideoCamera]['archive']['path'] +
        DateFormat("yyyyMMdd'T'kkmm'00z'").format(widget.archiveDateTime);
  }

  @override
  String getRemoteHost() {
    return properties['cameras'][selectedVideoCamera]['archive']
    ['access-points'][widget.location]['host'];
  }

  @override
  int getRemotePort() {
    return properties['cameras'][selectedVideoCamera]['archive']
    ['access-points'][widget.location]['port'];
  }
}
