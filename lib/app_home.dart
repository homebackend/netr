/*
 * Copyright (c) 2024-26 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/common.dart';
import 'cubit/mainwindow/location_cubit.dart';
import 'cubit/mainwindow/navigation_cubit.dart';
import 'cubit/mainwindow/run_config_cubit.dart';
import 'cubit/viewer/archive_view_cubit.dart';
import 'cubit/viewer/live_view_cubit.dart';
import 'mixin/fields_common.dart';
import 'pages/archive_page.dart';
import 'constants.dart' as constants;
import 'cubit/settings/theme_cubit.dart';
import 'pages/live_page.dart';
import 'pages/location_page.dart';
import 'pages/settings/settings_page.dart';
import 'widgets/internet_status.dart';

class AppHome extends StatelessWidget with FieldsCommon {
  const AppHome({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavigationCubit()),
        BlocProvider(create: (_) => LocationCubit()..determinePosition()),
        BlocProvider(create: (_) => RunConfigCubit()),
        BlocProvider(create: (_) => LiveViewCubit()),
        BlocProvider(
          create: (_) => ArchiveViewCubit(BlocProvider.of<LiveViewCubit>(_)),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (_, themeState) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: themeState.data,
          home: BlocBuilder<NavigationCubit, NavigationState>(
            builder: (context, navState) => CubitCommon.cameraViewBlocBuilder(
              Scaffold(
                backgroundColor: Colors.black,
                body: LiveViewPage(),
              ),
              Scaffold(
                backgroundColor: Colors.black,
                body: ArchiveViewPage(),
              ),
              _buildNavigationPage(context, navState),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationPage(BuildContext context, NavigationState navState) {
    return Scaffold(
      appBar: AppBar(
        actions: [],
        title: Row(
          children: [
            Image.asset(
              constants.appEyeIcon,
              height: 40,
            ),
            SizedBox(
              width: 20,
            ),
            Text(constants.appName),
            Expanded(
              child: Container(),
            ),
            showDarkLightSwitch(context),
            InternetStatusWidget(),
          ],
        ),
      ),
      body: switch (navState.index) {
        0 => LiveViewPage(),
        1 => ArchiveViewPage(),
        2 => LocationPage(),
        3 => SettingsPage(),
        int() => Container(),
      },
      bottomNavigationBar: NavigationBar(
        selectedIndex: navState.index,
        onDestinationSelected: (index) {
          context.read<NavigationCubit>().setSelectedIndex(index);
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.live_tv_outlined),
            selectedIcon: Icon(Icons.live_tv),
            label: 'Live View',
          ),
          NavigationDestination(
            icon: Icon(Icons.archive_outlined),
            selectedIcon: Icon(Icons.archive),
            label: 'Archive View',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_city_outlined),
            selectedIcon: Icon(Icons.location_city),
            label: 'Location',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget showDarkLightSwitch(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return Tooltip(
          message: 'Dark/Bright Theme',
          child: Row(
            children: [
              Text('Dark Theme'),
              horizontalSpacing(),
              Switch(
                activeThumbColor: Colors.white,
                value: state.data.brightness == Brightness.dark,
                onChanged: (value) {
                  context.read<ThemeCubit>().toggleTheme(value);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
