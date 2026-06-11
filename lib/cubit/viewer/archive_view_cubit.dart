/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/camera.dart';
import '../../models/location.dart';
import '../mixin/view_cubit_mixin.dart';
import 'live_view_cubit.dart';
import 'view_state.dart';

class ArchiveViewCubit extends Cubit<ViewState> with ViewCubitMixin {
  late final StreamSubscription _liveViewSubscription;

  ArchiveViewCubit(LiveViewCubit cubit) : super(ViewInitialState()) {
    if (cubit.state is ViewUpdatedState) {
      _emitState(cubit.state);
    }

    _liveViewSubscription = cubit.stream.listen((state) {
      _emitState(state);
    });
  }

  void _emitState(ViewState state) {
    if (state is ViewUpdatedState) {
      emitState(state.locations, state.cameras, state.nvrs, state.credentials);
    }
  }

  @override
  String get cubitName => 'ArchiveViewCubit';

  @override
  Future<void> close() {
    _liveViewSubscription.cancel();
    return super.close();
  }

  bool _criteria(Location l, Camera c) =>
      c.archiveName.isNotEmpty && c.archiveIndex >= 0;

  @override
  void next() => nextCamera(criteria: _criteria);

  @override
  void previous() => previousCamera(criteria: _criteria);
}
