/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'viewer/live_view_cubit.dart';

class CubitCommon {
  static bool liveViewBuildWhen(LiveViewState previous, current) {
    if (current is LiveViewUpdatedState) {
      if (current.isFreshState) {
        return true;
      }

      if (previous is LiveViewUpdatedState) {
        if (previous.selectedLocation?.name == current.selectedLocation?.name &&
            previous.selectedCamera?.name == current.selectedCamera?.name &&
            previous.fullScreen == current.fullScreen) {
          return false;
        }
      }

      if (!current.isFreshState) {
        return false;
      }
    }

    return true;
  }
}
