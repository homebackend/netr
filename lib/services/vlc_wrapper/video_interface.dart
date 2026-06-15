/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'dart:io' show Platform;
import 'dart:typed_data';
import 'package:flutter/material.dart';

// Import both platform backends directly
import 'package:media_kit/media_kit.dart' as mk;
import 'package:media_kit_video/media_kit_video.dart' as mkv;
import 'media_kit_vlc_android.dart' as vlc;

// 1. Unify the Log Enum Link
typedef MPVLogLevel = mk.MPVLogLevel;

// 2. Unify the Media Parameter Blueprint
class Media {
  final String url;
  Media(this.url);
}

// 3. Unify the Stream Proxy Layout
class PlayerStream {
  final dynamic _underlyingStream;

  PlayerStream(this._underlyingStream);

  Stream<bool> get buffering => _underlyingStream.buffering as Stream<bool>;
  Stream<bool> get playing => _underlyingStream.playing as Stream<bool>;
  Stream<dynamic> get error => _underlyingStream.error as Stream<dynamic>;
  Stream<int?> get width => _underlyingStream.width as Stream<int?>;
  Stream<int?> get height => _underlyingStream.height as Stream<int?>;
}

// 4. Corrected Core PlayerConfiguration Proxy Layout
class PlayerConfiguration {
  final MPVLogLevel logLevel;
  final String? title;
  final int bufferSize;
  final bool osc;

  const PlayerConfiguration({
    this.logLevel = MPVLogLevel.error,
    this.title,
    this.bufferSize = 32 * 1024 * 1024,
    this.osc = true,
  });

  // Map to genuine media_kit parameters cleanly
  mk.PlayerConfiguration toMediaKit() {
    return mk.PlayerConfiguration(
      logLevel: logLevel,
      title: title ?? 'Netr',
      bufferSize: bufferSize,
      osc: osc,
    );
  }

  // Map to custom VLC wrapper parameters cleanly
  vlc.PlayerConfiguration toVlc() {
    return vlc.PlayerConfiguration(
      logLevel: vlc.MPVLogLevel.values[logLevel.index],
      title: title,
      bufferSize: bufferSize,
      osc: osc,
    );
  }
}

// 5. Unify the Player Class Proxy
class Player {
  final PlayerConfiguration configuration;

  late final mk.Player? _linuxPlayer;
  late final vlc.Player? _androidPlayer;
  late final PlayerStream stream;

  Player({this.configuration = const PlayerConfiguration()}) {
    if (Platform.isLinux) {
      _linuxPlayer = mk.Player(configuration: configuration.toMediaKit());
      _androidPlayer = null;
      stream = PlayerStream(_linuxPlayer!.stream);
    } else {
      _linuxPlayer = null;
      _androidPlayer = vlc.Player(configuration: configuration.toVlc());
      stream = PlayerStream(_androidPlayer!.stream);
    }
  }

  dynamic get underlyingPlayer =>
      Platform.isLinux ? _linuxPlayer : _androidPlayer;
  dynamic get state =>
      Platform.isLinux ? _linuxPlayer!.state : _androidPlayer!.state;

  Future<void> open(Media media, {bool play = true}) async {
    if (Platform.isLinux) {
      await _linuxPlayer!.open(mk.Media(media.url), play: play);
    } else {
      await _androidPlayer!.open(vlc.Media(media.url), play: play);
    }
  }

  Future<void> playOrPause() async {
    if (Platform.isLinux) {
      await _linuxPlayer!.playOrPause();
    } else {
      await _androidPlayer!.playOrPause();
    }
  }

  Future<void> stop() async {
    if (Platform.isLinux) {
      await _linuxPlayer!.stop();
    } else {
      await _androidPlayer!.stop();
    }
  }

  Future<Uint8List?> screenshot({String format = 'image/jpeg'}) async {
    if (Platform.isLinux) {
      return await _linuxPlayer!.screenshot(format: format);
    } else {
      return await _androidPlayer!.screenshot(format: format);
    }
  }

  Future<void> dispose() async {
    if (Platform.isLinux) {
      await _linuxPlayer!.dispose();
    } else {
      await _androidPlayer!.dispose();
    }
  }
}

// 6. Unify the VideoController Proxy
class VideoController {
  final Player player;
  late final mkv.VideoController? _linuxController;
  late final vlc.VideoController? _androidController;

  VideoController(this.player) {
    if (Platform.isLinux) {
      _linuxController =
          mkv.VideoController(player.underlyingPlayer as mk.Player);
      _androidController = null;
    } else {
      _linuxController = null;
      _androidController =
          vlc.VideoController(player.underlyingPlayer as vlc.Player);
    }
  }

  dynamic get underlyingController =>
      Platform.isLinux ? _linuxController : _androidController;
}

// 7. Unify the Visual Video Widget Switcher
class Video extends StatelessWidget {
  final VideoController controller;
  final dynamic controls;

  const Video({
    super.key,
    required this.controller,
    this.controls,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isLinux) {
      return mkv.Video(
        controller: controller.underlyingController as mkv.VideoController,
        controls: controls,
      );
    } else {
      // 💡 Fixed: Changed typo from mlc to vlc wrapper target container reference
      return vlc.Video(
        controller: controller.underlyingController as vlc.VideoController,
        controls: controls,
      );
    }
  }
}
