/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'settings_common_item_state.dart';

abstract class SettingsCommonItemCubit<S extends SettingsCommonItemState, T>
    extends Cubit<S> {
  SettingsCommonItemCubit(super.initialState);

  Future<void> loadStateDefaults();
  Future<void> saveStateDefaults() async {
    await state.saveDefaults();
  }
  void editData(int index, T item);
  void updateAutovalidateMode(AutovalidateMode? autovalidateMode);
  void updateName(String? name);
  void reset();
}
