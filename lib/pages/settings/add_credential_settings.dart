/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/settings/add_credential_cubit.dart';
import '../../cubit/settings/add_credentials_cubit.dart';
import '../../mixin/common_form_validator.dart';
import '../../mixin/fields_common.dart';
import '../../mixin/settings_common.dart';
import '../../models/credential.dart';

class AddCredentialSettings extends StatefulWidget
    with CommonFormValidator, FieldsCommon, SettingsCommon {
  const AddCredentialSettings({super.key});

  @override
  State<AddCredentialSettings> createState() => _AddCredentialSettingsState();
}

class _AddCredentialSettingsState extends State<AddCredentialSettings> {
  final _formKey = GlobalKey<FormState>();
  final _credential = Credential('');
  final _nameController = TextEditingController();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder<AddCredentialsCubit, AddCredentialCubit,
        AddCredentialState, Credential>(
      'Credential',
      context,
      _formKey,
      _credential,
      AddCredentialCubit(),
      _form,
      _getSubTitle,
    );
  }

  Widget _form(
    GlobalKey<FormState> formKey,
    BuildContext context,
  ) {
    return BlocListener<AddCredentialCubit, AddCredentialState>(
      listenWhen: (previous, current) => previous.index != current.index,
      listener: (context, state) {
        _nameController.text = state.name;
        _userController.text = state.user;
        _passwordController.text = state.password;
      },
      child: BlocBuilder<AddCredentialCubit, AddCredentialState>(
        builder: (context, state) {
          return Form(
            key: formKey,
            autovalidateMode: state.autovalidateMode,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  validator: (value) =>
                      widget.validateName<AddCredentialsCubit, Credential>(
                          value, context, state.index >= 0),
                  onChanged: context.read<AddCredentialCubit>().updateName,
                  onSaved: (value) {
                    _credential.name = value!;
                  },
                  decoration: widget.textFieldDecoration(
                    'Credential Name',
                    'Unique name of credential',
                    Icons.title,
                  ),
                ),
                widget.verticalSpacing(),
                TextFormField(
                  controller: _userController,
                  validator: widget.validateUser,
                  onChanged: context.read<AddCredentialCubit>().updateUser,
                  onSaved: (value) {
                    _credential.user = value!;
                  },
                  decoration: widget.textFieldDecoration(
                    'User Name',
                    'User name',
                    Icons.person,
                  ),
                ),
                widget.verticalSpacing(),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !state.passwordVisibility,
                  validator: widget.validatePassword,
                  onChanged: context.read<AddCredentialCubit>().updatePassword,
                  onSaved: (value) {
                    _credential.password = value!;
                  },
                  decoration: widget.passwordFieldDecoration(
                    'Password',
                    'Password',
                    Icons.lock,
                    !state.passwordVisibility,
                    () {
                      context
                          .read<AddCredentialCubit>()
                          .togglePasswordVisibility();
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _getSubTitle(Credential credential) {
    return [
      Text('${credential.user}: ${"*" * credential.password.length}'),
    ];
  }
}
