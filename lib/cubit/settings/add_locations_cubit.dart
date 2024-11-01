/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import '../../mixin/preferences.dart';
import '../../models/location.dart';
import 'general_settings_cubit.dart';
import 'settings_common_cubit.dart';

class AddLocationsCubit extends SettingsCommonCubit<Location> {
  AddLocationsCubit(Stream<GeneralSettingsState> stream)
      : super(Preferences.keyLocations, stream);

  @override
  Location fromJson(Map<String, dynamic> map) {
    return Location.fromJson(map);
  }
}
