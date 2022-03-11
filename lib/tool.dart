import 'config.dart';

import 'package:flutter/material.dart';

Widget createIconButton(IconData icon, VoidCallback? handler, [String? text]) {
  text ??= '';
  return ElevatedButton.icon(
    icon: Icon(icon),
    onPressed: handler,
    label: Text(text),
  );
}

Widget createButton(String text, VoidCallback? handler) {
  return ElevatedButton(
    child: Text(text),
    onPressed: handler,
  );
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
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
    switch(this) {
      case VideoStreamType.live:
        return 'Live View';
      case VideoStreamType.archive:
        return 'Archive View';
    }
  }
}
