import 'dart:async';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:netr/helpers/camera_helper.dart';
import 'package:netr/helpers/historical_photo_camera_helper.dart';
import 'package:netr/helpers/photo_camera_helper.dart';
import 'package:netr/helpers/stream_camera_helper.dart';
import 'package:netr/tool.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef HomePageCallback = void Function(
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
    StreamCameraHelper? streamCameraHelper);

class HomePage extends StatefulWidget {
  const HomePage(this.onSubmit,
      {Key? key,
      this.viewerMode,
      this.videoStreamMode,
      this.videoStreamType,
      this.videoQuality,
      this.location,
      this.archiveDateTime,
      this.selectedVideoCamera,
      this.selectedCameraIndex,
      this.photoCameraHelper,
      this.historicalPhotoCameraHelper,
      this.streamCameraHelper})
      : isRestored = false,
        super(key: key);

  const HomePage.restore(
      this.onSubmit,
      this.viewerMode,
      this.videoStreamMode,
      this.videoStreamType,
      this.videoQuality,
      this.location,
      this.archiveDateTime,
      this.selectedVideoCamera,
      this.selectedCameraIndex,
      this.photoCameraHelper,
      this.historicalPhotoCameraHelper,
      this.streamCameraHelper,
      {Key? key})
      : isRestored = true,
        super(key: key);

  final bool isRestored;
  final HomePageCallback onSubmit;
  final ViewerMode? viewerMode;
  final VideoStreamMode? videoStreamMode;
  final VideoStreamType? videoStreamType;
  final String? videoQuality;
  final String? location;
  final DateTime? archiveDateTime;
  final String? selectedVideoCamera;
  final int? selectedCameraIndex;
  final PhotoCameraHelper? photoCameraHelper;
  final HistoricalPhotoCameraHelper? historicalPhotoCameraHelper;
  final StreamCameraHelper? streamCameraHelper;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String _archive = 'archive';

  Timer? _minuteTimer;
  ViewerMode? _viewerMode;
  VideoStreamMode? _videoStreamMode;
  VideoStreamType? _videoStreamType;
  String? _location;
  String? _videoQuality;
  DateTime? _archiveDateTime;
  String? _selectedVideoCamera;
  int? _selectedCameraIndex;
  PhotoCameraHelper? _photoCameraHelper;
  HistoricalPhotoCameraHelper? _historicalPhotoCameraHelper;
  StreamCameraHelper? _streamCameraHelper;
  String? _selectedArchiveDateTimeButton;

  _HomePageState();

