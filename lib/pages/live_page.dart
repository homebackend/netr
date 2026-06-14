/*
 * Copyright (c) 2024-26 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/viewer/live_view_cubit.dart';
import '../cubit/viewer/view_state.dart';
import '../mixin/fields_common.dart';
import '../models/camera.dart';
import '../models/location.dart';
import '../widgets/stream_quality_selector.dart';
import 'camera_view_page.dart';
import 'player/live_player.dart';

class LiveViewPage extends CameraViewPage {
  const LiveViewPage({super.key}) : super('Live View', Icons.videocam);

  @override
  State<LiveViewPage> createState() => _LiveViewPageState();
}

class _LiveViewPageState extends CameraViewPageState<LiveViewPage>
    with FieldsCommon {
  StreamQuality streamQuality = StreamQuality.high;

  @override
  BlocBuilder blocBuilder({
    required Widget Function(BuildContext, ViewState) builder,
    bool Function(ViewState previous, ViewState current)? buildWhen,
  }) =>
      BlocBuilder<LiveViewCubit, ViewState>(
        builder: builder,
        buildWhen: buildWhen,
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
  LivePlayer getPlayer(
    double maxWidth,
    double maxHeight,
    ViewUpdatedState state,
    String playerTitle,
    String dialogText,
  ) =>
      LivePlayer(
        maxWidth,
        maxHeight,
        state.selectedCamera!,
        state.selectedLocation!,
        state.cameraCredential(state.selectedCamera!)!,
        state.streamQuality,
        state.cameras
            .map(
              (camera) => (
                camera,
                state.cameraLocation(camera)!,
                state.cameraCredential(camera)!,
              ),
            )
            .toList(),
        playerTitle,
        dialogText,
      );

  @override
  List<Widget> getAppBarActions() {
    return [
      Tooltip(
        message: 'Stream Quality',
        child: StreamQualitySelector(
          value: streamQuality == StreamQuality.high,
          onToggle: (value) {
            streamQuality = value ? StreamQuality.high : StreamQuality.low;
            context.read<LiveViewCubit>().updateStreamQuality(streamQuality);
          },
        ),
      )
    ];
  }
}
