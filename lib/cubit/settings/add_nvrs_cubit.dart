/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import '../../mixin/preferences.dart';
import '../../models/camera.dart';
import 'general_settings_cubit.dart';
import 'settings_common_cubit.dart';

class AddNvrsCubit extends SettingsCommonCubit<Camera> {
  AddNvrsCubit(Stream<GeneralSettingsState> stream) : super(Preferences.keyNvrs, stream);

  @override
  Camera fromJson(Map<String, dynamic> map) {
    return Camera.fromJson(map);
  }
}
