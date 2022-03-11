import 'dart:convert';
import 'dart:developer';

import 'package:netr/helpers/photo_camera_helper.dart';
import 'package:netr/helpers/stream_camera_helper.dart';
import 'package:netr/models/app_info.dart';
import 'package:netr/tool.dart';
import 'package:netr/viewers/base_viewer.dart';
import 'package:netr/viewers/direct_archive_video_viewer.dart';
import 'package:netr/viewers/direct_video_viewer.dart';
import 'package:netr/viewers/picture_viewer.dart';
import 'package:netr/viewers/ssh_archive_video_viewer.dart';
import 'package:netr/viewers/ssh_video_viewer.dart';
import 'package:netr/viewers/vlc_direct_archive_video_viewer.dart';
import 'package:netr/viewers/vlc_direct_video_viewer.dart';

import 'config.dart';
import 'home.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  return runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return const MaterialApp(home: Home());
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  OtaEvent? _currentEvent;
  bool _updateAvailable = false;
  bool _updateInProgress = false;
  bool _showHome = true;
  bool _restoreHome = false;
  ViewerMode? _viewerMode;
  VideoStreamMode? _videoStreamMode;
  VideoStreamType? _videoStreamType;
  String? _videoQuality;
  String? _location;
  DateTime? _archiveDateTime;
  PhotoCameraHelper? _photoCameraHelper;
  StreamCameraHelper? _streamCameraHelper;
  String? _selectedVideoCamera;

  @override
  void initState() {
    super.initState();
    checkUpdateRequired();
  }

  Future<void> checkUpdateRequired() async {
    try {
      final currentInfo = await PackageInfo.fromPlatform();
      log('Current App version: ${currentInfo.buildNumber}');
      String baseUrl = properties['upgrade']['baseUrl'];
      var contents = await http.read(Uri.parse(baseUrl + '/info.json'));
      final AppInfo appInfo = AppInfo.fromJson(jsonDecode(contents));
      log('Available App version: ${appInfo.version}');

      if (int.parse(currentInfo.buildNumber) < int.parse(appInfo.version)) {
        setState(() {
          _updateAvailable = true;
        });
      }
    } catch (e) {
      log('Error accessing update data: $e');
      showSnackBar(
          context, 'Unable to check for App update. Will retry later.');
    }
  }

  Future<void> tryOtaUpdate() async {
    try {
      String baseUrl = properties['upgrade']['baseUrl'];
      String fileName = properties['upgrade']['fileName'];
      OtaUpdate()
          .execute(
        '$baseUrl/$fileName',
        destinationFilename: fileName,
      )
          .listen(
        (OtaEvent event) {
          setState(() => _currentEvent = event);
        },
      );
    } catch (e) {
      log('Failed to make OTA update. Details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_updateAvailable) {
      return Scaffold(
          appBar: AppBar(
            title: const Text('Netr App'),
          ),
          body: Column(
            children: [
              const Center(
                child: Text(
                  'A new version of App is available. Kindly update App to latest version.',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 20,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  createButton("Yes update", () {
                    tryOtaUpdate();
                    setState(() {
                      _updateAvailable = false;
                      _updateInProgress = true;
                    });
                  }),
                  createButton("No, may be next time", () {
                    setState(() {
                      _updateAvailable = false;
                    });
                  }),
                ],
              ),
            ],
          ));
    } else if (_updateInProgress && _currentEvent != null) {
      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Netr App'),
          ),
          body: Center(
            child: Text(
                'Update in progress. Current status: ${_currentEvent?.status} : ${_currentEvent?.value} \n'),
          ),
        ),
      );
    } else if (!_showHome) {
      void callback(bool showInstruction) {
        setState(() {
          _showHome = true;
          _restoreHome = true;
        });
      }

      BaseViewer? viewer;

      switch (_viewerMode) {
        case ViewerMode.picture:
        case ViewerMode.pictureArchive:
          viewer = PictureViewerHome(_photoCameraHelper!, _selectedVideoCamera,
              _videoQuality, '', callback);
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
        PhotoCameraHelper? photoCameraHelper,
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
        _photoCameraHelper = photoCameraHelper;
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
          _photoCameraHelper,
          _streamCameraHelper);
    }

    return HomePage(submitHandler);
  }
}
