/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter_bloc/flutter_bloc.dart';

part 'settings_navigation_state.dart';

class SettingsNavigationCubit extends Cubit<SettingsNavigationState> {
  final List<String> names;
  SettingsNavigationCubit(this.names) : super(SettingsNavigationState(0, names[0]));

  void setSelectedIndex(int index) {
    emit(SettingsNavigationState(index, names[index]));
  }
}
