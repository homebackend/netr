/*
 * Copyright (c) 2024-26 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:netr/cubit/viewer/camera_view_state.dart';

import '../cubit/viewer/archive_camera_view_cubit.dart';
import '../cubit/viewer/archive_view_cubit.dart';
import '../helpers/date_time_picker.dart';
import '../models/camera.dart';
import '../models/location.dart';
import '../tool.dart';
import 'camera_view_page.dart';

class ArchiveViewPage extends CameraViewPage {
  const ArchiveViewPage({super.key}) : super('Archive View', Icons.history);

  @override
  State<ArchiveViewPage> createState() => _ArchiveViewPageState();
}

class _ArchiveViewPageState extends CameraViewPageState<ArchiveViewCubit,
    ArchiveCameraViewCubit, ArchiveViewPage> {
  DateTime? _archiveDateTime;

  bool _filterCamera(Camera camera) =>
      camera.archiveName.isNotEmpty && camera.archiveIndex >= 0;

  @override
  ArchiveCameraViewCubit createCubit(
          PlayerStream playerStream, CameraViewData data) =>
      ArchiveCameraViewCubit(playerStream, data);

  @override
  Iterable<Camera> getCameras(List<Camera> cameras) sync* {
    yield* cameras.where(_filterCamera);
  }

  @override
  int getCameraCount(List<Camera> cameras) =>
      cameras.where(_filterCamera).length;

  @override
  void cameraTapHandler(BuildContext bc, Location l, Camera c, bool fs) async {
    //LiveViewCubit lvc = bc.read<LiveViewCubit>();

    if (_archiveDateTime == null) {
      await _showDateTimePicker(bc);
      if (_archiveDateTime == null) return;
    }

/*
    lvc.updateSelectedCameraAndLocation(c, l, true,
        fullScreen: fs, archiveView: true);
        */
  }

  @override
  List<Widget>? getAppBarActions() {
    return [
      createIconButton(
        Icons.edit_calendar,
        () => _showDateTimePicker(context),
        'Pick Date Time',
      )
    ];
  }

  Future<void> _showDateTimePicker(BuildContext bc) async {
    final DateTime now = DateTime.now();
    _archiveDateTime = await DateTimePicker.pickDateTime(
          bc,
          now: _archiveDateTime ?? now,
          firstDate: now.subtract(Duration(days: 30)),
          lastDate: now,
          helpText: 'Select Date Time for Archive View',
        ) ??
        _archiveDateTime;
    log(_archiveDateTime.toString());
  }
}
