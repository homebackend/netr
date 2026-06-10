/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/settings/app_settings_cubit.dart';
import '../../cubit/settings/general_settings_cubit.dart';
import '../../mixin/fields_common.dart';
import '../../mixin/settings_common.dart';
import '../../tool.dart';

class GeneralSettings extends StatefulWidget with FieldsCommon, SettingsCommon {
  const GeneralSettings({super.key});

  @override
  State<GeneralSettings> createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends State<GeneralSettings> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppSettingsCubit, AppSettingsState>(
        builder: (appContext, appState) {
      return BlocBuilder<GeneralSettingsCubit, GeneralSettingsState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (isDesktopPlatform())
                  Row(
                    children: [
                      Switch(
                        value: appState.startAppMaximized,
                        onChanged: (value) {
                          context
                              .read<AppSettingsCubit>()
                              .setStartApplicationAsMaximized(value);
                        },
                      ),
                      widget.horizontalSpacing(),
                      const Text('Start Application as Maximized'),
                    ],
                  ),
                Row(
                  children: [
                    Switch(
                      value: appState.playVideoFullscreen,
                      onChanged: (value) {
                        context
                            .read<AppSettingsCubit>()
                            .setPlayVideoFullScreen(value);
                      },
                    ),
                    widget.horizontalSpacing(),
                    const Text('Play Video in Full Screen Mode'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    state.exportInProgress
                        ? CircularProgressIndicator()
                        : ElevatedButton.icon(
                            label: Text('Export'),
                            icon: Icon(Icons.save),
                            onPressed: () {
                              context.read<GeneralSettingsCubit>().exportFile();
                            },
                          ),
                    SizedBox(width: 16),
                    state.shareInProgress
                        ? CircularProgressIndicator()
                        : ElevatedButton.icon(
                            label: Text('Share'),
                            icon: Icon(Icons.share),
                            onPressed: () {
                              context.read<GeneralSettingsCubit>().shareFile();
                            },
                          ),
                    SizedBox(width: 16),
                    state.importInProgress
                        ? CircularProgressIndicator()
                        : ElevatedButton.icon(
                            label: Text('Import'),
                            icon: Icon(Icons.file_open),
                            onPressed: () {
                              context.read<GeneralSettingsCubit>().importFile();
                            },
                          ),
                  ],
                )
              ],
            ),
          );
        },
      );
    });
  }
}
