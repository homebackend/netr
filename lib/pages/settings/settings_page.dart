/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/settings/add_cameras_cubit.dart';
import '../../cubit/settings/add_credentials_cubit.dart';
import '../../cubit/settings/add_locations_cubit.dart';
import '../../cubit/settings/add_nvrs_cubit.dart';
import '../../cubit/settings/general_settings_cubit.dart';
import '../../cubit/settings/settings_navigation_cubit.dart';
import 'add_credential_settings.dart';
import 'add_device_settings.dart';
import 'add_location_settings.dart';
import 'general_settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    GeneralSettingsCubit generalSettingsCubit = GeneralSettingsCubit();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SettingsNavigationCubit([
            'General',
            'Camera',
            'NVR',
            'Location',
            'Credential',
          ]),
        ),
        BlocProvider(create: (_) => generalSettingsCubit),
        BlocProvider(
            create: (_) => AddCamerasCubit(generalSettingsCubit.stream)),
        BlocProvider(create: (_) => AddNvrsCubit(generalSettingsCubit.stream)),
        BlocProvider(
            create: (_) => AddLocationsCubit(generalSettingsCubit.stream)),
        BlocProvider(
            create: (_) => AddCredentialsCubit(generalSettingsCubit.stream))
      ],
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth > 600) {
          return SizedBox(
            child: Center(
              child: SizedBox(
                width: 600,
                child: Center(
                  child: buildScaffold(),
                ),
              ),
            ),
          );
        } else {
          return buildScaffold();
        }
      }),
    );
  }

  Widget buildScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<SettingsNavigationCubit, SettingsNavigationState>(
          builder: (context, state) {
            return Center(
              child: Text(
                '${state.name} Settings',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ),
      body: const SettingsPageView(),
    );
  }
}

class SettingsPageView extends StatefulWidget {
  const SettingsPageView({super.key});

  @override
  State<SettingsPageView> createState() => _SettingsPageViewState();
}

class _SettingsPageViewState extends State<SettingsPageView> {
  final PageController _controller = PageController();

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsNavigationCubit, SettingsNavigationState>(
      builder: (context, state) {
        return _buildSettings(state);
      },
    );
  }

  Widget _buildSettings(SettingsNavigationState state) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        PageView(
          onPageChanged: (index) {
            context.read<SettingsNavigationCubit>().setSelectedIndex(index);
          },
          controller: _controller,
          children: <Widget>[
            GeneralSettings(),
            AddDeviceSettings(DeviceType.camera),
            AddDeviceSettings(DeviceType.nvr),
            AddLocationSettings(),
            AddCredentialSettings(),
          ],
        ),
        DotsIndicator(
          dotsCount: 5,
          position: state.index.toDouble(),
          onTap: (position) {
            _controller.jumpToPage(position);
          },
        ),
      ],
    );
  }
}
