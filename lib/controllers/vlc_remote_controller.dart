import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:netr/config.dart';
import 'package:http/http.dart' as http;
import 'package:netr/controllers/video_player_controller_interface.dart';

// Documentation: https://wiki.videolan.org/VLC_HTTP_requests/
class VlcRemoteController implements VideoPlayerControllerInterface {
  VlcRemoteController.network(this._url);

  String _url;
  bool _isPlaying = false;

  @override
  Future<void> setMediaFromNetwork(String dataSource, {
    bool? autoPlay,
  }) async {
    await _setStreamUrl(dataSource);
  }

  @override
  Future<void> play() async {
    String url = '/requests/status.xml?command=in_play&input=${Uri.encodeComponent(_url)}';
    await _processVlcUrl(url);
    _isPlaying = true;
  }

  @override
  Future<void> pause() async {
    String path = '/requests/status.xml?command=pl_pause';
    await _processVlcUrl(path);
    _isPlaying = false;
  }

  @override
  Future<void> stop() async {
    String path = '/requests/status.xml?command=pl_stop';
    await _processVlcUrl(path);
    _isPlaying = false;
  }

  @override
  Future<bool?> isPlaying() async {
    return _isPlaying;
  }

  Future _processVlcUrl(String path) async {
    String url =
        'http://${properties['vlc']['host']}:${properties['vlc']['port']}$path';
    log('Url: $url');
    String basicAuth = 'Basic ${base64Encode(utf8.encode(
            properties['vlc']['user'] + ':' + properties['vlc']['password']))}';
    try {
      var contents = await http.read(Uri.parse(url),
          headers: <String, String>{'authorization': basicAuth});
      log(contents);
    } on Exception catch (e) {
      log('Error: $e');
      throw 'Failed to process request: $e';
    }
  }

  Future<void> _setStreamUrl(String dataSource) async {
    _url = dataSource;
    await play();
  }

  @override
  void addListener(VoidCallback onInitListener,
      DoubleCallback bufferingListener,
      VoidCallback playingListener,
      VoidCallback stoppedListener,
      ErrorCallback errorListener) {
    //
  }

  @override
  void removeListener() {

  }

  @override
  bool isInitialized() {
    return true;
  }

  @override
  Future<void> dispose() async {

  }
}