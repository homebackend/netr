/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';

import 'string_helper.dart';

class ThumbnailManager {
  static bool thumbnailGenerationFailed = false;
  static const thumbCacheFolder = 'thumbs';

  static Future<String> getThumbnailFilePath(
    String locationName,
    String cameraName,
  ) async {
    final Directory cacheDir = await getApplicationCacheDirectory();

    final Directory thumbDir = Directory('${cacheDir.path}/$thumbCacheFolder');
    if (!await thumbDir.exists()) {
      await thumbDir.create(recursive: true);
    }

    final String fileName =
        StringHelper.getBase64Md5('$locationName/$cameraName');
    return '${thumbDir.path}/$fileName.jpg';
  }

  static Future<File> getThumbnailFile(
      String locationName, String cameraName) async {
    final String location =
        await getThumbnailFilePath(locationName, cameraName);

    return File(location);
  }

  static Future<void> generateCctvThumbnail(
    Player player,
    String locationName,
    String cameraName,
  ) async {
    try {
      if (thumbnailGenerationFailed) {
        log('Skipping thumbnail generation as it failed earlier');
        return;
      }

      await Future.delayed(const Duration(seconds: 3));
      if (player.state.width == null || player.state.width == 0) {
        log('Thumbnail generation skipped');
        return;
      }

      final Uint8List? bytes = await player.screenshot(format: 'image/jpeg');
      if (bytes == null) {
        thumbnailGenerationFailed = true;
        return;
      }

      final String thumbnailFileLocation =
          await ThumbnailManager.getThumbnailFilePath(
        locationName,
        cameraName,
      );
      log('New thumbnail created: $thumbnailFileLocation');
      final File thumbnailFile = File(thumbnailFileLocation);
      await thumbnailFile.writeAsBytes(bytes);
    } catch (e) {
      log("Thumbnail capture failed: $e");
    }
  }
}
