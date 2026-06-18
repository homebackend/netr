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

import '../cubit/settings/app_settings_cubit.dart';
import '../cubit/viewer/archive_view_cubit.dart';
import '../cubit/viewer/view_state.dart';
import '../helpers/date_time_picker.dart';
import '../helpers/string_helper.dart';
import '../mixin/preferences.dart';
import '../models/camera.dart';
import '../models/location.dart';
import '../tool.dart';
import 'camera_view_page.dart';
import 'player/archive_players.dart';
import 'player/archive_player_base.dart';

class ArchiveViewPage extends CameraViewPage {
  const ArchiveViewPage({super.key})
      : super('Archive View', Icons.video_library);

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

  @override
  bool filterCamera(Camera camera) {
    if (camera.archiveName.isEmpty || camera.archiveIndex < 0) {
      return false;
    }

    if (hasSSHAccess(camera)) {
      return true;
    }

    String expectedName = camera.locationName;
    AppSettingsState s = context.read<AppSettingsCubit>().state;
    if (s is AppSettingsUpdateState && s.selectedLocation != null) {
      expectedName = s.selectedLocation!;
    }

    ViewState vs = context.read<ArchiveViewCubit>().state;
    if (vs is ViewUpdatedState) {
      Camera? nvr = vs.cameraNvr(camera);
      if (nvr != null) {
        return nvr.ipLocationNames.any((l) => l == expectedName);
      }
    }

    return false;
  }

  @override
  bool hasSSHAccess(Camera camera) {
    ViewState s = context.read<ArchiveViewCubit>().state;
    if (s is ViewUpdatedState) {
      Camera? nvr = s.cameraNvr(camera);
      if (nvr != null) {
        return s.cameraIpLocations(nvr).any((l) => l.useSshForNonLocal);
      }
    }

    return false;
  }

  @override
  void updateCubit(
          ViewUpdatedState state,
          Future<void> Function(ViewUpdatedState vuState,
                  {DateTime? startDateTime})
              updator) =>
      updator(state, startDateTime: _archiveDateTime);

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
  List<Widget> getAppBarActions(BuildContext bc, AppSettingsState appSettings) {
    return [
      ...super.getAppBarActions(bc, appSettings),
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
  bool isPlayerReady() => _archiveDateTime != null;

  @override
  ArchivePlayerBase getPlayer(
    double maxWidth,
    double maxHeight,
    ViewUpdatedState state,
    String playerTitle,
    String dialogText,
  ) =>
      isAndroidPlatform()
          ? AndroidArchivePlayer(
              maxWidth,
              maxHeight,
              state,
              _archiveDateTime!,
              playerTitle,
              dialogText,
            )
          : DesktopArchivePlayer(
              maxWidth,
              maxHeight,
              state,
              _archiveDateTime!,
              playerTitle,
              dialogText,
            );

  @override
  List<String> getLocations() {
    ViewState s = context.read<ArchiveViewCubit>().state;
    return s is ViewUpdatedState
        ? s.locations.map((location) => location.name).toList()
        : [];
  }
}
