/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

part of 'live_camera_view_cubit.dart';

@immutable
class LiveCameraViewState {}

final class LiveCameraViewUpdatedState extends LiveCameraViewState {
  final String url;

  LiveCameraViewUpdatedState(this.url);
}

final class LiveCameraViewErrorState extends LiveCameraViewState {
  final String error;

  LiveCameraViewErrorState(this.error);
}

final class LiveCameraViewBufferingState extends LiveCameraViewState {
  final double bufferingState;
  final bool bufferingDone;

  LiveCameraViewBufferingState(this.bufferingState, this.bufferingDone);
}

final class LiveCameraViewPlayingState extends LiveCameraViewState {
  final bool playing;

  LiveCameraViewPlayingState(this.playing);
}

final class LiveCameraViewVideoState extends LiveCameraViewState {
  final int width;
  final int height;

  LiveCameraViewVideoState(this.width, this.height);
}

final class LiveCameraViewDoneState extends LiveCameraViewState {}
