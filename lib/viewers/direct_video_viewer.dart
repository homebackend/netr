import 'package:netr/config.dart';
import 'package:netr/viewers/video_viewer.dart';

class DirectVideoViewerHome extends VideoViewerHome {
  const DirectVideoViewerHome(
      super.streamCameraHelper,
      super.selectedVideoCamera,
      super.selectedVideoQuality,
      super.location,
      super.callback,
      {super.key});

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
