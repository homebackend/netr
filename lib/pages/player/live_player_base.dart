/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/mixin/camera_view_cubit_mixin.dart';
import '../../cubit/settings/app_settings_cubit.dart';
import '../../cubit/viewer/camera_view_state.dart';
import '../../cubit/viewer/live_camera_view_cubit.dart';
import '../../cubit/viewer/live_view_cubit.dart';
import '../../cubit/viewer/ssh_cubit.dart';
import '../../cubit/viewer/view_state.dart';
import '../../models/camera.dart';
import 'player_base.dart';

abstract class LivePlayerBase extends PlayerBase {
  final StreamQuality streamQuality;

  LivePlayerBase(double maxWidth, double maxHeight, ViewUpdatedState state,
      String playerTitle, String dialogText,
      {super.key})
      : streamQuality = state.streamQuality,
        super(
          maxWidth,
          maxHeight,
          state.selectedCamera!.name,
          state.selectedCamera!,
          state.selectedLocation!,
          state.cameraCredential(state.selectedCamera!)!,
          state.cameras
              .map(
                (camera) => (
                  camera,
                  camera,
                  state.cameraLocation(camera)!,
                  state.cameraCredential(camera)!,
                ),
              )
              .toList(),
          playerTitle,
          dialogText,
        );
}

abstract class LivePlayerBaseState<T extends LivePlayerBase>
    extends PlayerBaseState<T, LiveViewCubit, LiveCameraViewCubit> {
  @override
  BlocProvider<LiveCameraViewCubit> createViewBlocProvider(
          BuildContext context, CameraPlayerStream playerStream) =>
      BlocProvider(
        create: (context) => LiveCameraViewCubit(
          playerStream,
          CameraViewData(
            context.read<SshCubit>(),
            widget.location,
            widget.camera,
            widget.credential,
            physicalLocationName:
                context.read<AppSettingsCubit>().state.selectedLocation,
            quality: widget.streamQuality,
            width: widget.maxWidth,
            height: widget.maxHeight,
          ),
        ),
      );
}
