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

  const AppSettingsState({
    this.startAppMaximized = false,
    this.playVideoFullscreen = false,
    this.enableAutoScreenCapture = true,
  });
}

final class AppSettingsInitialState extends AppSettingsState {}

final class AppSettingsUpdateState extends AppSettingsState {
  const AppSettingsUpdateState({
    super.startAppMaximized = false,
    super.playVideoFullscreen = false,
    super.enableAutoScreenCapture = true,
  });

  AppSettingsState copyWith({
    bool? startAppMaximized,
    bool? playVideoFullscreen,
    bool? enableAutoScreenCapture,
  }) {
    return AppSettingsUpdateState(
      startAppMaximized: startAppMaximized ?? this.startAppMaximized,
      playVideoFullscreen: playVideoFullscreen ?? this.playVideoFullscreen,
      enableAutoScreenCapture:
          enableAutoScreenCapture ?? this.enableAutoScreenCapture,
    );
  }
}
