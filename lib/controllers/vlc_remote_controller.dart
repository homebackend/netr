import 'dart:convert';
import 'dart:developer';

import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:http/http.dart' as http;

import '../config.dart';

class VlcRemoteController extends VlcPlayerController {
  VlcRemoteController.network(this._url) : super.network('');

  String _url;
  bool _isPlaying = false;

  @override
  VlcPlayerValue value = VlcPlayerValue(isInitialized: true, duration: const Duration(days: 1));

  @override
  Future<void> setMediaFromNetwork(
    String dataSource, {
    bool? autoPlay,
    HwAcc? hwAcc,
  }) async {
    await _setStreamUrl(
      dataSource,
      dataSourceType: DataSourceType.network,
      package: null,
      autoPlay: autoPlay,
      hwAcc: hwAcc,
    );
  }

  @override
  Future<void> play() async {
    _throwIfNotInitialized('play');
    String url = '/requests/status.xml?command=in_play&input=' +
        Uri.encodeComponent(_url);
    await _processVlcUrl(url);
    _isPlaying = true;
  }

  @override
  Future<void> stop() async {
    _throwIfNotInitialized('stop');
    String path = '/requests/status.xml?command=pl_stop';
    await _processVlcUrl(path);
    _isPlaying = false;
  }

  @override
  Future<bool?> isPlaying() async {
    _throwIfNotInitialized('isPlaying');
    return _isPlaying;
  }

  // Documentation: https://wiki.videolan.org/VLC_HTTP_requests/
  Future _processVlcUrl(String path) async {
    String url =
        'http://${properties['vlc']['host']}:${properties['vlc']['port']}$path';
    log('Url: $url');
    String basicAuth = 'Basic ' +
        base64Encode(utf8.encode(
            properties['vlc']['user'] + ':' + properties['vlc']['password']));
    try {
      var contents = await http.read(Uri.parse(url),
          headers: <String, String>{'authorization': basicAuth});
      log(contents);
    } on Exception catch (e) {
      log('Error: $e');
      throw 'Failed to process request: $e';
    }
  }

  void _throwIfNotInitialized(String functionName) {}

  Future<void> _setStreamUrl(
    String dataSource, {
    required DataSourceType dataSourceType,
    String? package,
    bool? autoPlay,
    HwAcc? hwAcc,
  }) async {
    _throwIfNotInitialized('setStreamUrl');
    _url = dataSource;
    await play();
  }
}
