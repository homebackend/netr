/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter_bloc/flutter_bloc.dart';

part 'video_player_state.dart';

class VideoPlayerCubit extends Cubit<VideoPlayerState> {
  VideoPlayerCubit() : super(VideoPlayerUpdateState());

  void updateWidthHeight(int width, int height) {
    double aspectRatio = width / height;
    emit(state.copyWith(
      width: width,
      height: height,
      aspectRatio: aspectRatio,
    ));
  }
}
