/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../mixin/preferences.dart';

part 'app_settings_state.dart';

class AppSettingsCubit extends Cubit<AppSettingsState> with Preferences {
  static final String _keyStartAppMaximized = 'startAppMaximized';
  static final String _keyPlayVideoFullscreen = 'playVideoFullscreen';
  static final String _keyEnableAutoScreenCapture = 'enableAutoScreenCapture';
  static final String _keySelectedLocation = 'selectedLocation';

  AppSettingsCubit() : super(AppSettingsInitialState());

  Future<void> load() async {
    bool startAppMaximized = await loadBool(_keyStartAppMaximized) ?? false;
    bool playVideoFullScreen = await loadBool(_keyPlayVideoFullscreen) ?? false;
    bool enableAutoScreenCapture =
        await loadBool(_keyEnableAutoScreenCapture) ?? true;
    String? selectedLocation = await loadString(_keySelectedLocation);
    emit(AppSettingsUpdateState(
      startAppMaximized: startAppMaximized,
      playVideoFullscreen: playVideoFullScreen,
      enableAutoScreenCapture: enableAutoScreenCapture,
      selectedLocation: selectedLocation,
    ));
  }

  void setStartApplicationAsMaximized(bool value) async {
    if (state is AppSettingsUpdateState) {
      await saveBool(_keyStartAppMaximized, value);
      emit(
          (state as AppSettingsUpdateState).copyWith(startAppMaximized: value));
    }
  }

  void setPlayVideoFullScreen(bool value) async {
    if (state is AppSettingsUpdateState) {
      await saveBool(_keyPlayVideoFullscreen, value);
      emit((state as AppSettingsUpdateState)
          .copyWith(playVideoFullscreen: value));
    }
  }

  void setEnableAutoScreenCapture(bool value) async {
    if (state is AppSettingsUpdateState) {
      await saveBool(_keyEnableAutoScreenCapture, value);
      emit((state as AppSettingsUpdateState)
          .copyWith(enableAutoScreenCapture: value));
    }
  }

  void setSelectedLocation(String selectedLocation) async {
    if (state is AppSettingsUpdateState) {
      await saveString(_keySelectedLocation, selectedLocation);
      emit((state as AppSettingsUpdateState)
          .copyWith(selectedLocation: selectedLocation));
    }
  }
}
