/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';

import '../../mixin/preferences.dart';
import '../../tool.dart';

part 'general_settings_state.dart';

class GeneralSettingsCubit extends Cubit<GeneralSettingsState>
    with Preferences {
  static final String _exportFileName = 'netr.json';

  GeneralSettingsCubit() : super(GeneralSettingsUpdateState());

  void exportFile() async {
    try {
      emit(state.copyWith(exportInProgress: true));
      String prefsJson = await getAllPreferencesAsString();

      List<int> list = utf8.encode(prefsJson);
      Uint8List bytes = Uint8List.fromList(list);
      String? outputFile = await FilePicker.saveFile(
        dialogTitle: 'Please select an output file:',
        lockParentWindow: true,
        fileName: _exportFileName,
        initialDirectory: await getDefaultDirectory(),
        bytes: bytes,
      );

      if (outputFile == null) {
        emit(state.copyWith(exportInProgress: false));
        return;
      }

      if (isDesktopPlatform()) {
        var file = File(outputFile);
        await file.writeAsString(prefsJson);
      }

      await setDefaultDirectory(dirname(outputFile));

      log('Json saved to file $outputFile');
      emit(state.copyWith(exportInProgress: false, exportFailed: false));
    } catch (e) {
      log('Error saving file: $e');
      emit(state.copyWith(exportInProgress: false, exportFailed: true));
    }
  }

  void shareFile() async {
    emit(state.copyWith(shareInProgress: true));
    try {
      String prefsJson = await getAllPreferencesAsString();

      final params = ShareParams(
        files: [
          XFile.fromData(
            utf8.encode(prefsJson),
            mimeType: 'text/json',
          ),
        ],
        fileNameOverrides: [_exportFileName],
      );
      await SharePlus.instance.share(params);

      emit(state.copyWith(shareInProgress: false, shareFailed: false));
    } catch (e) {
      log('Error sharing file: $e');
      emit(state.copyWith(shareInProgress: false, shareFailed: true));
    }
  }

  void importFile() async {
    emit(state.copyWith(importInProgress: true));
    try {
      FilePickerResult? inputFile = await FilePicker.pickFiles(
        dialogTitle: 'Please select an input file to load preferences',
        lockParentWindow: true,
        initialDirectory: await getDefaultDirectory(),
        type: FileType.any,
      );

      if (inputFile == null) {
        emit(state.copyWith(importInProgress: false));
        return;
      }

      File file = File(inputFile.files.single.path!);
      String contents = await file.readAsString();
      await setAllPreferencesFromString(contents);
      await setDefaultDirectory(dirname(inputFile.files.single.path!));

      emit(state.copyWith(
        importInProgress: false,
        importFailed: false,
        reloadPreferences: true,
      ));
      emit(GeneralSettingsUpdateState());
    } catch (e) {
      log('Error importing file: $e');
      emit(state.copyWith(importInProgress: false, importFailed: true));
    }
  }
}
