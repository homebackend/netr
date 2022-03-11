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

  List<String> getCameras() {
    if (isInitialized) {
      return getCamerasInternal();
    }

    throw "Not initialised";
  }

  List<String> getTypes(String camera) {
    if (isInitialized) {
      return getTypesInternal(camera);
    }

    throw "Not initialised";
  }

  String getDefaultType();

  List<String> getCamerasInternal();

  List<String> getTypesInternal(String camera);

  String? getPreviousCamera(camera) {
    var cameras = getCameras();
    for (int i = 1; i < cameras.length; i++) {
      if (camera == cameras[i]) {
        return cameras[i - 1];
      }
    }

    return null;
  }

  String? getNextCamera(camera) {
    var cameras = getCameras();
    for (int i = 0; i < cameras.length - 1; i++) {
      if (camera == cameras[i]) {
        return cameras[i + 1];
      }
    }

    return null;
  }
}