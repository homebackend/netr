import 'dart:convert';
import 'dart:async';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:netr/helpers/camera_helper.dart';
import 'package:netr/helpers/dropbox_camera_helper.dart';
import 'package:netr/models/latest_info.dart';

class PhotoCameraHelper extends DropboxCameraHelper {
  static const String _latestInfoFileName = 'latest.json';

  LatestInfo? _latestInfo;

  PhotoCameraHelper(OnLoadHandler onLoadHandler, OnErrorHandler onErrorHandler)
      : super(onLoadHandler, onErrorHandler);

  @override
  Future<void> load() async {
    await _loadLatestJson();
    _checkAndRerunLoadLatestJson(true);
  }

  Future<void> _checkAndRerunLoadLatestJson(bool first) async {
    if (_latestInfo == null) {
      log('Dropbox not initialized: Will retry');
      Timer(Duration(seconds: first ? 10 : 60), () async {
        _loadLatestJson();
        _checkAndRerunLoadLatestJson(false);
      });
    } else {
      isInitialized = true;
      onLoadHandler();
    }
  }

  Future<void> reload() async {
    await _loadLatestJson();
  }

  @override
  String getDefaultType() {
    return 'high';
  }

  @override
  List<String> getCamerasInternal(String? videoQuality) {
    return _latestInfo?.cameras ?? <String>[];
  }

  @override
  List<String> getTypesInternal(String camera) {
    return _latestInfo?.types ?? <String>[];
  }

  String _getUrl(String camera, String type) {
    int index = _latestInfo?.cameras.indexOf(camera) ?? 0;
    return "${_latestInfo?.dest}/${_latestInfo?.time}-$type-${index + 1}-$camera.jpg";
  }

  Future _loadLatestJson() async {
    var sourcePath = '$location/$_latestInfoFileName';

    final String? link = await getDropboxUrl(sourcePath);

    if (link == null) {
      return;
    }

    try {
      var contents = await http.read(Uri.parse(link));
      _latestInfo = LatestInfo.fromJson(jsonDecode(contents));
    } on Exception catch (e) {
      log('Error: $e');
      onErrorHandler('Error loading camera configuration: $e');
    }
  }

  Future<String?> getImageUrl(String camera) async {
    if (_latestInfo == null) {
      await _loadLatestJson();
      if (_latestInfo == null) {
        return null;
      }
    }

    String sourcePath = _getUrl(camera, 'high');
    final String? link = await getDropboxUrl(sourcePath);
    return link;
  }

  int getFrequency(String camera) {
    if(_latestInfo!.minCameras.contains(camera)) {
      return _latestInfo!.minCameraFrequency;
    } else if(_latestInfo!.cameras.contains(camera)) {
      return _latestInfo!.frequency;
    }

    throw UnsupportedError('$camera is not supported');
  }

  String getLatestImageTime() {
    return _latestInfo!.time;
  }
}