  @override
  void initState() {
    super.initState();

    _viewerMode = widget.viewerMode;
    _videoStreamMode = widget.videoStreamMode;
    _videoStreamType = widget.videoStreamType;
    _videoQuality = widget.videoQuality;
    _location = widget.location;
    _archiveDateTime = widget.archiveDateTime;
    _selectedVideoCamera = widget.selectedVideoCamera;
    _selectedCameraIndex = widget.selectedCameraIndex;
    _photoCameraHelper = widget.photoCameraHelper;
    _streamCameraHelper = widget.streamCameraHelper;
    _selectedArchiveDateTimeButton = null;

    if (!widget.isRestored) {
      _loadConfiguration(null);
    }

    _minuteTimer = Timer.periodic(const Duration(minutes: 1), (Timer t) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    if (_minuteTimer != null) {
      _minuteTimer!.cancel();
    }
    _saveConfiguration();
    super.dispose();
  }

  void _addViewerModes(List<Widget> columns) {
    var viewerModesWidgets = <Widget>[];
    viewerModesWidgets
        .add(const FittedBox(fit: BoxFit.fitHeight, child: Text('Mode:')));

    for (var viewerMode in ViewerMode.values) {
      if (viewerMode == ViewerMode.none) {
        continue;
      }

      if (isWebPlatform() && viewerMode == ViewerMode.inAppVideo) {
        continue;
      }

      viewerModesWidgets.add(createIconButton(
          viewerMode.iconData,
          _viewerMode == viewerMode
              ? null
              : () async {
                  await _saveConfiguration();
                  const videoModes = [
                    ViewerMode.inAppVideo,
                    ViewerMode.remoteVlc
                  ];
                  const pictureModes = [
                    ViewerMode.pictureArchive,
                    ViewerMode.picture
                  ];
                  if ((videoModes.contains(viewerMode) &&
                          pictureModes.contains(_viewerMode)) ||
                      (videoModes.contains(_viewerMode) &&
                          pictureModes.contains(viewerMode))) {
                    _location = null;
                  }

                  await _loadConfiguration(viewerMode.toString());
                  setState(() {
                    _viewerMode = viewerMode;
                  });
                },
          viewerMode.displayTitle));
    }
    columns.add(
      FocusTraversalGroup(
        child: SizedBox(
          height: 35,
          child: ListView(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              children: viewerModesWidgets),
        ),
      ),
    );
    columns.add(Container(height: 5));
  }

  CameraHelper? _addCameraWidgets(List<Widget> columns) {
    var cameraWidgets = <Widget>[];
    cameraWidgets.add(
        const FittedBox(fit: BoxFit.fitHeight, child: Text('Which camera:')));
    CameraHelper? cameraHelper;
    bool noneSelected = false;
    switch (_viewerMode) {
      case ViewerMode.picture:
        if (_photoCameraHelper == null) {
          _photoCameraHelper = PhotoCameraHelper(() {
            setState(() {
              cameraHelper = _photoCameraHelper;
            });
          }, (error) {
            showSnackBar(context, 'Error loading info: $error');
            _photoCameraHelper = null;
          });
          _photoCameraHelper?.init();
        } else {
          cameraHelper = _photoCameraHelper!;
        }
        break;
      case ViewerMode.pictureArchive:
        if (_historicalPhotoCameraHelper == null) {
          _historicalPhotoCameraHelper = HistoricalPhotoCameraHelper(() {
            setState(() {
              cameraHelper = _historicalPhotoCameraHelper;
            });
          }, (error) {
            showSnackBar(context, 'Error loading info: $error');
            _historicalPhotoCameraHelper = null;
          });
          _historicalPhotoCameraHelper?.init();
        } else {
          cameraHelper = _historicalPhotoCameraHelper!;
        }
        break;
      case ViewerMode.remoteVlc:
      case ViewerMode.inAppVideo:
        if (_streamCameraHelper == null) {
          _streamCameraHelper = StreamCameraHelper(_videoStreamMode, () {
            setState(() {
              cameraHelper = _streamCameraHelper;
            });
          }, (error) {
            showSnackBar(context, 'Error loading info: $error');
            _streamCameraHelper = null;
          });
          _streamCameraHelper?.init();
        } else {
          cameraHelper = _streamCameraHelper!;
        }
        break;
      case ViewerMode.none:
      default:
        noneSelected = true;
        break;
    }
    if (noneSelected) {
      cameraWidgets
          .add(const Center(child: Text('Select View Mode to list cameras')));
    } else if (cameraHelper == null) {
      cameraWidgets.add(getBusyIndicator());
    } else {
      String? quality = _videoQuality == _archive ? null : _videoQuality;
      List<String> cameras = cameraHelper!.getCameras(quality);
      for (int i = 0; i < cameras.length; i++) {
        String camera = cameras[i];
        var text = toDisplayText(camera);
        cameraWidgets.add(createButton(
            text,
            _selectedVideoCamera == camera
                ? null
                : () {
                    setState(() {
                      _selectedVideoCamera = camera;
                      _selectedCameraIndex = i;
                    });
                  }));
      }
    }
    columns.add(
      FocusTraversalGroup(
        child: SizedBox(
          height: 35,
          child: ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: cameraWidgets,
          ),
        ),
      ),
    );

    return cameraHelper;
  }

  void _addStreamModeWidgets(List<Widget> columns) {
    if (_viewerMode == ViewerMode.remoteVlc) {
      _videoStreamMode = VideoStreamMode.streamDirect;
    } else {
      var videoStreamModeWidgets = <Widget>[];
      videoStreamModeWidgets.add(const FittedBox(
          fit: BoxFit.fitHeight, child: Text('How (stream mode): ')));

      for (var videoStreamMode in VideoStreamMode.values) {
        videoStreamModeWidgets.add(createButton(
            videoStreamMode.displayTitle,
            _videoStreamMode == videoStreamMode
                ? null
                : () {
                    setState(() {
                      _videoStreamMode = videoStreamMode;
                    });
                  }));
      }
      columns.add(
        FocusTraversalGroup(
          child: Row(children: videoStreamModeWidgets),
        ),
      );
    }
  }

