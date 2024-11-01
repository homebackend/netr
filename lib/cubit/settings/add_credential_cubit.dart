/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter/material.dart';

import '../../models/credential.dart';
import 'settings_common_item_cubit.dart';
import 'settings_common_item_state.dart';

part 'add_credential_state.dart';

class AddCredentialCubit
    extends SettingsCommonItemCubit<AddCredentialState, Credential> {
  AddCredentialCubit() : super(AddCredentialUpdateState()) {
    loadStateDefaults();
  }

  @override
  void editData(int index, Credential item) {
    emit(state.copyWith(
      index: index,
      name: item.name,
      user: item.user,
      password: item.password,
    ));
  }

  @override
  void reset() {
    emit(AddCredentialUpdateState());
    loadStateDefaults();
  }

  @override
  void updateAutovalidateMode(AutovalidateMode? autovalidateMode) {
    emit(state.copyWith(autovalidateMode: autovalidateMode));
  }

  @override
  void updateName(String? name) {
    emit(state.copyWith(name: name));
  }

  void updateUser(String? user) {
    emit(state.copyWith(user: user));
  }

  void updatePassword(String? password) {
    emit(state.copyWith(password: password));
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(passwordVisibility: !state.passwordVisibility));
  }

  @override
  Future<void> loadStateDefaults() async {
    await state.loadDefaults();
    emit(state);
  }
}
