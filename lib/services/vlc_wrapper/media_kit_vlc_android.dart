/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'dart:async';
import 'dart:typed_data';

enum MPVLogLevel { none, info, error, warn, debug }

class PlayerConfiguration {
  final bool buffer;
  final bool ready;
  final String? title;
  final String? subtitle;
  final String? logBy;

  final MPVLogLevel logLevel;
  final int bufferSize;
  final bool osc;

  const PlayerConfiguration({
    this.buffer = true,
    this.ready = true,
    this.title,
    this.subtitle,
    this.logBy,
    this.logLevel = MPVLogLevel.none,
    this.bufferSize = 32 * 1024 * 1024,
    this.osc = true,
  });
}

class Media {
  final String url;
  Media(this.url);
}

class VideoController {
  final Player player;
  VideoController(this.player);
}

/*
class Video extends StatefulWidget {
  final VideoController controller;
  final dynamic controls;

  const Video({super.key, required this.controller, this.controls});

  @override
  State<Video> createState() => _VideoState();
}

class _VideoState extends State<Video> {
  bool _isNativeReady = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkInitialization();
  }

  // 💡 Safely poll the native initialization status before mounting the VlcPlayer widget
  void _checkInitialization() {
    final vlc = widget.controller.player.vlcController;

    if (vlc != null && vlc.value.isInitialized) {
      if (mounted) setState(() => _isNativeReady = true);
    } else {
      // Check again in 100ms if the native thread is still booting
      _timer = Timer(const Duration(milliseconds: 100), _checkInitialization);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vlc = widget.controller.player.vlcController;

    // 💡 Keeps acting as a perfect drop-in: returns the spinner
    // until the underlying Android native surface layer is 100% stable.
    if (vlc == null || !_isNativeReady) {
      return const Center(child: CircularProgressIndicator());
    }

    return VlcPlayer(
      controller: vlc,
      aspectRatio: vlc.value.size.width > 0
          ? vlc.value.size.width / vlc.value.size.height
          : 16 / 9,
      placeholder: const Center(child: CircularProgressIndicator()),
    );
  }
}
*/

///*
class Video extends StatelessWidget {
  final VideoController controller;
  final dynamic controls;

  const Video({super.key, required this.controller, this.controls});

  @override
  Widget build(BuildContext context) {
    if (!controller.player._isVlcInitialized) {
      log('XXXXXXXX Not initialized');
      return const Center(child: CircularProgressIndicator());
    }

    final vlc = controller.player.vlcController;

    if (vlc == null) {
      log('XXXXXXXX is null');
      return const Center(child: CircularProgressIndicator());
    }

    log('XXXXXXXXXXXXXXXX');
    return VlcPlayer(
      controller: vlc,
      aspectRatio: vlc.value.size.width > 0
          ? vlc.value.size.width / vlc.value.size.height
          : 16 / 9,
      placeholder: const Center(child: CircularProgressIndicator()),
    );
  }
}
//*/

class PlayerStream {
  final StreamController<bool> _bufferingController =
      StreamController<bool>.broadcast();
  final StreamController<bool> _playingController =
      StreamController<bool>.broadcast();
  final StreamController<dynamic> _errorController =
      StreamController<dynamic>.broadcast();
  final StreamController<int?> _widthController =
      StreamController<int?>.broadcast();
  final StreamController<int?> _heightController =
      StreamController<int?>.broadcast();

  Stream<bool> get buffering => _bufferingController.stream;
  Stream<bool> get playing => _playingController.stream;
  Stream<dynamic> get error => _errorController.stream;
  Stream<int?> get width => _widthController.stream;
  Stream<int?> get height => _heightController.stream;

  void dispose() {
    _bufferingController.close();
    _playingController.close();
    _errorController.close();
    _widthController.close();
    _heightController.close();
  }
}

class PlayerState {
  int? width;
  int? height;
}

class Player {
  final PlayerConfiguration configuration;
  VlcPlayerController? _vlcController;
  final PlayerStream stream = PlayerStream();
  final PlayerState state = PlayerState();
  bool _isVlcInitialized = false;
  bool _isVlcControllerInitialized = false;

  Player({this.configuration = const PlayerConfiguration()});

  VlcPlayerController? get vlcController => _vlcController;

  Future<void> open(Media media, {bool play = true}) async {
    if (_vlcController != null && _vlcController!.value.isInitialized) {
      log('open: setMediaFromNetwork');
      await _vlcController!.setMediaFromNetwork(media.url, autoPlay: play);
      return;
    }

    int vlcNetworkCacheMs = (configuration.bufferSize > 1024 * 64) ? 2000 : 500;

    log('open: network');
    _vlcController = VlcPlayerController.network(
      media.url,
      hwAcc: HwAcc.auto,
      autoPlay: play,
      options: VlcPlayerOptions(
          /*advanced: VlcAdvancedOptions([
          VlcAdvancedOptions.networkCaching(vlcNetworkCacheMs),
        ]),*/
          ),
    );

    _vlcController!.addListener(_onVlcStateChanged);
    _vlcController!.addOnInitListener(() {
      log('OnInitListener');
      _isVlcControllerInitialized = true;
    });
    log('Setting _isVlcInitialized true');
    _isVlcInitialized = true;
  }

  void _onVlcStateChanged() {
    log('in _onVlcStateChanged');
    if (_vlcController != null /* && _vlcController!.value.isInitialized*/) {
      log('YYYYYYYYYYYYYYYYYYYYYYYYYYY');
      final value = _vlcController!.value;

      stream._playingController.add(value.isPlaying);

      final isBufferingNow = value.playingState == PlayingState.buffering;
      stream._bufferingController.add(isBufferingNow);

      if (value.hasError) {
        stream._errorController.add(value.errorDescription);
      }

      if (value.size.width > 0 && value.size.width.toInt() != state.width) {
        state.width = value.size.width.toInt();
        state.height = value.size.height.toInt();
        stream._widthController.add(state.width);
        stream._heightController.add(state.height);
      }
    }
  }

  Future<void> playOrPause() async {
    if (_vlcController == null) return;
    if (await _vlcController!.isPlaying() ?? false) {
      await _vlcController!.pause();
    } else {
      await _vlcController!.play();
    }
  }

  Future<void> stop() async {
    if (_isVlcControllerInitialized &&
        (await _vlcController!.isPlaying() ?? false)) {
      await _vlcController?.stop();
    }
  }

  Future<Uint8List?> screenshot(String s,
      {String format = 'image/jpeg'}) async {
    if (_vlcController == null) return null;
    return await _vlcController!.takeSnapshot();
  }

  Future<void> dispose() async {
    if (_isVlcInitialized && _vlcController != null) {
      _vlcController!.removeListener(_onVlcStateChanged);
      await _vlcController!.stopRendererScanning();
      await _vlcController!.dispose();
    }
    stream.dispose();
  }
}
