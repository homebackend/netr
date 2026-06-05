/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netr/cubit/mainwindow/navigation_cubit.dart';
import 'package:netr/cubit/mainwindow/run_config_cubit.dart';
import 'package:netr/cubit/viewer/live_view_cubit.dart';

import 'cubit/common.dart';
import 'cubit/mainwindow/location_cubit.dart';
import 'pages/archive_page.dart';
import 'constants.dart' as constants;
import 'cubit/settings/theme_cubit.dart';
import 'pages/live_page.dart';
import 'pages/location_page.dart';
import 'pages/settings/settings_page.dart';
import 'widgets/internet_status.dart';

class AppHome extends StatelessWidget {
  const AppHome({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()..setInitialTheme()),
        BlocProvider(create: (_) => NavigationCubit()),
        BlocProvider(create: (_) => LocationCubit()..determinePosition()),
        BlocProvider(create: (_) => RunConfigCubit()),
        BlocProvider(create: (_) => LiveViewCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (_, themeState) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeState.data,
            home: BlocBuilder<NavigationCubit, NavigationState>(
              builder: (context, navState) {
                return BlocBuilder<LiveViewCubit, LiveViewState>(
                  buildWhen: CubitCommon.liveViewBuildWhen,
                  builder: (context, lvState) {
                    if (lvState is LiveViewUpdatedState && lvState.fullScreen) {
                      return Scaffold(
                        backgroundColor: Colors.black,
                        body: LiveViewPage(),
                      );
                    } else {
                      return _buildNavigationPage(context, navState);
                    }
                  },
                );
              },
            ),
          );
        },
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
        return Switch(
          activeThumbColor: Colors.white,
          value: state.data.brightness == Brightness.dark,
          onChanged: (value) {
            context.read<ThemeCubit>().toggleTheme(value);
          },
        );
      },
    );
  }
}

/*
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _showHome = true;
  bool _restoreHome = false;
  ViewerMode? _viewerMode;
  VideoStreamMode? _videoStreamMode;
  VideoStreamType? _videoStreamType;
  String? _videoQuality;
  String? _location;
  DateTime? _archiveDateTime;
  PhotoCameraHelper? _photoCameraHelper;
  HistoricalPhotoCameraHelper? _historicalPhotoCameraHelper;
  StreamCameraHelper? _streamCameraHelper;
  String? _selectedVideoCamera;
  int? _selectedCameraIndex;

  @override
  Widget build(BuildContext context) {
    if (!_showHome) {
      void callback(bool showInstruction) {
        setState(() {
          _showHome = true;
          _restoreHome = true;
        });
      }

      BaseViewer? viewer;

      switch (_viewerMode) {
        case ViewerMode.picture:
          viewer = PictureViewerHome(_photoCameraHelper!, _selectedVideoCamera,
              _videoQuality, '', callback);
          break;
        case ViewerMode.pictureArchive:
          var lastDateTime = DateFormat('yyyy-MM-dd-HH:mm')
              .parse(_historicalPhotoCameraHelper!.getLatestImageTime());
          viewer = PictureHistoricalViewerHome(
              _historicalPhotoCameraHelper!,
              lastDateTime,
              _selectedCameraIndex!,
              _selectedVideoCamera,
              _videoQuality,
              _location,
              callback);
          break;
        case ViewerMode.inAppVideo:
          if (_videoStreamType == VideoStreamType.live) {
            if (_videoStreamMode == VideoStreamMode.streamDirect) {
              viewer = DirectVideoViewerHome(_streamCameraHelper!,
                  _selectedVideoCamera, _videoQuality, _location, callback);
            } else {
              viewer = SshVideoViewerHome(_streamCameraHelper!,
                  _selectedVideoCamera, _videoQuality, _location, callback);
            }
          } else {
            if (_videoStreamMode == VideoStreamMode.streamDirect) {
              viewer = DirectArchiveVideoViewerHome(_streamCameraHelper!,
                  _selectedVideoCamera, _location, _archiveDateTime!, callback);
            } else {
              viewer = SshArchiveVideoViewerHome(_streamCameraHelper!,
                  _selectedVideoCamera, _location, _archiveDateTime!, callback);
            }
          }
          break;
        case ViewerMode.remoteVlc:
          if (_videoStreamMode == VideoStreamMode.streamDirect) {
            if (_videoStreamType == VideoStreamType.live) {
              viewer = VlcDirectVideoViewerHome(_streamCameraHelper!,
                  _selectedVideoCamera, _videoQuality, _location, callback);
            } else {
              viewer = VlcDirectArchiveVideoViewerHome(_streamCameraHelper!,
                  _selectedVideoCamera, _location, _archiveDateTime, callback);
            }
          }
          break;
        case ViewerMode.none:
        default:
          viewer = null;
          break;
      }

      if (viewer != null) {
        return viewer;
      }
    }

    void submitHandler(
        ViewerMode viewerMode,
        VideoStreamMode? videoStreamMode,
        VideoStreamType? videoStreamType,
        String videoQuality,
        String? location,
        DateTime? archiveDateTime,
        String selectedVideoCamera,
        int selectedCameraIndex,
        PhotoCameraHelper? photoCameraHelper,
        HistoricalPhotoCameraHelper? historicalPhotoCameraHelper,
        StreamCameraHelper? streamCameraHelper) {
      setState(() {
        _showHome = false;
        _viewerMode = viewerMode;
        _videoStreamMode = videoStreamMode;
        _videoStreamType = videoStreamType;
        _videoQuality = videoQuality;
        _location = location;
        _archiveDateTime = archiveDateTime;
        _selectedVideoCamera = selectedVideoCamera;
        _selectedCameraIndex = selectedCameraIndex;
        _photoCameraHelper = photoCameraHelper;
        _historicalPhotoCameraHelper = historicalPhotoCameraHelper;
        _streamCameraHelper = streamCameraHelper;
      });
    }

    if (_restoreHome) {
      _restoreHome = false;
      return HomePage.restore(
          submitHandler,
          _viewerMode,
          _videoStreamMode,
          _videoStreamType,
          _videoQuality,
          _location,
          _archiveDateTime,
          _selectedVideoCamera,
          _selectedCameraIndex,
          _photoCameraHelper,
          _historicalPhotoCameraHelper,
          _streamCameraHelper);
    }

    return HomePage(submitHandler);
  }
}
*/
