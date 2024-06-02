import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:netr/helpers/camera_helper.dart';
import 'package:netr/helpers/photo_camera_helper.dart';

class HistoricalPhotoCameraHelper extends PhotoCameraHelper {
  HistoricalPhotoCameraHelper(
      OnLoadHandler onLoadHandler, OnErrorHandler onErrorHandler)
      : super(onLoadHandler, onErrorHandler);

  Future<String?> getHistoricalImageUrl(
      DateTime dateTime, String camera, int index, String type) async {
    String formattedDate =
        DateFormat('yyyy-MM-dd/yyyy-MM-dd-HH:mm').format(dateTime);
    String sourcePath =
        '$location/$formattedDate-$type-${index + 1}-$camera.jpg';

    try {
      final String? link = await getDropboxUrl(sourcePath);
      log('$sourcePath => $link!');
      return link;
    } on Exception catch (e) {
      log('Error occurred: $e');
      return null;
    }
  }
}
