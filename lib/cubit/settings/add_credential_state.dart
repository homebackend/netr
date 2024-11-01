/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

part of 'add_credential_cubit.dart';

sealed class AddCredentialState extends SettingsCommonItemState {
  final String user;
  final String password;
  final bool passwordVisibility;

  AddCredentialState({
    super.autovalidateMode,
    super.index,
    super.name,
    this.user = '',
    this.password = '',
    this.passwordVisibility = false,
  }) : super('credential');

  AddCredentialState copyWith({
    AutovalidateMode? autovalidateMode,
    int? index,
    String? name,
    String? user,
    String? password,
    bool? passwordVisibility,
  });
}

final class AddCredentialUpdateState extends AddCredentialState {
  AddCredentialUpdateState({
    super.autovalidateMode,
    super.index,
    super.name,
    super.user,
    super.password,
    super.passwordVisibility,
  });

  @override
  AddCredentialState copyWith({
    AutovalidateMode? autovalidateMode,
    int? index,
    String? name,
    String? user,
    String? password,
    bool? passwordVisibility,
  }) {
    return AddCredentialUpdateState(
      autovalidateMode: autovalidateMode ?? this.autovalidateMode,
      index: index ?? this.index,
      name: name ?? this.name,
      user: user ?? this.user,
      password: password ?? this.password,
      passwordVisibility: passwordVisibility ?? this.passwordVisibility,
    );
  }
}
