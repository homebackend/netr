/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/camera.dart';
import '../../models/credential.dart';
import '../../models/location.dart';
import 'camera_view_state.dart';

abstract class CameraViewCubit extends Cubit<CameraViewState> {
  CameraViewCubit(super.initialState);

  String getUrlPath();

  Future<void> updateCamera(
    Camera camera,
    Location location,
    Credential credential,
    Camera? archive,
  );

  Future<void> getStreamUrl();
}
