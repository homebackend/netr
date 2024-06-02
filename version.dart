import 'dart:convert';
import 'dart:io';

void main() {
  File('pubspec.yaml')
      .openRead()
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .forEach((line) {
    final versionRegex = RegExp(r'^version:\s*([.0-9]+)\+([0-9]+)\s*$');
    if (versionRegex.hasMatch(line)) {
      final match = versionRegex.firstMatch(line);
      print('${match![1]}.${match[2]}');
    }
  });
}
