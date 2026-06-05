/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

part of 'video_player_cubit.dart';

sealed class VideoPlayerState {
  final int width;
  final int height;
  final double aspectRatio;

  VideoPlayerState({
    this.width = 0,
    this.height = 0,
    this.aspectRatio = 0.0,
  });

  VideoPlayerState copyWith({
    int width,
    int height,
    double aspectRatio,
  });
}

final class VideoPlayerUpdateState extends VideoPlayerState {
  VideoPlayerUpdateState({
    super.width,
    super.height,
    super.aspectRatio,
  });

  @override
  VideoPlayerUpdateState copyWith({
    int? width,
    int? height,
    double? aspectRatio,
  }) {
    return VideoPlayerUpdateState(
      width: width ?? this.width,
      height: height ?? this.height,
      aspectRatio: aspectRatio ?? this.aspectRatio,
    );
  }
}
