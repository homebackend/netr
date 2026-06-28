/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_common/main_app.dart';
import 'package:flutter_common/tool.dart';
import 'package:window_manager/window_manager.dart';

import 'app_home.dart';
import 'constants.dart';
import 'cubit/settings/app_settings_cubit.dart';
import 'desktop_home_screen.dart';

class MainAppWrapper {
  static void runAppWrapper() {
    return runApp(
      BlocProvider(
        create: (_) => AppSettingsCubit()..load(),
        child: BlocListener<AppSettingsCubit, AppSettingsState>(
          listenWhen: (previous, _) =>
              isDesktopPlatform() && previous is AppSettingsInitialState,
          listener: (context, state) {
            if (state is AppSettingsUpdateState) {
              if (state.startAppMaximized) {
                windowManager.waitUntilReadyToShow().then((_) async {
                  await windowManager.maximize();
                });
              }
            }
          },
          child: MaterialApp(
            home: MainApp(
              githubOrganization,
              githubRepo,
              baseAssetName,
              appName,
              appIcon,
              () => isDesktopPlatform() ? DesktopHomeScreen() : AppHome(),
            ),
          ),
        ),
      ),
    );
  }
}
