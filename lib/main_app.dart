/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netr/cubit/startup/app_initialization_cubit.dart';
import 'package:netr/tool.dart';
import 'package:window_manager/window_manager.dart';

import 'app_home.dart';
import 'cubit/settings/app_settings_cubit.dart';
import 'pages/update_app.dart';
import 'pages/splash.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    /*if (isMobilePlatform()) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }*/

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AppInitializationCubit()..initialize()),
        BlocProvider(create: (_) => AppSettingsCubit()..load()),
      ],
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
        child: BlocBuilder<AppInitializationCubit, AppInitializationStatus>(
          builder: (context, status) {
            switch (status.state) {
              case AppInitializationState.initialization:
                return SplashScreen();
              case AppInitializationState.updateApp:
                return UpdateApp(
                  status.baseUrl ?? '',
                  () =>
                      context.read<AppInitializationCubit>().emitInitialized(),
                );
              case AppInitializationState.initialized:
                return AppHome();
              case AppInitializationState.updateCheckFailed:
                showSnackBar(context, 'Unable to check for App update');
                return AppHome();
            }
          },
        ),
      ),
    );
  }
}
