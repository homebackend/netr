import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:netr/tool.dart';
import '../controllers/vlc_remote_controller.dart';
import '../helpers/stream_camera_helper.dart';
import 'direct_video_viewer.dart';

class VlcDirectVideoViewerHome extends DirectVideoViewerHome {
  const VlcDirectVideoViewerHome(StreamCameraHelper streamCameraHelper,
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
  VlcDirectVideoViewerHomeState createState() =>
      VlcDirectVideoViewerHomeState();
}

class VlcDirectVideoViewerHomeState
    extends DirectVideoViewerHomeState<VlcDirectVideoViewerHome> {
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
  VlcPlayerController getVlcPlayerControllerInternal(String url) {
    VlcRemoteController _vlcRemoteController = VlcRemoteController.network(url);

    return _vlcRemoteController;
  }
}
