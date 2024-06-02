import 'package:netr/config.dart';
import 'package:netr/helpers/camera_helper.dart';
import 'package:netr/tool.dart';

class StreamCameraHelper extends CameraHelper {
  StreamCameraHelper(this.videoStreamMode, OnLoadHandler onLoadHandler,
      OnErrorHandler onErrorHandler)
      : super(onLoadHandler, onErrorHandler);

  VideoStreamMode? videoStreamMode;

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
  List<String> getCamerasInternal(String? videoQuality) {
    List<String> cameras = [];
    properties['cameras'].keys.forEach((camera) {
      if (videoQuality == null ||
          properties['cameras'][camera]['streams']['paths']
              .containsKey(videoQuality) ||
          (videoQuality == 'archive' &&
              properties['cameras'][camera].containsKey(videoQuality))) {
        cameras.add(camera);
      }
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

  @override
  String getDefaultLocation(String camera) {
    return properties['cameras'][camera]['default-access-point'];
  }

  @override
  List<String> getLocations(String camera) {
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
