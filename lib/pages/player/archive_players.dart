/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter/material.dart';

import 'archive_player_base.dart';
import 'player_media_kit.dart';
import 'player_vlc_player.dart';

class DesktopArchivePlayer extends ArchivePlayerBase {
  DesktopArchivePlayer(super.maxWidth, super.maxHeight, super.state,
      super.archiveDateTime, super.playerTitle, super.dialogText,
      {super.key});

  @override
  State<DesktopArchivePlayer> createState() => _DesktopArchivePlayerState();
}

class _DesktopArchivePlayerState
    extends ArchivePlayerBaseState<DesktopArchivePlayer> with PlayerMediaKit {}

class AndroidArchivePlayer extends ArchivePlayerBase {
  AndroidArchivePlayer(super.maxWidth, super.maxHeight, super.state,
      super.archiveDateTime, super.playerTitle, super.dialogText,
      {super.key});

  @override
  State<AndroidArchivePlayer> createState() => _AndroidArchivePlayerState();
}

class _AndroidArchivePlayerState
    extends ArchivePlayerBaseState<AndroidArchivePlayer> with PlayerVlcPlayer {}