  void _addLocationWidgets(CameraHelper? cameraHelper, List<Widget> columns) {
    if (_viewerMode == null || cameraHelper == null) {
      return;
    }

    if (((_selectedVideoCamera != null && _videoStreamMode != null) ||
        _viewerMode == ViewerMode.picture ||
        _viewerMode == ViewerMode.pictureArchive)) {
      List<String> locations =
          cameraHelper.getLocations(_selectedVideoCamera ?? '');
      String title = '';
      switch (_viewerMode) {
        case ViewerMode.inAppVideo:
        case ViewerMode.remoteVlc:
          title = 'Where (access point): ';
          break;
        case ViewerMode.picture:
        case ViewerMode.pictureArchive:
        default:
          title = 'Which (location): ';
          break;
      }

      if (locations.length > 1) {
        String defaultLocation =
            cameraHelper.getDefaultLocation(_selectedVideoCamera!);
        _location ??= defaultLocation;

        var locationWidgets = <Widget>[];
        locationWidgets
            .add(FittedBox(fit: BoxFit.fitHeight, child: Text(title)));

        for (String location in locations) {
          locationWidgets.add(createButton(
              toDisplayText(location),
              _location == location
                  ? null
                  : () {
                      setState(() {
                        _location = location;
                      });
                    }));
        }

        columns.add(
          FocusTraversalGroup(
            child: Row(children: locationWidgets),
          ),
        );
      } else {
        _location = locations[0];
      }
    }
  }

  void _addVideoStreamWidgets(List<Widget> columns) {
    if (_viewerMode == ViewerMode.inAppVideo ||
        _viewerMode == ViewerMode.remoteVlc) {
      var videoStreamTypeWidgets = <Widget>[];
      videoStreamTypeWidgets.add(const FittedBox(
          fit: BoxFit.fitHeight, child: Text('Which (stream type): ')));

      for (var videoStreamType in VideoStreamType.values) {
        videoStreamTypeWidgets.add(createButton(
            videoStreamType.displayTitle,
            _videoStreamType == videoStreamType
                ? null
                : () {
                    setState(() {
                      _videoStreamType = videoStreamType;
                    });
                  }));
      }
      columns.add(
        FocusTraversalGroup(
          child: Row(children: videoStreamTypeWidgets),
        ),
      );
    }
  }

  void _addQualityWidgets(CameraHelper? cameraHelper, List<Widget> columns) {
    switch (_viewerMode) {
      case ViewerMode.inAppVideo:
      case ViewerMode.remoteVlc:
        if (_videoStreamType == VideoStreamType.archive) {
          _videoQuality = _archive;
          return;
        } else if (_videoStreamType == null) {
          return;
        }
        break;
      default:
    }

    if (_selectedVideoCamera != null) {
      List<String> types = cameraHelper?.getTypes(_selectedVideoCamera!) ?? [];
      String defaultType = cameraHelper?.getDefaultType() ?? '';
      if (types.isNotEmpty) {
        _videoQuality ??= defaultType;
        var videoQualityWidgets = <Widget>[];
        videoQualityWidgets.add(const FittedBox(
            fit: BoxFit.fitHeight, child: Text('Which (quality): ')));
        for (var videoQuality in types) {
          videoQualityWidgets.add(createButton(
              toDisplayText(videoQuality),
              _videoQuality == videoQuality
                  ? null
                  : () {
                      setState(() {
                        _videoQuality = videoQuality;
                      });
                    }));
        }
        columns.add(
          FocusTraversalGroup(
            child: Row(children: videoQualityWidgets),
          ),
        );
      }
    }
  }

