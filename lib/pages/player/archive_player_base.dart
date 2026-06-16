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
import '../../cubit/viewer/archive_camera_view_cubit.dart';
import '../../cubit/viewer/archive_view_cubit.dart';
import '../../cubit/viewer/camera_view_state.dart';
import '../../cubit/viewer/view_state.dart';
import '../../models/camera.dart';
import '../../models/location.dart';
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
    extends PlayerBaseState<T> {
  @override
  void back(BuildContext context) => context.read<ArchiveViewCubit>().back();

  @override
  void quit(BuildContext context) => context.read<ArchiveViewCubit>().quit();

  @override
  void getStreamUrl(BuildContext context) => context
      .read<ArchiveCameraViewCubit>()
      .getStreamUrl(cameraName: widget.cameraName);

  @override
  void next(BuildContext context) => context.read<ArchiveViewCubit>().next();

  @override
  void previous(BuildContext context) =>
      context.read<ArchiveViewCubit>().previous();

  @override
  void toggleFullScreen(BuildContext context) =>
      context.read<ArchiveViewCubit>().toggleFullScreen();

  @override
  void updateCamera(BuildContext context, ViewUpdatedState state) =>
      context.read<ArchiveCameraViewCubit>().updateCamera(state);

  @override
  void updateSelectedCameraAndLocation(BuildContext context, Camera camera,
          Location location, bool isFreshState) =>
      context
          .read<ArchiveViewCubit>()
          .updateSelectedCameraAndLocation(camera, location, isFreshState);

  @override
  BlocListener<ArchiveCameraViewCubit, CameraViewState>
      createCameraViewBlocListener(
              void Function(BuildContext context, CameraViewState state)
                  listener) =>
          BlocListener<ArchiveCameraViewCubit, CameraViewState>(
              listener: listener);

  @override
  BlocListener<ArchiveViewCubit, ViewState> createViewBlocListener(
          void Function(BuildContext context, ViewState state) listener) =>
      BlocListener<ArchiveViewCubit, ViewState>(listener: listener);

  @override
  BlocProvider<ArchiveCameraViewCubit> createViewBlocProvider(
          BuildContext context, CameraPlayerStream playerStream) =>
      BlocProvider(
        create: (context) => ArchiveCameraViewCubit(
          playerStream,
          CameraViewData(
            widget.location,
            widget.camera,
            widget.credential,
            quality: StreamQuality.high,
            width: widget.maxWidth,
            height: widget.maxHeight,
            cameraIndex: widget.archiveIndex,
            startDateTime: widget.startDateTime,
          ),
        ),
      );

  @override
  BlocBuilder<ArchiveCameraViewCubit, CameraViewState>
      createCameraErrorViewBlocBuilder(
              Widget Function(BuildContext context, CameraViewState state)
                  builder) =>
          BlocBuilder<ArchiveCameraViewCubit, CameraViewState>(
            builder: builder,
          );
}
