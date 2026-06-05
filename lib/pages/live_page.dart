/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/viewer/live_view_cubit.dart';
import '../models/location.dart';
import 'player/player_base.dart';

class LiveViewPage extends StatefulWidget {
  const LiveViewPage({super.key});

  @override
  State<LiveViewPage> createState() => _LiveViewPageState();
}

class _LiveViewPageState extends State<LiveViewPage> {
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
    return BlocBuilder<LiveViewCubit, LiveViewState>(
      buildWhen: (previous, current) {
        if (current is LiveViewUpdatedState && !current.isFreshState) {
          return false;
        }

        return true;
      },
      builder: (context, state) {
        return state is LiveViewUpdatedState && state.fullScreen
            ? _videoViewer(state)
            : _buildCameraView(state);
      },
    );
  }

  Widget _buildCameraView(LiveViewState state) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Live View',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: (() {
        if (state is LiveViewInitialState) {
          return _noCameraView();
        } else if (state is LiveViewUpdatedState) {
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

  Widget _videoplayer(BoxConstraints constraints, LiveViewUpdatedState state) {
    return LayoutBuilder(builder: (context, playerConstraints) {
      return PlayerBase(
        constraints.maxWidth,
        constraints.maxHeight,
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

  Widget _videoViewer(LiveViewUpdatedState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        log('Viewer: ${constraints.maxWidth}x${constraints.maxHeight}');
        return BlocBuilder<LiveViewCubit, LiveViewState>(
            builder: (context, lvState) {
          return lvState is LiveViewUpdatedState && lvState.fullScreen
              ? _videoplayer(constraints, state)
              : Column(
                  children: [
                    _getCameraHeader(state.selectedCamera!.name),
                    SizedBox(height: 8),
                    Expanded(
                      child: _videoplayer(constraints, state),
                    )
                  ],
                );
        });
      },
    );
  }

  Widget _listCamerasByLocation(LiveViewUpdatedState state) {
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
      LiveViewUpdatedState state, Location location, int locationIndex) {
    return Scrollbar(
      thumbVisibility: true,
      controller: _horizontalControllers[locationIndex],
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        controller: _horizontalControllers[locationIndex],
        itemCount: state.locationCamera(location).length,
        separatorBuilder: (
          BuildContext context,
          int index,
        ) {
          return SizedBox(width: 16);
        },
        itemBuilder: (context, index) {
          return Card(
            child: InkWell(
              splashColor: Colors.blue.withAlpha(30),
              onTap: () {
                context.read<LiveViewCubit>().updateSelectedCameraAndLocation(
                    state.locationCamera(location)[index], location);
              },
              child: Column(
                children: [
                  SizedBox(
                    height: 240,
                    width: 320,
                    child: Container(
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
                  _getCameraHeader(state.locationCamera(location)[index].name),
                ],
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
        Icon(Icons.live_tv),
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