  void _addArchiveDateTimeWidgets(List<Widget> columns) {
    if (_viewerMode != ViewerMode.remoteVlc &&
        _viewerMode != ViewerMode.inAppVideo) {
      return;
    }

    if (_videoStreamType == VideoStreamType.archive) {
      var now = DateTime.now();
      var firstDate = _viewerMode == ViewerMode.pictureArchive
          ? now.subtract(const Duration(days: 5))
          : now.subtract(const Duration(days: 30));

      final Map<String, DateTime> dateTimeMapping = {
        '1 min': now.subtract(const Duration(minutes: 1)),
        '2 min': now.subtract(const Duration(minutes: 2)),
        '3 min': now.subtract(const Duration(minutes: 3)),
        '5 min': now.subtract(const Duration(minutes: 5)),
        '10 min': now.subtract(const Duration(minutes: 10)),
        '30 min': now.subtract(const Duration(minutes: 30)),
        '1 hour': now.subtract(const Duration(hours: 1)),
        '2 hour': now.subtract(const Duration(hours: 2)),
        '3 hour': now.subtract(const Duration(hours: 3)),
        '6 hour': now.subtract(const Duration(hours: 6)),
        '12 hours': now.subtract(const Duration(hours: 12)),
        '1 day': now.subtract(const Duration(days: 1)),
        '2 day': now.subtract(const Duration(days: 2)),
        '1 week': now.subtract(const Duration(days: 7)),
      };

      var archiveDateTimeWidgets = <Widget>[];
      archiveDateTimeWidgets.add(
          const FittedBox(fit: BoxFit.fitHeight, child: Text('What (time): ')));

      DateTimePicker dateTimePicker = DateTimePicker(
        type: DateTimePickerType.dateTime,
        initialDate: _archiveDateTime,
        initialTime: _archiveDateTime == null
            ? null
            : TimeOfDay(
                hour: _archiveDateTime!.hour, minute: _archiveDateTime!.minute),
        firstDate: firstDate,
        lastDate: DateTime(now.year, now.month, now.day),
        icon: const Icon(Icons.archive),
        dateLabelText: 'What (date and time):',
        onChanged: (val) {
          var input = DateTime.parse(val);
          var now = DateTime.now();
          if (input.isAfter(now)) {
            input = now;
          }

          if (_viewerMode == ViewerMode.pictureArchive) {
            var rem = input.minute % 15;
            if (rem >= 8) {
              input = input.add(Duration(minutes: rem));
            } else if (rem > 0) {
              input = input.subtract(Duration(minutes: rem));
            }
          }

          _selectedArchiveDateTimeButton = null;
          setState(() {
            _archiveDateTime = input;
          });
        },
      );

      dateTimeMapping.forEach((key, value) {
        archiveDateTimeWidgets.add(createButton(
            toDisplayText(key),
            _selectedArchiveDateTimeButton == key
                ? null
                : () {
                    _selectedArchiveDateTimeButton = key;
                    setState(() {
                      _archiveDateTime = value;
                    });
                  }));
      });
      archiveDateTimeWidgets.add(
          const FittedBox(fit: BoxFit.fitHeight, child: Text(' in the past')));

      columns.add(
        FocusTraversalGroup(
          child: Row(children: archiveDateTimeWidgets),
        ),
      );
      columns.add(dateTimePicker);
    }
  }

