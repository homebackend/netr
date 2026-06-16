/*
 * Copyright (c) 2024-26 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'dart:developer';
import 'dart:io' show Platform, File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget createIconButton(
  IconData icon,
  VoidCallback? handler, [
  String? text,
  ButtonStyle? style,
  bool autofocus = false,
  bool usePlayButtonAsEnter = false,
]) {
  final Widget button = text == null || text.isEmpty
      ? ElevatedButton(
          autofocus: autofocus,
          onPressed: handler,
          style: style,
          child: Icon(icon),
        )
      : ElevatedButton.icon(
          autofocus: autofocus,
          icon: Icon(icon),
          onPressed: handler,
          label: Text(text),
          style: style,
        );

  if (!usePlayButtonAsEnter) return button;

  return Shortcuts(
    shortcuts: <ShortcutActivator, Intent>{
      const SingleActivator(LogicalKeyboardKey.mediaPlay):
          const ActivateIntent(),
      const SingleActivator(LogicalKeyboardKey.mediaPlayPause):
          const ActivateIntent(),
    },
    child: button,
  );
}

Widget createNavigatorButton(IconData icon, VoidCallback? handler) {
  return createIconButton(
    icon,
    handler,
    "",
    ButtonStyle(
      foregroundColor: WidgetStateProperty.all(Colors.blue),
      backgroundColor: WidgetStateProperty.all(Colors.black54),
    ),
  );
}

Widget createButton(String text, VoidCallback? handler,
    [ButtonStyle? style, bool autofocus = false]) {
  return ElevatedButton(
    autofocus: autofocus,
    onPressed: handler,
    style: style,
    child: Text(text),
  );
}

void showSnackBar(BuildContext context, String message, {Duration? timeout}) {
  final snackBar = SnackBar(
    content: Text(message),
    duration: timeout ?? const Duration(seconds: 3),
    persist: false,
    action: SnackBarAction(
      label: 'Ok',
      onPressed: () {},
    ),
  );
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void showAlertDialog(BuildContext context, String message, [int duration = 5]) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(Duration(seconds: duration), () {
          Navigator.of(context).pop(true);
        });

        return AlertDialog(
          title: Text(message),
        );
      });
}

Widget getBusyIndicator() {
  return const Center(child: CircularProgressIndicator());
}

String toDisplayText(String text) {
  List<String> splits = text.split('-');
  if (splits.length == 1) {
    return splits[0][0].toUpperCase() + splits[0].substring(1);
  }

  List<String> ret = [];
  for (String split in splits) {
    ret.add(toDisplayText(split));
  }

  return ret.join(' ');
}

bool isStringEmptyOrNull(String? value) {
  return value == null || value.isNotEmpty;
}

bool isDesktopPlatform() =>
    !kIsWeb && (isLinuxPlatform() || isWindowsPlatform() || isMacOSPlatform());
bool isWindowsPlatform() => Platform.isWindows;
bool isLinuxPlatform() => Platform.isLinux;
bool isMacOSPlatform() => Platform.isMacOS;
bool isMobilePlatform() => !kIsWeb && (isAndroidPlatform() || isIOSPlatform());
bool isAndroidPlatform() => !kIsWeb && Platform.isAndroid;
bool isIOSPlatform() => !kIsWeb && Platform.isIOS;
bool isWebPlatform() => kIsWeb;

bool isArchLinuxDistribution() {
  try {
    final File osReleaseFile = File('/etc/os-release');
    if (osReleaseFile.existsSync()) {
      final String contents = osReleaseFile.readAsStringSync().toLowerCase();

      return contents.contains('id=arch') ||
          contents.contains('id=manjaro') ||
          contents.contains('id_like=arch');
    }
  } catch (e) {
    log('Failed inspecting system distribution configuration settings: $e');
  }
  return false;
}

enum ViewerMode {
  none,
  picture,
  pictureArchive,
  remoteVlc,
  inAppVideo,
}

extension ViewerModeExtension on ViewerMode {
  String get displayTitle {
    switch (this) {
      case ViewerMode.picture:
        return 'Picture';
      case ViewerMode.pictureArchive:
        return 'Picture Archive';
      case ViewerMode.remoteVlc:
        return 'Remote for Vlc';
      case ViewerMode.inAppVideo:
        return 'Video in App';
      default:
        return 'Unknown';
    }
  }

  IconData get iconData {
    switch (this) {
      case ViewerMode.picture:
        return Icons.photo;
      case ViewerMode.pictureArchive:
        return Icons.photo_album;
      case ViewerMode.remoteVlc:
        return Icons.settings_remote;
      case ViewerMode.inAppVideo:
        return Icons.live_tv;
      case ViewerMode.none:
        return Icons.no_cell;
    }
  }
}

enum VideoStreamMode { streamDirect, streamOverSsh }

extension VideoStreamModeExtension on VideoStreamMode {
  String get displayTitle {
    switch (this) {
      case VideoStreamMode.streamDirect:
        return 'Stream Directly';
      case VideoStreamMode.streamOverSsh:
        return 'Stream Over SSH';
    }
  }
}

enum VideoStreamType { live, archive }

extension VideoStreamTypeExtension on VideoStreamType {
  String get displayTitle {
    switch (this) {
      case VideoStreamType.live:
        return 'Live View';
      case VideoStreamType.archive:
        return 'Archive View';
    }
  }
}
