/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'dart:convert';
import 'package:crypto/crypto.dart';

class StringHelper {
  static String getBase64Md5(String input) {
    final bytes = utf8.encode(input);
    final md5Hash = md5.convert(bytes);
    return base64Url.encode(md5Hash.bytes).replaceAll('=', '');
  }
}