  void _addGoWidgets(List<Widget> columns, CameraHelper? cameraHelper) {
    bool enableGoButton = false;
    if (cameraHelper != null) {
      switch (_viewerMode) {
        case ViewerMode.picture:
        case ViewerMode.pictureArchive:
          enableGoButton =
              _selectedVideoCamera != null && _videoQuality != null;
          break;
        case ViewerMode.remoteVlc:
        case ViewerMode.inAppVideo:
          enableGoButton = _selectedVideoCamera != null &&
              _videoStreamMode != null &&
              isStringEmptyOrNull(_videoQuality) &&
              isStringEmptyOrNull(_location) &&
              _videoStreamType != null &&
              (_videoStreamType == VideoStreamType.live ||
                  _archiveDateTime != null);
          break;
        default:
      }
    }
    if (!enableGoButton) {
      columns.add(const Text(
        'Please select all required options to move forward',
        style: TextStyle(color: Colors.blueAccent),
      ));
    } else {
      columns.add(
        createIconButton(
          Icons.start,
          () {
            _saveConfigurationAndSubmit();
          },
          'Go',
          ButtonStyle(
            alignment: Alignment.center,
            backgroundColor: MaterialStateProperty.all(Colors.black54),
            foregroundColor: MaterialStateProperty.all(Colors.blue),
            textStyle: MaterialStateProperty.all(
              const TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          true,
          true,
        ),
      );
    }
  }

  Future<void> _loadConfiguration(String? strViewerMode) async {
    _viewerMode = null;
    _videoStreamMode = null;
    _videoStreamType = null;
    _location = null;
    _videoQuality = null;
    _archiveDateTime = null;
    _selectedVideoCamera = null;
    _selectedCameraIndex = null;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    strViewerMode ??= prefs.getString("ViewerMode");
    if (strViewerMode == null) {
      return;
    }

    _viewerMode =
        ViewerMode.values.firstWhere((e) => e.toString() == strViewerMode);

    _selectedCameraIndex = prefs.getInt("$strViewerMode.SelectedCameraIndex");
    _selectedVideoCamera =
        prefs.getString("$strViewerMode.SelectedVideoCamera");
    _videoQuality = prefs.getString("$strViewerMode.VideoQuality");

    if (_viewerMode == ViewerMode.remoteVlc ||
        _viewerMode == ViewerMode.inAppVideo) {
      String? videoStreamType =
          prefs.getString("$strViewerMode.VideoStreamType");
      if (videoStreamType != null) {
        _videoStreamType = VideoStreamType.values
            .firstWhere((e) => e.toString() == videoStreamType);
      }
      _location = prefs.getString("$strViewerMode.Location");
      String? archiveDateTime =
          prefs.getString("$strViewerMode.ArchiveDateTime");
      if (archiveDateTime != null) {
        _archiveDateTime = DateTime.parse(archiveDateTime);
      }
    }

    if (_viewerMode == ViewerMode.inAppVideo) {
      String? videoStreamMode =
          prefs.getString("$strViewerMode.VideoStreamMode");
      if (videoStreamMode != null) {
        _videoStreamMode = VideoStreamMode.values
            .firstWhere((e) => e.toString() == videoStreamMode);
      }
    }

    setState(() {});
  }

  Future<void> _saveConfiguration() async {
    if (_viewerMode == null) {
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String strViewerMode = _viewerMode.toString();
    await prefs.setString("ViewerMode", strViewerMode);

    if (_selectedCameraIndex != null) {
      await prefs.setInt(
          "$strViewerMode.SelectedCameraIndex", _selectedCameraIndex!);
    }
    if (_selectedVideoCamera != null) {
      await prefs.setString(
          "$strViewerMode.SelectedVideoCamera", _selectedVideoCamera!);
    }
    if (_videoQuality != null) {
      await prefs.setString("$strViewerMode.VideoQuality", _videoQuality!);
    }

    if (_viewerMode == ViewerMode.remoteVlc ||
        _viewerMode == ViewerMode.inAppVideo) {
      if (_videoStreamType != null) {
        await prefs.setString(
            "$strViewerMode.VideoStreamType", _videoStreamType.toString());
      }
      if (_location != null) {
        await prefs.setString("$strViewerMode.Location", _location!);
      }
      if (_archiveDateTime != null) {
        await prefs.setString(
            "$strViewerMode.ArchiveDateTime", _archiveDateTime.toString());
      }
    }

    if (_viewerMode == ViewerMode.inAppVideo) {
      if (_videoStreamMode != null) {
        await prefs.setString(
            "$strViewerMode.VideoStreamMode", _videoStreamMode.toString());
      }
    }
  }

  Future<void> _saveConfigurationAndSubmit() async {
    await _saveConfiguration();

    widget.onSubmit(
        _viewerMode!,
        _videoStreamMode,
        _videoStreamType,
        _videoQuality!,
        _location,
        _archiveDateTime,
        _selectedVideoCamera!,
        _selectedCameraIndex!,
        _photoCameraHelper,
        _historicalPhotoCameraHelper,
        _streamCameraHelper);
  }

  @override
  Widget build(BuildContext context) {
    var columns = <Widget>[];
    if (_videoQuality == _archive &&
        (_videoStreamType != VideoStreamType.archive ||
            _viewerMode == ViewerMode.picture ||
            _viewerMode == ViewerMode.pictureArchive)) {
      _videoQuality = null;
    }
    if ((_viewerMode == ViewerMode.inAppVideo ||
            _viewerMode == ViewerMode.remoteVlc) &&
        _streamCameraHelper != null) {
      _streamCameraHelper!.videoStreamMode = _videoStreamMode;
    }

    // ################################################################
    // # Viewer Mode
    // ################################################################
    _addViewerModes(columns);

    // ################################################################
    // # Camera Selection
    // ################################################################
    CameraHelper? cameraHelper = _addCameraWidgets(columns);

    if (cameraHelper != null && _selectedVideoCamera != null) {
      if (!cameraHelper.doesCameraExist(_selectedVideoCamera!, _videoQuality)) {
        _selectedCameraIndex = null;
        _selectedVideoCamera = null;
        _videoQuality = null;
      }
    }

    switch (_viewerMode) {
      case ViewerMode.inAppVideo:
      case ViewerMode.remoteVlc:
        // ################################################################
        // # Stream Mode (Direct|Ssh)
        // ################################################################
        _addStreamModeWidgets(columns);
        // ################################################################
        // # Access point
        // ################################################################
        _addLocationWidgets(cameraHelper, columns);
        break;
      case ViewerMode.picture:
      case ViewerMode.pictureArchive:
        // ################################################################
        // # Location
        // ################################################################
        _addLocationWidgets(cameraHelper, columns);
        break;
      default:
    }

    // ################################################################
    // # Stream Type (Live|Archive)
    // ################################################################
    _addVideoStreamWidgets(columns);

    // ################################################################
    // # Quality
    // ################################################################
    _addQualityWidgets(cameraHelper, columns);

    // ################################################################
    // # Archive date time
    // ################################################################
    _addArchiveDateTimeWidgets(columns);

    // ################################################################
    // # Go Button
    // ################################################################
    _addGoWidgets(columns, cameraHelper);

    return Scaffold(
      appBar: AppBar(title: const Text('Netr App')),
      body: SingleChildScrollView(child: Column(children: columns)),
    );
  }
}
