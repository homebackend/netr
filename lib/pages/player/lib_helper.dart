/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter/material.dart';

import '../../cubit/mixin/camera_view_cubit_mixin.dart';
import '../../cubit/viewer/video_player_cubit.dart';

abstract class LibHelper {
  String get playerTitle;
  String get cameraName;
  String get locationName;
  double get maxWidth;
  double get maxHeight;

  void initCamera(BuildContext context);
  void initLibHelper(BuildContext context);
  void disposeLibHelper();
  void startThumbnailGeneration(String cameraName, String locationName);
  CameraPlayerStream get stream;
  Future<void> open(String url);
  Future<void> stop(BuildContext context);
  Future<void> togglePlay();
  Widget createVideoWidget(BuildContext context, VideoPlayerState state);
}
