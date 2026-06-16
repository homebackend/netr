/*
 * Copyright (c) 2024-26 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:media_kit/media_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'constants.dart' as constants;
import 'desktop_home_screen.dart';
import 'main_app.dart';
import 'mixin/encrypter.dart' as encrypter;
import 'tool.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (isDesktopPlatform()) {
    MediaKit.ensureInitialized();
    await windowManager.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setTitle(constants.appName);
      await windowManager.center();
      await windowManager.show();
      await windowManager.setPreventClose(true);
    });
  }
  await Settings.init(cacheProvider: SharePreferenceCache());
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? ivBase64 =
      prefs.getString(encrypter.keyEncryptionInitialisationVector);
  if (ivBase64 != null) {
    encrypter.encryptionIV = IV.fromBase64(ivBase64);
  } else {
    await prefs.setString(
      encrypter.keyEncryptionInitialisationVector,
      encrypter.encryptionIV.base64,
    );
  }

  return isDesktopPlatform()
      ? runApp(const MaterialApp(home: DesktopHomeScreen()))
      : runApp(const MainApp());
}
