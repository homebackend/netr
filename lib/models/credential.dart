/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import '../mixin/encrypter.dart';
import 'settings_item.dart';

class Credential extends SettingsItem with EncryptMixin {
  static final String _keyName = 'name';
  static final String _keyUser = 'user';
  static final String _keyPassword = 'password';

  String user;
  String password;

  Credential(
    super.name, {
    this.user = '',
    this.password = '',
  });

  @override
  Credential copySelf() {
    return Credential(name, user: user, password: password);
  }

  factory Credential.fromJson(Map<String, dynamic> map) {
    var cred = Credential(
      map[_keyName] ?? '',
      user: map[_keyUser] ?? '',
      password: map[_keyPassword] ?? '',
    );

    if (cred.password.isNotEmpty) {
      cred.password = EncryptMixin.decrypt(cred.password);
    }

    return cred;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      _keyName: name,
      _keyUser: user,
      _keyPassword: EncryptMixin.encrypt(password),
    };
  }
}
