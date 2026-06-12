/*
 * Copyright (c) 2024-26 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:media_kit/media_kit.dart';

import '../cubit/viewer/archive_camera_view_cubit.dart';
import '../cubit/viewer/archive_view_cubit.dart';
import '../cubit/viewer/camera_view_state.dart';
import '../cubit/viewer/view_state.dart';
import '../helpers/date_time_picker.dart';
import '../helpers/string_helper.dart';
import '../mixin/preferences.dart';
import '../models/camera.dart';
import '../models/location.dart';
import '../tool.dart';
import 'camera_view_page.dart';
import 'player/archive_player.dart';

class ArchiveViewPage extends CameraViewPage {
  const ArchiveViewPage({super.key}) : super('Archive View', Icons.history);

  @override
  State<ArchiveViewPage> createState() => _ArchiveViewPageState();
}

class _ArchiveViewPageState extends CameraViewPageState<ArchiveViewPage>
    with Preferences {
  DateTime? _archiveDateTime;

  @override
  BlocBuilder blocBuilder({
    required Widget Function(BuildContext, ViewState) builder,
    bool Function(ViewState previous, ViewState current)? buildWhen,
  }) =>
      BlocBuilder<ArchiveViewCubit, ViewState>(
        builder: builder,
        buildWhen: buildWhen,
      );

  @override
  void initState() {
    _load();
    super.initState();
  }

  Future<void> _load() async {
    String? archiveDateTime = await loadString(Preferences.keyArchiveDateTime);

    if (archiveDateTime != null) {
      setState(() {
        _archiveDateTime = DateTime.tryParse(archiveDateTime);
      });
    }
  }

  bool _filterCamera(Camera camera) =>
      camera.archiveName.isNotEmpty && camera.archiveIndex >= 0;

  /* This function creates a cubit that will be used to switch
   * between the availble CCTVs. Note it sends the actual NVR 
   * values corresponding to the CCTV as NVR stores the archives.
   */
  @override
  ArchiveCameraViewCubit createCubit(PlayerStream playerStream,
      ViewUpdatedState state, double maxWidth, double maxHeight) {
    return ArchiveCameraViewCubit(
      playerStream,
      CameraViewData(
        state.selectedLocation!,
        state.cameraNvr(state.selectedCamera!)!,
        state.cameraNvrCredential(state.selectedCamera!)!,
        quality: StreamQuality.high,
        cameraIndex: state.selectedCamera!.archiveIndex,
        width: maxWidth,
        height: maxHeight,
      ),
    );
  }

  @override
  void updateCubit(
          ViewUpdatedState state,
          Future<void> Function(ViewUpdatedState vuState,
                  {DateTime? startDateTime})
              updator) =>
      updator(state, startDateTime: _archiveDateTime);

  @override
  Iterable<Camera> getCameras(List<Camera> cameras) sync* {
    yield* cameras.where(_filterCamera);
  }

  @override
  int getCameraCount(List<Camera> cameras) =>
      cameras.where(_filterCamera).length;

  @override
  void cameraTapHandler(BuildContext bc, Location l, Camera c, bool fs) async {
    ArchiveViewCubit cubit = bc.read<ArchiveViewCubit>();
    if (_archiveDateTime == null) {
      await _showDateTimePicker(bc);
      if (_archiveDateTime == null) return;
    }

    cubit.updateSelectedCameraAndLocation(
      c,
      l,
      true,
      fullScreen: fs,
      archiveView: true,
    );
  }

  @override
  List<Widget> getAppBarActions() {
    return [
      createIconButton(
        Icons.edit_calendar,
        () => _showDateTimePicker(context),
        _archiveDateTime == null
            ? 'Pick Date Time'
            : 'Picked Date Time: ${StringHelper.getOrdinalSuffix(_archiveDateTime!.day)}${DateFormat(' MMMM hh:mm a').format(_archiveDateTime!)}',
      )
    ];
  }

  Future<void> _showDateTimePicker(BuildContext bc) async {
    final DateTime now = DateTime.now();
    DateTime? picked = await DateTimePicker.pickDateTime(
          bc,
          now: _archiveDateTime ?? now,
          firstDate: now.subtract(Duration(days: 30)),
          lastDate: now,
          helpText: 'Select Date Time for Archive View',
        ) ??
        _archiveDateTime;

    if (picked != null) {
      setState(() {
        _archiveDateTime = picked;
      });
      saveString(Preferences.keyArchiveDateTime, _archiveDateTime.toString());
      log(_archiveDateTime.toString());
    }
  }

  @override
  ArchivePlayer getPlayer(
    double maxWidth,
    double maxHeight,
    ViewUpdatedState state,
    String playerTitle,
    String dialogText,
  ) =>
      ArchivePlayer(
        maxWidth,
        maxHeight,
        state.cameraNvr(state.selectedCamera!)!,
        state.selectedLocation!,
        state.cameraNvrCredential(state.selectedCamera!)!,
        state.selectedCamera!.archiveIndex,
        _archiveDateTime!,
        state.cameras
            .map(
              (camera) => (
                state.cameraNvr(camera)!,
                state.cameraLocation(camera)!,
                state.cameraNvrCredential(camera)!,
              ),
            )
            .toList(),
        playerTitle,
        dialogText,
      );
}
