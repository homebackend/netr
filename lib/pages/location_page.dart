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
import 'package:intl/intl.dart';

import '../cubit/mainwindow/location_cubit.dart';
import '../cubit/mainwindow/run_config_cubit.dart';
import '../mixin/fields_common.dart';
import '../models/camera.dart';

class LocationPage extends StatelessWidget with FieldsCommon {
  const LocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationCubit, LocationStatus>(
      listener: (context, state) {
        switch (state.state) {
          case LocationState.unknown:
            return log('unknown location');
          case LocationState.locationServiceDisabled:
            return log('Location service disabled');
          case LocationState.permissionsDenied:
            return log('Location: permission denied');
          case LocationState.permissionDeniedForever:
            return log('Location: permission denied forever');
          case LocationState.locatedWithCordinates:
          case LocationState.locatedFully:
            context.read<RunConfigCubit>().updateGps(
                  state.longitude,
                  state.latitude,
                );
            break;
        }
      },
      child: BlocBuilder<RunConfigCubit, RunConfigState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                state.locationSource == LocationSource.unset ||
                        context.read<RunConfigCubit>().locations.isEmpty
                    ? Text('Please add Location')
                    : dropDownMenu<String>(
                        'Current Location',
                        context
                            .read<RunConfigCubit>()
                            .locations
                            .map((l) => l.name)
                            .toList(),
                        state.location.isEmpty ? null : state.location,
                        (v) => v,
                        (value) {
                          context.read<RunConfigCubit>().updateLocation(
                                value!,
                                LocationSource.userInput,
                              );
                        },
                      ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      switch (state.locationSource) {
                        LocationSource.unset => 'No location set',
                        LocationSource.userInput => 'From user input',
                        LocationSource.gps => 'From GPS',
                        LocationSource.lastUsed => 'From last used value',
                      },
                    ),
                  ],
                ),
                verticalSpacing(),
                dropDownMenu(
                  'Stream Quality',
                  StreamQuality.values,
                  state.quality,
                  (q) => q.name,
                  (v) {
                    context.read<RunConfigCubit>().updateQuality(v!);
                  },
                  showEmptyOption: false,
                ),
                verticalSpacing(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Archive view date and time'),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    border: Border.all(width: 1.0),
                  ),
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        'Current Selection: ${DateFormat("yyyy-MM-dd – kk:mm").format(state.archiveDate)}',
                      ),
                      verticalSpacing(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              var updateArchiveDate = context
                                  .read<RunConfigCubit>()
                                  .updateArchiveDate;
                              final selectedDate = await showDatePicker(
                                context: context,
                                initialEntryMode: DatePickerEntryMode.calendar,
                                initialDate: state.archiveDate,
                                firstDate: state.archiveFirstDate,
                                lastDate: state.archiveLastDate,
                              );
                              updateArchiveDate(selectedDate);
                            },
                            child: Row(
                              children: [
                                Icon(Icons.date_range),
                                horizontalSpacing(),
                                Text('Pick a date'),
                              ],
                            ),
                          ),
                          horizontalSpacing(),
                          ElevatedButton(
                            onPressed: () async {
                              var updateArchiveTime = context
                                  .read<RunConfigCubit>()
                                  .updateArchiveTime;
                              final TimeOfDay? selectedTime =
                                  await showTimePicker(
                                context: context,
                                initialEntryMode: TimePickerEntryMode.dial,
                                initialTime:
                                    TimeOfDay.fromDateTime(state.archiveDate),
                              );

                              updateArchiveTime(selectedTime);
                            },
                            child: Row(
                              children: [
                                Icon(Icons.timelapse),
                                horizontalSpacing(),
                                Text('Pick a time'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
