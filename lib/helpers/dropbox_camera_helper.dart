import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:netr/config.dart';
import 'package:netr/helpers/camera_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class DropboxCameraHelper extends CameraHelper {
  final int _maxApiRetries = 3;
  String? _accessToken;
  String location;
  bool _initialized = false;

  DropboxCameraHelper(
      OnLoadHandler onLoadHandler, OnErrorHandler onErrorHandler)
      : location = "/${properties['defaultImageLocation']}",
        super(onLoadHandler, onErrorHandler);

  Future<bool> _authenticateUsingRefreshToken() async {
    _initialized = true;
    Response? response =
        await _postDropboxRequestWithBasicAuthentication('/oauth2/token', {
      'grant_type': 'refresh_token',
      'refresh_token': properties['images'][location]['refreshToken'],
    });

    if (response == null) {
      return false;
    } else if (response.statusCode == 200) {
      log('Successfully acquired access token');
      Map<String, dynamic> json = jsonDecode(response.body);
      _accessToken = json['access_token'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('dropboxAccessToken', _accessToken!);
      return true;
    } else {
      log('Error [${response.statusCode}]: ${response.body}');
      return false;
    }
  }

  Future<Response?> _postDropboxRequestWithBasicAuthentication(
      String url, Object body) async {
    String key = properties['images'][location]['key'];
    String secret = properties['images'][location]['secret'];
    String authorization = "Basic ${base64Encode(utf8.encode('$key:$secret'))}";
    return _postDropboxRequest(
        url, 'application/x-www-form-urlencoded', authorization, body);
  }

  Future<Response?> _postDropboxRequestWithAccessToken(String url, Object body,
      [int retries = 1]) async {
    if (!_initialized) {
      await _authenticateUsingRefreshToken();
    }

    String authorization = 'Bearer $_accessToken';
    Response? response =
        await _postDropboxRequest(url, 'application/json', authorization, body);
    if (response == null) {
      return response;
    } else if (retries <= _maxApiRetries &&
        response.statusCode == 401 &&
        response.body.contains('expired_access_token')) {
      log('Access Token has expired. Will try refreshing token ...');
      await _authenticateUsingRefreshToken();
      return _postDropboxRequestWithAccessToken(url, body, retries + 1);
    } else {
      return response;
    }
  }

  Future<Response?> _postDropboxRequest(
      String url, String contentType, String authorization, Object body) async {
    try {
      var headers = {
        'authorization': authorization,
        'content-type': contentType,
      };
      return await http.post(Uri.parse('https://api.dropbox.com$url'),
          headers: headers, body: body);
    } catch (e) {
      log('Error executing dropbox request [$url]: $e');
      return null;
    }
  }

  Future<bool> fileExists(path) async {
    Response? response = await _postDropboxRequestWithAccessToken(
        '/2/files/get_metadata', '{"path": "$path"}');

    if (response == null) {
      return false;
    } else if (response.statusCode == 200) {
      return true;
    } else {
      log('Error [${response.statusCode}]: ${response.body}');
      return false;
    }
  }

  Future<String?> getDropboxUrl(String sourcePath) async {
    Response? response = await _postDropboxRequestWithAccessToken(
        '/2/files/get_temporary_link', '{"path": "$sourcePath"}');
    if (response == null) {
      return null;
    } else if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      String link = json['link'] as String;
      log('Dropbox url is $link');
      return link;
    } else {
      log('Error [${response.statusCode}]: ${response.body}');
      return null;
    }
  }

  @override
  String getDefaultLocation(String camera) {
    return properties['defaultImageLocation'];
  }

  @override
  List<String> getLocations(String camera) {
    List<String> locations = [];
    properties['images'].keys.forEach((location) {
      locations.add(location);
    });
    return locations;
  }
}
