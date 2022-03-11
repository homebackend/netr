import 'package:netr/helpers/camera_helper.dart';

import '../config.dart';
import '../tool.dart';

class StreamCameraHelper extends CameraHelper {
  StreamCameraHelper(OnLoadHandler onLoadHandler, OnErrorHandler onErrorHandler)
      : super(onLoadHandler, onErrorHandler);

  @override
  Future<void> load() async {
    isInitialized = true;
    onLoadHandler();
  }

  @override
  String getDefaultType() {
    return 'low';
  }

  @override
  List<String> getCamerasInternal() {
    List<String> cameras = [];
    properties['cameras'].keys.forEach((camera) {
      cameras.add(camera);
    });
    return cameras;
  }

  @override
  List<String> getTypesInternal(String camera) {
    List<String> types = [];
    properties['cameras'][camera]['streams']['paths'].keys.forEach((type) {
      types.add(type);
    });
    return types;
  }

  String getDefaultLocation(String camera) {
    return properties['cameras'][camera]['default-access-point'];
  }

  List<String> getLocations(String camera, VideoStreamMode videoStreamMode) {
    List<String> locations = [];
    properties['cameras'][camera]['streams']['access-points']
        .keys
        .forEach((accessPoint) {
      if (videoStreamMode == VideoStreamMode.streamOverSsh &&
          !properties['ssh'].containsKey(accessPoint)) {
        return;
      }
      locations.add(accessPoint);
    });

    return locations;
  }
}
