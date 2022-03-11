import 'dart:convert';
import 'dart:async';
import 'dart:developer';

import 'package:dropbox_client/dropbox_client.dart';
import 'package:http/http.dart' as http;
import 'package:netr/helpers/camera_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import '../models/latest_info.dart';

class PhotoCameraHelper extends CameraHelper {
  String? _location;
  static const String _latestInfoFileName = 'latest.json';

  LatestInfo? _latestInfo;

  PhotoCameraHelper(OnLoadHandler onLoadHandler, OnErrorHandler onErrorHandler)
      : super(onLoadHandler, onErrorHandler);

  @override
  Future<void> load() async {
    await _initDropbox();
    _checkAndRerunLoadLatestJson(true);
  }

  Future<void> _checkAndRerunLoadLatestJson(bool first) async {
    if (_latestInfo == null) {
      log('Dropbox not initialized: Will retry');
      Timer(Duration(seconds: first ? 10 : 60), () async {
        if (!await checkAuthorized(false)) {
          _loadLatestJson();
        }
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
  List<String> getCamerasInternal() {
    return _latestInfo?.cameras ?? <String>[];
  }

  @override
  List<String> getTypesInternal(String camera) {
    return _latestInfo?.types ?? <String>[];
  }

  String getUrl(String camera, String type) {
    int index = _latestInfo?.cameras.indexOf(camera) ?? 1;
    return "${_latestInfo?.dest}/${_latestInfo?.time}-$type-$index-$camera.jpg";
  }

  String? _accessToken;

  Future _initDropbox() async {
    properties['images'].keys.forEach((location) => _location = location);

    String dropboxClientId = properties['images'][_location]['client_id'];
    String dropboxKey = properties['images'][_location]['key'];
    String dropboxSecret = properties['images'][_location]['secret'];
    await Dropbox.init(dropboxClientId, dropboxKey, dropboxSecret);
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (properties['images'][_location].containsKey('access_token')) {
      _accessToken =
          properties['images'][_location]['access_token'];
      prefs.setString('dropboxAccessToken', _accessToken!);
    } else {
      _accessToken = prefs.getString('dropboxAccessToken');
    }

    await _loadLatestJson();
  }

  Future<bool> checkAuthorized(bool authorize) async {
    final token = await Dropbox.getAccessToken();
    if (token != null) {
      if (_accessToken == null || _accessToken!.isEmpty) {
        _accessToken = token;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('dropboxAccessToken', _accessToken!);
      }
      return true;
    }
    if (authorize) {
      if (_accessToken != null && _accessToken!.isNotEmpty) {
        await Dropbox.authorizeWithAccessToken(_accessToken!);
        final token = await Dropbox.getAccessToken();
        if (token != null) {
          log('authorizeWithAccessToken!');
          return true;
        }
      } else {
        await Dropbox.authorize();
        log('authorize!');
      }
    }
    return false;
  }

  Future authorize() async {
    await Dropbox.authorize();
  }

  Future unlink() async {
    await deleteAccessToken();
    await Dropbox.unlink();
  }

  Future authorizeWithAccessToken() async {
    await Dropbox.authorizeWithAccessToken(_accessToken!);
  }

  Future deleteAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('dropboxAccessToken');
  }

  Future<String?> getTemporaryLink(path) async {
    final result = await Dropbox.getTemporaryLink(path);
    return result;
  }

  Future<String?> getDropboxUrl(String sourcePath) async {
    if (await checkAuthorized(true)) {
      String? response = await getTemporaryLink(sourcePath);
      if (response == null) {
        return null;
      }

      if (response.contains("expired_access_token")) {
        await deleteAccessToken();
        await Dropbox.authorize();
        return getDropboxUrl(sourcePath);
      }

      return response;
    } else {
      return null;
    }
  }

  Future _loadLatestJson() async {
    var sourcePath = _location! + '/' + _latestInfoFileName;

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

    var index = _latestInfo?.cameras.indexOf(camera);
    index = index == null ? 1 : 1 + index;
    var sourcePath =
        "${_latestInfo?.dest}/${_latestInfo?.time}-high-$index-$camera.jpg";
    final String? link = await getDropboxUrl(sourcePath);
    return link;
  }
}
