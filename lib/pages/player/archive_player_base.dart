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
import '../../cubit/viewer/archive_camera_view_cubit.dart';
import '../../cubit/viewer/archive_view_cubit.dart';
import '../../cubit/viewer/camera_view_state.dart';
import '../../cubit/viewer/ssh_cubit.dart';
import '../../cubit/viewer/view_state.dart';
import '../../models/camera.dart';
import 'player_base.dart';

abstract class ArchivePlayerBase extends PlayerBase {
  final int archiveIndex;
  final DateTime startDateTime;

  ArchivePlayerBase(double maxWidth, double maxHeight, ViewUpdatedState state,
      DateTime archiveDateTime, String playerTitle, String dialogText,
      {super.key})
      : archiveIndex = state.selectedCamera!.archiveIndex,
        startDateTime = archiveDateTime,
        super(
          maxWidth,
          maxHeight,
          state.selectedCamera!.name,
          state.cameraNvr(state.selectedCamera!)!,
          state.selectedLocation!,
          state.cameraNvrCredential(state.selectedCamera!)!,
          state.cameras
              .map(
                (camera) => (
                  camera,
                  state.cameraNvr(camera)!,
                  state.cameraLocation(camera)!,
                  state.cameraNvrCredential(camera)!,
                ),
              )
              .toList(),
          playerTitle,
          dialogText,
        );
}

abstract class ArchivePlayerBaseState<T extends ArchivePlayerBase>
    extends PlayerBaseState<T, ArchiveViewCubit, ArchiveCameraViewCubit> {
  @override
  BlocProvider<ArchiveCameraViewCubit> createViewBlocProvider(
          BuildContext context, CameraPlayerStream playerStream) =>
      BlocProvider(
        create: (context) => ArchiveCameraViewCubit(
          playerStream,
          CameraViewData(
            context.read<SshCubit>(),
            widget.location,
            widget.camera,
            widget.credential,
            physicalLocationName:
                context.read<AppSettingsCubit>().state.selectedLocation,
            quality: StreamQuality.high,
            width: widget.maxWidth,
            height: widget.maxHeight,
            cameraIndex: widget.archiveIndex,
            startDateTime: widget.startDateTime,
          ),
        ),
      );
}
