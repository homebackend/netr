/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter/widgets.dart';

import '../../mixin/preferences.dart';

abstract class SettingsCommonItemState with Preferences {
  final String stateName;
  final AutovalidateMode autovalidateMode;
  final int index;
  String name;

  SettingsCommonItemState(
    this.stateName, {
    this.autovalidateMode = AutovalidateMode.disabled,
    this.index = -1,
    this.name = '',
  });

  Future<void> loadDefaults() async {
    name = await loadString('$stateName.name') ?? name;
  }

  Future<void> saveDefaults() async {
    await saveString('$stateName.name', name);
  }
}
