/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:encrypt/encrypt.dart';

IV encryptionIV = IV.fromLength(16);
final String keyEncryptionInitialisationVector = 'encryptionIV';

mixin EncryptMixin {
  static final String _secureKey = '3fWrhtt4zYQlvPmJSGRgow==';
  static final _key = Key.fromBase64(_secureKey);
  static final _encrypter = Encrypter(AES(_key));

  static String? encrypt(String? plainText) {
    if (plainText == null) {
      return plainText;
    }

    return _encrypter.encrypt(plainText, iv: encryptionIV).base64;
  }

  static String decrypt(String encryptedText) {
    return _encrypter.decrypt(Encrypted.fromBase64(encryptedText),
        iv: encryptionIV);
  }
}
