/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

mixin AddLocationFormValidator {
  static final _regexUserName = RegExp(r'^[A-Za-z][A-Za-z0-9_]*$');

  String? _validateOptionalDouble(
      String? value, String name, double minValue, double maxValue) {
    if (value == null || value.isEmpty) {
      return null;
    }

    try {
      var longitude = double.parse(value);

      if (longitude < minValue || longitude > maxValue) {
        return '$name must lie between $minValue and $maxValue';
      }
    } catch (e) {
      return '$name must be a number';
    }

    return null;
  }

  String? validateLongitude(String? value) {
    return _validateOptionalDouble(value, 'Longitude', -180.0, 180.0);
  }

  String? validateLatitude(String? value) {
    return _validateOptionalDouble(value, 'Latitude', -90.0, 90.0);
  }

  String? validateSshUser(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (!_regexUserName.hasMatch(value)) {
      return 'Please add a valid user name';
    }

    return null;
  }

  String? validateSshPrivateKey(String? value) {
    return null;
  }
}
