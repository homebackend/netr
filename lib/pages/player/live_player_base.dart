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
import '../../cubit/viewer/camera_view_state.dart';
import '../../cubit/viewer/live_camera_view_cubit.dart';
import '../../cubit/viewer/live_view_cubit.dart';
import '../../cubit/viewer/view_state.dart';
import '../../models/camera.dart';
import '../../models/location.dart';
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
    extends PlayerBaseState<T> {
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
          BuildContext context, CameraPlayerStream playerStream) =>
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

  @override
  BlocBuilder<LiveCameraViewCubit, CameraViewState>
      createCameraErrorViewBlocBuilder(
              Widget Function(BuildContext context, CameraViewState state)
                  builder) =>
          BlocBuilder<LiveCameraViewCubit, CameraViewState>(
            builder: builder,
          );
}
