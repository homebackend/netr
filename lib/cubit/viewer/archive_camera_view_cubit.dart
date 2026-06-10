/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart';

import '../mixin/camera_view_cubit_mixin.dart';
import 'camera_view_state.dart';

class ArchiveCameraViewCubit extends Cubit<CameraViewState>
    with CameraViewCubitMixin {
  late List<StreamSubscription> subscriptions;
  ArchiveCameraViewCubit(PlayerStream playerStream, CameraViewData data)
      : super(CameraViewInitialState(data)) {
    subscriptions = subscribe(playerStream);
  }

  @override
  Future<void> close() {
    for (var subscription in subscriptions) {
      subscription.cancel();
    }
    return super.close();
  }
}
