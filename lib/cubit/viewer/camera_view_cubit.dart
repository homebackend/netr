/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/camera.dart';
import 'camera_view_state.dart';
import 'view_state.dart';

abstract class CameraViewCubit extends Cubit<CameraViewState> {
  CameraViewCubit(super.initialState);

  String get cubitName;

  String getUrlPath();

  Future<void> updateStreamQuality(StreamQuality streamQuality);

  /* This function is used to emit the url corresponding to the
   * values passed as argument. This function gets triggered in
   * response to ViewCubit.next() or ViewCubit.previous. The 
   * arguments sent should correspond to the actual camera or 
   * NVR as the case may be. This function internally calls 
   * getStreamUrl() to emit the url. */
  Future<void> updateCamera(ViewUpdatedState vuState,
      {DateTime? startDateTime});

  void emitUrlState(
      {String? cameraName, String? locationName, String? host, int? port});

  /* This function is used to emit the url corresponding to the
   * state stored in the cubit. */
  Future<void> getStreamUrl({String? cameraName, String? locationName});
}
