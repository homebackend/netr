typedef OnLoadHandler = void Function();
typedef OnErrorHandler = void Function(String error);

abstract class CameraHelper {
  bool isInitialized = false;
  OnLoadHandler onLoadHandler;
  OnErrorHandler onErrorHandler;

  CameraHelper(this.onLoadHandler, this.onErrorHandler);

  Future<void> init() async {
    await load();
  }

  Future<void> load();

  List<String> getCameras(String? videoQuality) {
    if (isInitialized) {
      return getCamerasInternal(videoQuality);
    }

    throw "Not initialised";
  }

  bool doesCameraExist(String camera, String? videoQuality) {
    List<String> cameras = getCameras(videoQuality);
    return cameras.contains(camera);
  }

  List<String> getTypes(String camera) {
    if (isInitialized) {
      return getTypesInternal(camera);
    }

    throw "Not initialised";
  }

  String getDefaultType();

  List<String> getCamerasInternal(String? videoQuality);

  List<String> getTypesInternal(String camera);

  String getDefaultLocation(String camera);

  List<String> getLocations(String camera);
}
