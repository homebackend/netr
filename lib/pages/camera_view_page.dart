/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart';
import 'package:netr/cubit/viewer/camera_view_cubit.dart';

import '../cubit/common.dart';
import '../cubit/settings/app_settings_cubit.dart';
import '../cubit/viewer/camera_view_state.dart';
import '../cubit/viewer/view_cubit.dart';
import '../cubit/viewer/view_state.dart';
import '../models/camera.dart';
import '../models/location.dart';
import '../widgets/thumbnail.dart';
import 'player/player_base.dart';

abstract class CameraViewPage extends StatefulWidget {
  final String viewName;
  final IconData iconData;
  const CameraViewPage(this.viewName, this.iconData, {super.key});
}

abstract class CameraViewPageState<C extends ViewCubit,
    CC extends CameraViewCubit, T extends CameraViewPage> extends State<T> {
  final ScrollController _verticalController = ScrollController();
  final List<ScrollController> _horizontalControllers = [];

  @override
  void dispose() {
    _verticalController.dispose();
    for (var c in _horizontalControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<C, ViewState>(
      buildWhen: CubitCommon.viewBuildWhen,
      builder: (context, state) {
        return state is ViewUpdatedState && state.fullScreen
            ? _videoViewer(state)
            : _buildCameraView(state);
      },
    );
  }

  @protected
  int getCameraCount(List<Camera> cameras);

  @protected
  Iterable<Camera> getCameras(List<Camera> cameras);

  @protected
  void cameraTapHandler(BuildContext bc, Location l, Camera c, bool fs);

  @protected
  List<Widget>? getAppBarActions();

  @protected
  CameraViewCubit createCubit(PlayerStream playerStream, CameraViewData data);

  Widget _buildCameraView(ViewState state) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.viewName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: getAppBarActions(),
      ),
      body: (() {
        if (state is ViewInitialState) {
          return _noCameraView();
        } else if (state is ViewUpdatedState) {
          if (state.selectedCamera != null && state.selectedLocation != null) {
            return _videoViewer(state);
          } else {
            return _listCamerasByLocation(state);
          }
        }

        return _noCameraView();
      }()),
    );
  }

  Widget _noCameraView() {
    return Center(
      child: Text('Please add cameras'),
    );
  }

  Widget _videoplayer(ViewUpdatedState state) {
    return LayoutBuilder(builder: (context, playerConstraints) {
      return PlayerBase<C, CC>(
        (PlayerStream p) => createCubit(
          p,
          CameraViewData(
            state.selectedLocation!,
            state.selectedCamera!,
            state.cameraCredential(state.selectedCamera!)!,
            quality: StreamQuality.high,
            width: playerConstraints.maxWidth.toInt(),
            height: playerConstraints.maxHeight.toInt(),
          ),
        ),
        playerConstraints.maxWidth,
        playerConstraints.maxHeight,
        state.selectedCamera!,
        state.selectedLocation!,
        state.cameraCredential(state.selectedCamera!)!,
        state.cameras
            .map(
              (camera) => (
                camera,
                state.cameraLocation(camera)!,
                state.cameraCredential(camera)!,
              ),
            )
            .toList(),
        'Live Camera Viewer',
        'Select a Camera',
      );
    });
  }

  Widget _videoViewer(ViewUpdatedState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        log('Viewer: ${constraints.maxWidth}x${constraints.maxHeight}');
        return BlocBuilder<C, ViewState>(builder: (context, vState) {
          return CubitCommon.isFullScreen(vState)
              ? SizedBox.expand(child: _videoplayer(state))
              : Column(
                  children: [
                    _getCameraHeader(state.selectedCamera!.name),
                    SizedBox(height: 8),
                    Expanded(
                      child: _videoplayer(state),
                    )
                  ],
                );
        });
      },
    );
  }

  Widget _listCamerasByLocation(ViewUpdatedState state) {
    _horizontalControllers.clear();
    List<Location> locations = state.locations
        .where((location) => state.locationCamera(location).isNotEmpty)
        .toList();
    for (int i = 0; i < locations.length; i++) {
      _horizontalControllers.add(ScrollController());
    }

    return Scrollbar(
      thumbVisibility: true,
      controller: _verticalController,
      child: ListView.separated(
        scrollDirection: Axis.vertical,
        controller: _verticalController,
        itemCount: locations.length,
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(height: 8);
        },
        itemBuilder: (context, index) {
          return Column(
            children: [
              SizedBox(
                height: 300,
                child: _getLocationRow(state, locations[index], index),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_city),
                  SizedBox(width: 8),
                  Text(
                    locations[index].name,
                    style: TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _getLocationRow(
    ViewUpdatedState state,
    Location location,
    int locationIndex,
  ) {
    return Scrollbar(
      thumbVisibility: true,
      controller: _horizontalControllers[locationIndex],
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        controller: _horizontalControllers[locationIndex],
        itemCount: getCameraCount(state.locationCamera(location)),
        separatorBuilder: (
          BuildContext context,
          int index,
        ) {
          return SizedBox(width: 16);
        },
        itemBuilder: (context, index) {
          Camera camera = state.locationCamera(location)[index];

          return BlocBuilder<AppSettingsCubit, AppSettingsState>(
            builder: (context, appState) => Card(
              child: InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onTap: () => cameraTapHandler(
                  context,
                  location,
                  camera,
                  appState.playVideoFullscreen,
                ),
                child: Column(
                  children: [
                    Container(
                      height: 180,
                      width: 320,
                      color: Colors.black12,
                      child: ThumbnailWidget(location.name, camera.name),
                    ),
                    SizedBox(height: 8),
                    _getCameraHeader(camera.name),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _getCameraHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(widget.iconData),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
