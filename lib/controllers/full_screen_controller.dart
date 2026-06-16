/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

import '../tool.dart';

class FullScreenController {
  static Future<void> enter() async {
    log("Entering fullscreen mode");

    if (isWebPlatform()) return;

    if (isMobilePlatform()) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else if (isDesktopPlatform()) {
      await windowManager.setFullScreen(true);
    }
  }

  static Future<void> exit() async {
    log("Exiting fullscreen mode");

    if (isWebPlatform()) return;

    if (isMobilePlatform()) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    } else if (isDesktopPlatform()) {
      await windowManager.setFullScreen(false);
    }
  }
}
