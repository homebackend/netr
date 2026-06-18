/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

part of 'app_settings_cubit.dart';

@immutable
sealed class AppSettingsState {
  final bool startAppMaximized;
  final bool playVideoFullscreen;
  final bool enableAutoScreenCapture;
  final String? selectedLocation;

  const AppSettingsState({
    this.startAppMaximized = false,
    this.playVideoFullscreen = false,
    this.enableAutoScreenCapture = true,
    this.selectedLocation,
  });
}

final class AppSettingsInitialState extends AppSettingsState {}

final class AppSettingsUpdateState extends AppSettingsState {
  const AppSettingsUpdateState({
    super.startAppMaximized = false,
    super.playVideoFullscreen = false,
    super.enableAutoScreenCapture = true,
    super.selectedLocation,
  });

  AppSettingsState copyWith({
    bool? startAppMaximized,
    bool? playVideoFullscreen,
    bool? enableAutoScreenCapture,
    String? selectedLocation,
  }) {
    return AppSettingsUpdateState(
      startAppMaximized: startAppMaximized ?? this.startAppMaximized,
      playVideoFullscreen: playVideoFullscreen ?? this.playVideoFullscreen,
      enableAutoScreenCapture:
          enableAutoScreenCapture ?? this.enableAutoScreenCapture,
      selectedLocation: selectedLocation ?? this.selectedLocation,
    );
  }
}
