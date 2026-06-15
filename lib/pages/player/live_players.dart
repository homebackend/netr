/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter/material.dart';
import 'package:netr/pages/player/live_player_base.dart';
import 'package:netr/pages/player/player_media_kit.dart';
import 'package:netr/pages/player/player_vlc_player.dart';

class DesktopLivePlayer extends LivePlayerBase {
  DesktopLivePlayer(super.maxWidth, super.maxHeight, super.state,
      super.playerTitle, super.dialogText,
      {super.key});

  @override
  State<DesktopLivePlayer> createState() => _DesktopLivePlayerState();
}

class _DesktopLivePlayerState extends LivePlayerBaseState<DesktopLivePlayer>
    with PlayerMediaKit {}

class AndroidLivePlayer extends LivePlayerBase {
  AndroidLivePlayer(super.maxWidth, super.maxHeight, super.state,
      super.playerTitle, super.dialogText,
      {super.key});

  @override
  State<AndroidLivePlayer> createState() => _AndroidLivePlayerState();
}

class _AndroidLivePlayerState extends LivePlayerBaseState<AndroidLivePlayer>
    with PlayerVlcPlayer {}
