/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

part of 'settings_common_cubit.dart';

sealed class SettingsCommonState {}

final class SettingsCommonInitialState extends SettingsCommonState {}

final class SettingsCommonUpdatedState<T> extends SettingsCommonState {
  final List<T> items;
  SettingsCommonUpdatedState(this.items);
}
