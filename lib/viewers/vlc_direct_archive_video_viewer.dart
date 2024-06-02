import 'package:flutter/material.dart';
import 'package:netr/controllers/vlc_remote_controller.dart';
import 'package:netr/helpers/stream_camera_helper.dart';
import 'package:netr/viewers/direct_archive_video_viewer.dart';
import 'package:netr/tool.dart';


class VlcDirectArchiveVideoViewerHome extends DirectArchiveVideoViewerHome {
  const VlcDirectArchiveVideoViewerHome(StreamCameraHelper streamCameraHelper,
      selectedVideoCamera, location, archiveDateTime, callback,
      {Key? key})
      : super(
    streamCameraHelper,
    selectedVideoCamera,
    location,
    archiveDateTime,
    callback,
    key: key,
  );

  @override
  VlcDirectArchiveVideoViewerHomeState createState() =>
      VlcDirectArchiveVideoViewerHomeState();
}

class VlcDirectArchiveVideoViewerHomeState
    extends DirectArchiveVideoViewerHomeState<VlcDirectArchiveVideoViewerHome> {
  @override
  Widget build(BuildContext context) {
    initializeViewer(context);
    List<Widget> navigators = [];
    navigators.add(createIconButton(Icons.power, () {}));
    navigators.addAll(getNavigators(context));
    navigators.add(getBackButton(context));

    return Scaffold(
        body: Center(
            child: Column(
              children: navigators,
            )));
  }

  @override
  VlcRemoteController getVideoPlayerControllerInternal(String url) {
    VlcRemoteController vlcRemoteController = VlcRemoteController.network(url);

    return vlcRemoteController;
  }
}
