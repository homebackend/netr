/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../constants.dart' as constants;
import '../../models/app_info.dart';
import '../../tool.dart';

part 'app_initialization_state.dart';

class AppInitializationCubit extends Cubit<AppInitializationStatus> {
  List<String> baseUrls = constants.upgradeBaseUrls;

  AppInitializationCubit()
      : super(AppInitializationStatus(AppInitializationState.initialization));

  Future<void> initialize() async {
    emit(AppInitializationStatus(AppInitializationState.initialization));
    if (isMobilePlatform()) {
      await checkUpdateRequired();
    } else {
      emitInitialized();
    }
  }

  void emitInitialized() {
    emit(AppInitializationStatus(AppInitializationState.initialized));
  }

  Future<void> checkUpdateRequired() async {
    try {
      final currentInfo = await PackageInfo.fromPlatform();
      log('Current App version: ${currentInfo.buildNumber}');
      for (String baseUrl in baseUrls) {
        String contents = await http.read(
          Uri.parse('$baseUrl/info.json'),
        );

        final AppInfo appInfo = AppInfo.fromJson(jsonDecode(contents));
        log('Available App version: ${appInfo.version}');

        if (int.parse(currentInfo.buildNumber) < int.parse(appInfo.version)) {
          emit(AppInitializationStatus(AppInitializationState.updateApp,
              baseUrl: baseUrl));
        } else {
          emitInitialized();
        }

        return;
      }
    } catch (e) {
      emit(AppInitializationStatus(AppInitializationState.updateCheckFailed));
    }
  }
}
