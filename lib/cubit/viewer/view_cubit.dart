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
import 'view_state.dart';

abstract class ViewCubit extends Cubit<ViewState> {
  ViewCubit(super.initialState);

  String get cubitName;

  void emitState(
    List<Location> locations,
    List<Camera> cameras,
    List<Camera> nvrs,
    List<Credential> credentials,
  );

  void updateSelectedCameraAndLocation(
    Camera camera,
    Location location,
    bool isFreshState, {
    bool? fullScreen,
    bool? archiveView,
  });

  /* This function is called by to emit the next camera.
   * It emits the state corresponding to the next camera. */
  void next();

  /* This function is called by to emit the previous camera.
   * It emits the state corresponding to the previous camera. */
  void previous();

  void back();
  void toggleFullScreen();
}
