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
import 'cubit/settings/theme_cubit.dart';
import 'helpers/app_update_detailer.dart';
import 'pages/update_app.dart';
import 'pages/splash.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()..setInitialTheme()),
        BlocProvider(create: (_) => AppInitializationCubit()..initialize()),
        BlocProvider(create: (_) => AppSettingsCubit()..load()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (_, themeState) => MaterialApp(
          title: 'Netr',
          debugShowCheckedModeBanner: false,
          theme: themeState.data,
          home: ScaffoldMessenger(
            child: Builder(
              builder: (context) {
                return MultiBlocListener(
                  listeners: [
                    BlocListener<AppInitializationCubit,
                        AppInitializationStatus>(
                      listenWhen: (_, current) =>
                          current.state ==
                          AppInitializationState.showUpdateDetails,
                      listener: (context, status) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (dialogContext) => AppUpdateDialog(
                            downloadUrl: status.downloadUrl,
                            latestVersion: status.latestVersion,
                            changeLog: status.changeLog,
                          ),
                        );
                      },
                    ),
                    BlocListener<AppInitializationCubit,
                        AppInitializationStatus>(
                      listenWhen: (_, current) =>
                          current.state ==
                          AppInitializationState.updateCheckFailed,
                      listener: (context, status) {
                        showSnackBar(context, 'Unable to check for App update');
                      },
                    ),
                    BlocListener<AppSettingsCubit, AppSettingsState>(
                      listenWhen: (previous, _) =>
                          isDesktopPlatform() &&
                          previous is AppSettingsInitialState,
                      listener: (context, state) {
                        if (state is AppSettingsUpdateState) {
                          if (state.startAppMaximized) {
                            windowManager
                                .waitUntilReadyToShow()
                                .then((_) async {
                              await windowManager.maximize();
                            });
                          }
                        }
                      },
                    ),
                  ],
                  child: BlocBuilder<AppInitializationCubit,
                      AppInitializationStatus>(
                    builder: (context, status) {
                      switch (status.state) {
                        case AppInitializationState.initialization:
                          return const SplashScreen();
                        case AppInitializationState.showUpdateDetails:
                          return const AppHome();
                        case AppInitializationState.updateApp:
                          return UpdateApp(
                            status.downloadUrl,
                            status.latestVersion,
                            status.changeLog,
                            () => context
                                .read<AppInitializationCubit>()
                                .emitInitialized(),
                          );
                        case AppInitializationState.initialized:
                          return const AppHome();
                        case AppInitializationState.updateCheckFailed:
                          return const AppHome();
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
