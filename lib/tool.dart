import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget _wrapInRawKeyboardListener(ElevatedButton widget, String? label,
    [bool usePlayButtonAsEnter = false]) {
  return RawKeyboardListener(
    focusNode: FocusNode(),
    onKey: (RawKeyEvent event) {
      if (event is RawKeyDownEvent) {
        if (event.isKeyPressed(LogicalKeyboardKey.enter) ||
            event.isKeyPressed(LogicalKeyboardKey.select) ||
            (usePlayButtonAsEnter &&
                (event.isKeyPressed(LogicalKeyboardKey.mediaPlay) ||
                    event.isKeyPressed(LogicalKeyboardKey.mediaPlayPause)))) {
          if (widget.onPressed != null) {
            widget.onPressed!();
          }
        }
      }
    },
    child: widget,
  );
}

Widget createIconButton(IconData icon, VoidCallback? handler,
    [String? text,
    ButtonStyle? style,
    bool autofocus = false,
    bool usePlayButtonAsEnter = false]) {
  text ??= '';
  ElevatedButton button = ElevatedButton.icon(
    autofocus: autofocus,
    icon: Icon(icon),
    onPressed: handler,
    label: Text(text),
    style: style,
  );

  return _wrapInRawKeyboardListener(button, text, usePlayButtonAsEnter);
}

Widget createNavigatorButton(IconData icon, VoidCallback? handler) {
  return createIconButton(
    icon,
    handler,
    "",
    ButtonStyle(
      foregroundColor: MaterialStateProperty.all(Colors.blue),
      backgroundColor: MaterialStateProperty.all(Colors.black54),
    ),
  );
}

Widget createButton(String text, VoidCallback? handler,
    [ButtonStyle? style, bool autofocus = false]) {
  ElevatedButton button = ElevatedButton(
    autofocus: autofocus,
    onPressed: handler,
    style: style,
    child: Text(text),
  );

  return _wrapInRawKeyboardListener(button, text);
}

void showSnackBar(context, message) {
  final snackBar = SnackBar(
    content: Text(message),
    action: SnackBarAction(
      label: 'Ok',
      onPressed: () {
        // Some code to undo the change.
      },
    ),
  );
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void showAlertDialog(context, message, [int duration = 5]) {
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

bool isDesktopPlatform() {
  return !kIsWeb &&
      (Platform.isLinux || Platform.isWindows || Platform.isMacOS);
}

bool isMobilePlatform() {
  return !kIsWeb && (Platform.isAndroid || Platform.isIOS);
}

bool isAndroidPlatform() {
  return !kIsWeb && Platform.isAndroid;
}

bool isWebPlatform() {
  return kIsWeb;
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
