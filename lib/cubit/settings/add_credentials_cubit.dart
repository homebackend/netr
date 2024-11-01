/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import '../../mixin/preferences.dart';
import '../../models/credential.dart';
import 'general_settings_cubit.dart';
import 'settings_common_cubit.dart';

class AddCredentialsCubit extends SettingsCommonCubit<Credential> {
  AddCredentialsCubit(Stream<GeneralSettingsState> stream)
      : super(Preferences.keyCredentials, stream);

  @override
  Credential fromJson(Map<String, dynamic> map) {
    return Credential.fromJson(map);
  }
}
