/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'viewer/archive_view_cubit.dart';
import 'viewer/live_view_cubit.dart';
import 'viewer/view_state.dart';

class CubitCommon {
  static bool isFullScreen(ViewState s) =>
      s is ViewUpdatedState && s.fullScreen;

  static bool viewBuildWhen(ViewState previous, current,
      {bool Function(ViewUpdatedState previous, ViewUpdatedState current)?
          previousCurrentCheck}) {
    if (current is ViewUpdatedState) {
      if (current.isFreshState) {
        return true;
      }

      if (previous is ViewUpdatedState) {
        if (previous.selectedLocation?.name == current.selectedLocation?.name &&
            previous.selectedCamera?.name == current.selectedCamera?.name &&
            previous.fullScreen == current.fullScreen &&
            (previousCurrentCheck == null ||
                previousCurrentCheck(previous, current))) {
          return false;
        }
      }

      if (!current.isFreshState) {
        return false;
      }
    }

    return true;
  }

  static Widget cameraViewBlocBuilder(Widget Function() lvChild,
      Widget Function() avChild, Widget Function() otherChild) {
    return BlocBuilder<LiveViewCubit, ViewState>(
      buildWhen: viewBuildWhen,
      builder: (context, lvState) {
        return BlocBuilder<ArchiveViewCubit, ViewState>(
          buildWhen: viewBuildWhen,
          builder: (context, avState) => isFullScreen(lvState)
              ? lvChild()
              : isFullScreen(avState)
                  ? avChild()
                  : otherChild(),
        );
      },
    );
  }
}
