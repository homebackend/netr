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

import 'app_home.dart';
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

    return BlocProvider(
      create: (context) => AppInitializationCubit()..initialize(),
      child: BlocBuilder<AppInitializationCubit, AppInitializationStatus>(
        builder: (context, status) {
          switch (status.state) {
            case AppInitializationState.initialization:
              return SplashScreen();
            case AppInitializationState.updateApp:
              return UpdateApp(status.baseUrl ?? '');
            case AppInitializationState.initialized:
              return AppHome();
            case AppInitializationState.updateCheckFailed:
              showSnackBar(context, 'Unable to check for App update');
              return AppHome();
          }
        },
      ),
    );
  }
}
