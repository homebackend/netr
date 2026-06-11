/*
 * Copyright (c) 2024-26 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart';

import '../cubit/viewer/camera_view_state.dart';
import '../cubit/viewer/live_camera_view_cubit.dart';
import '../cubit/viewer/live_view_cubit.dart';
import '../cubit/viewer/view_state.dart';
import '../models/camera.dart';
import '../models/location.dart';
import 'camera_view_page.dart';

class LiveViewPage extends CameraViewPage {
  const LiveViewPage({super.key}) : super('Live View', Icons.videocam);

  @override
  State<LiveViewPage> createState() => _LiveViewPageState();
}

class _LiveViewPageState extends CameraViewPageState<LiveViewCubit,
    LiveCameraViewCubit, LiveViewPage> {
  /* This function creates a cubit that will be used to switch
   * between the availble CCTVs. Note it sends the actual Camera
   * values corresponding to the CCTV has the live view.
   */
  @override
  LiveCameraViewCubit createCubit(PlayerStream playerStream,
          ViewUpdatedState state, double maxWidth, double maxHeight) =>
      LiveCameraViewCubit(
        playerStream,
        CameraViewData(
          state.selectedLocation!,
          state.selectedCamera!,
          state.cameraCredential(state.selectedCamera!)!,
          quality: StreamQuality.high,
          width: maxWidth,
          height: maxHeight,
        ),
      );

  @override
  void updateCubit(
          ViewUpdatedState state,
          Future<void> Function(ViewUpdatedState vuState,
                  {DateTime? startDateTime})
              updator) =>
      updator(state);

  @override
  Iterable<Camera> getCameras(List<Camera> cameras) => cameras;

  @override
  int getCameraCount(List<Camera> cameras) => cameras.length;

  @override
  void cameraTapHandler(BuildContext bc, Location l, Camera c, bool fs) {
    bc
        .read<LiveViewCubit>()
        .updateSelectedCameraAndLocation(c, l, true, fullScreen: fs);
  }

  @override
  List<Widget>? getAppBarActions() {
    return null;
  }
}
