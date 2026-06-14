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

import '../../cubit/viewer/camera_view_state.dart';
import '../../cubit/viewer/live_camera_view_cubit.dart';
import '../../cubit/viewer/live_view_cubit.dart';
import '../../cubit/viewer/view_state.dart';
import '../../models/camera.dart';
import '../../models/location.dart';
import 'player_base.dart';

class LivePlayer extends PlayerBase {
  final StreamQuality streamQuality;

  const LivePlayer(
      super.maxWidth,
      super.maxHeight,
      super.cameraName,
      super.camera,
      super.location,
      super.credential,
      this.streamQuality,
      super.cameras,
      super.playerTitle,
      super.dialogText,
      {super.key});

  @override
  State<LivePlayer> createState() => _LivePlayerState();
}

class _LivePlayerState extends PlayerBaseState<LivePlayer> {
  @override
  void toggleFullScreen(BuildContext context) =>
      context.read<LiveViewCubit>().toggleFullScreen();

  @override
  void back(BuildContext context) => context.read<LiveViewCubit>().back();

  @override
  void next(BuildContext context) => context.read<LiveViewCubit>().next();

  @override
  void previous(BuildContext context) =>
      context.read<LiveViewCubit>().previous();

  @override
  void updateSelectedCameraAndLocation(
    BuildContext context,
    Camera camera,
    Location location,
    bool isFreshState,
  ) =>
      context
          .read<LiveViewCubit>()
          .updateSelectedCameraAndLocation(camera, location, isFreshState);

  @override
  void getStreamUrl(BuildContext context) =>
      context.read<LiveCameraViewCubit>().getStreamUrl();

  @override
  void updateCamera(BuildContext context, ViewUpdatedState state) =>
      context.read<LiveCameraViewCubit>().updateCamera(state);

  @override
  BlocProvider<LiveCameraViewCubit> createViewBlocProvider(
          BuildContext context, PlayerStream playerStream) =>
      BlocProvider(
        create: (context) => LiveCameraViewCubit(
          playerStream,
          CameraViewData(
            widget.location,
            widget.camera,
            widget.credential,
            quality: widget.streamQuality,
            width: widget.maxWidth,
            height: widget.maxHeight,
          ),
        ),
      );

  @override
  BlocListener<LiveViewCubit, ViewState> createViewBlocListener(
          void Function(BuildContext context, ViewState state) listener) =>
      BlocListener<LiveViewCubit, ViewState>(listener: listener);

  @override
  BlocListener<LiveCameraViewCubit, CameraViewState>
      createCameraViewBlocListener(
              void Function(BuildContext context, CameraViewState state)
                  listener) =>
          BlocListener<LiveCameraViewCubit, CameraViewState>(
              listener: listener);
}
