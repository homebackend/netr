/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

part of 'general_settings_cubit.dart';

@immutable
sealed class GeneralSettingsState {
  final bool reloadPreferences;
  final bool exportInProgress;
  final bool exportFailed;
  final bool shareInProgress;
  final bool shareFailed;
  final bool importInProgress;
  final bool importFailed;

  const GeneralSettingsState({
    this.reloadPreferences = false,
    this.exportInProgress = false,
    this.exportFailed = false,
    this.shareInProgress = false,
    this.shareFailed = false,
    this.importInProgress = false,
    this.importFailed = false,
  });

  GeneralSettingsState copyWith({
    bool? reloadPreferences,
    bool? exportInProgress,
    bool? exportFailed,
    bool? shareInProgress,
    bool? shareFailed,
    bool? importInProgress,
    bool? importFailed,
  });
}

final class GeneralSettingsUpdateState extends GeneralSettingsState {
  const GeneralSettingsUpdateState({
    super.reloadPreferences,
    super.exportInProgress,
    super.exportFailed,
    super.shareInProgress,
    super.shareFailed,
    super.importInProgress,
    super.importFailed,
  });

  @override
  GeneralSettingsState copyWith({
    bool? reloadPreferences,
    bool? exportInProgress,
    bool? exportFailed,
    bool? shareInProgress,
    bool? shareFailed,
    bool? importInProgress,
    bool? importFailed,
  }) {
    return GeneralSettingsUpdateState(
      reloadPreferences: reloadPreferences ?? this.reloadPreferences,
      exportInProgress: exportInProgress ?? this.exportInProgress,
      exportFailed: exportFailed ?? this.exportFailed,
      shareInProgress: shareInProgress ?? this.shareInProgress,
      shareFailed: shareFailed ?? this.shareFailed,
      importInProgress: importInProgress ?? this.importInProgress,
      importFailed: importFailed ?? this.importFailed,
    );
  }
}
