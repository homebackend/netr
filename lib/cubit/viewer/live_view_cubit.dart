/*
 * Copyright (c) 2024-26 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../mixin/preferences.dart';
import '../../models/camera.dart';
import '../../models/credential.dart';
import '../../models/location.dart';
import '../mixin/view_cubit_mixin.dart';
import 'view_state.dart';

class LiveViewCubit extends Cubit<ViewState> with ViewCubitMixin, Preferences {
  LiveViewCubit() : super(ViewInitialState()) {
    _load();
  }

  Future<void> _load() async {
    List<Camera> cameras =
        await loadItems(Preferences.keyCameras, Camera.fromJson);
    List<Camera> nvrs = await loadItems(Preferences.keyNvrs, Camera.fromJson);
    List<Location> locations =
        await loadItems(Preferences.keyLocations, Location.fromJson);
    List<Credential> credentials =
        await loadItems(Preferences.keyCredentials, Credential.fromJson);

    emitState(locations, cameras, nvrs, credentials);
  }

  @override
  void next() => nextCamera();

  @override
  void previous() => previousCamera();
}
