/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart';

import '../../cubit/viewer/archive_camera_view_cubit.dart';
import '../../cubit/viewer/archive_view_cubit.dart';
import '../../cubit/viewer/camera_view_state.dart';
import '../../cubit/viewer/view_state.dart';
import '../../models/camera.dart';
import '../../models/location.dart';
import 'player_base.dart';

class ArchivePlayer extends PlayerBase {
  final int archiveIndex;
  final DateTime startDateTime;

  const ArchivePlayer(
      super.maxWidth,
      super.maxHeight,
      super.camera,
      super.location,
      super.credential,
      this.archiveIndex,
      this.startDateTime,
      super.cameras,
      super.playerTitle,
      super.dialogText,
      {super.key});

  @override
  State<ArchivePlayer> createState() => _ArchivePlayerState();
}

class _ArchivePlayerState extends PlayerBaseState<ArchivePlayer> {
  @override
  void back(BuildContext context) => context.read<ArchiveViewCubit>().back();

  @override
  void getStreamUrl(BuildContext context) =>
      context.read<ArchiveCameraViewCubit>().getStreamUrl();

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
          BuildContext context, PlayerStream playerStream) =>
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
}
