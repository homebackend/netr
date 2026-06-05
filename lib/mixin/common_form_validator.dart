/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netr/models/settings_item.dart';

import '../cubit/settings/settings_common_cubit.dart';

mixin CommonFormValidator {
  static final _regexIpAddress = RegExp(
      r'^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$');
  static final _regexHostName = RegExp(
      r'^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$');
  static final int _minimumPort = 1;
  static final int _maximumPort = 65535;
  static final _allowedCharsInName = RegExp(r'^[, a-zA-Z0-9]+$');
  static final int _maxNameLength = 30;

  String?
      validateName<Cs extends SettingsCommonCubit<T>, T extends SettingsItem>(
          String? value, BuildContext context, bool editMode) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length > _maxNameLength) {
      return 'Name length should not exceed $_maxNameLength';
    }

    if (!_allowedCharsInName.hasMatch(value)) {
      return 'Name should only have alpha numeric, space and comma characters';
    }

    if (!editMode &&
        context
            .read<Cs>()
            .items
            .map((item) => item.name)
            .toList()
            .contains(value)) {
      return 'Name is required to be unique';
    }

    return null;
  }

  String? validateUser(String? value) {
    if (value == null || value.isEmpty) {
      return 'User is required';
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    return null;
  }

  String? validateHost(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (!_regexHostName.hasMatch(value) && !_regexIpAddress.hasMatch(value)) {
      return 'Please provide valid host name or IP address';
    }

    return null;
  }

  String? validatePort(
    String? value, {
    bool mandatory = false,
  }) {
    if (value == null || value.isEmpty) {
      if (mandatory) {
        return 'Value for port is mandatory';
      } else {
        return null;
      }
    }

    try {
      var port = int.parse(value);

      if (port < _minimumPort || port > _maximumPort) {
        return 'Port must lie between $_minimumPort and $_maximumPort';
      }
    } catch (e) {
      return 'Port must be a number';
    }

    return null;
  }
}
