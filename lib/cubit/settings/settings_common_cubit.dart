/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../mixin/preferences.dart';
import '../../models/settings_item.dart';
import 'general_settings_cubit.dart';

part 'settings_common_state.dart';

abstract class SettingsCommonCubit<T extends SettingsItem>
    extends Cubit<SettingsCommonState> with Preferences {
  final List<T> items = [];
  final String _keyItems;
  late StreamSubscription _settingsSubscription;

  SettingsCommonCubit(this._keyItems, Stream<GeneralSettingsState> stream)
      : super(SettingsCommonInitialState()) {
    _settingsSubscription = stream.listen((state) {
      if (state.reloadPreferences) {
        reload();
      }
    });

    _load();
  }

  @override
  Future<void> close() async {
    await _settingsSubscription.cancel();
    return super.close();
  }

  void addItem(T item) async {
    items.add(item.copySelf() as T);
    await _save();
    emit(SettingsCommonUpdatedState(items));
  }

  void editItem(int index, T item) async {
    items.replaceRange(index, index + 1, [item.copySelf() as T]);
    await _save();
    emit(SettingsCommonUpdatedState(items));
  }

  void removeLocation(int index) async {
    items.removeAt(index);
    await _save();
    if (items.isEmpty) {
      emit(SettingsCommonInitialState());
    } else {
      emit(SettingsCommonUpdatedState(items));
    }
  }

  void reload() async {
    emit(SettingsCommonInitialState());
    await _load();
    emit(SettingsCommonUpdatedState(items));
  }

  T fromJson(Map<String, dynamic> map);

  Future<void> _load() async {
    await loadItems(_keyItems, fromJson, items: items);
    emit(SettingsCommonUpdatedState(items));
  }

  Future<void> _save() async {
    await saveItems(_keyItems, items);
  }
}
