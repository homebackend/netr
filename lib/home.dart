import 'package:netr/helpers/camera_helper.dart';

import 'helpers/photo_camera_helper.dart';
import 'helpers/stream_camera_helper.dart';
import 'tool.dart';

import 'package:flutter/material.dart';
import 'package:date_time_picker/date_time_picker.dart';

typedef HomePageCallback = void Function(
    ViewerMode viewerMode,
    VideoStreamMode? videoStreamMode,
    VideoStreamType? videoStreamType,
    String videoQuality,
    String? location,
    DateTime? archiveDateTime,
    String selectedVideoCamera,
    PhotoCameraHelper? photoCameraHelper,
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
      this.photoCameraHelper,
      this.streamCameraHelper})
      : super(key: key);

  const HomePage.restore(
      this.onSubmit,
      this.viewerMode,
      this.videoStreamMode,
      this.videoStreamType,
      this.videoQuality,
      this.location,
      this.archiveDateTime,
      this.selectedVideoCamera,
      this.photoCameraHelper,
      this.streamCameraHelper,
      {Key? key})
      : super(key: key);

  final HomePageCallback onSubmit;
  final ViewerMode? viewerMode;
  final VideoStreamMode? videoStreamMode;
  final VideoStreamType? videoStreamType;
  final String? videoQuality;
  final String? location;
  final DateTime? archiveDateTime;
  final String? selectedVideoCamera;
  final PhotoCameraHelper? photoCameraHelper;
  final StreamCameraHelper? streamCameraHelper;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ViewerMode? _viewerMode;
  VideoStreamMode? _videoStreamMode;
  VideoStreamType? _videoStreamType;
  String? _location;
  String? _videoQuality;
  DateTime? _archiveDateTime;
  String? _selectedVideoCamera;
  PhotoCameraHelper? _photoCameraHelper;
  StreamCameraHelper? _streamCameraHelper;

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
    _photoCameraHelper = widget.photoCameraHelper;
    _streamCameraHelper = widget.streamCameraHelper;
  }

  @override
  Widget build(BuildContext context) {
    var columns = <Widget>[];

    // ################################################################
    // # Viewer Mode
    // ################################################################
    var viewerModesWidgets = <Widget>[];
    viewerModesWidgets
        .add(const FittedBox(fit: BoxFit.fitHeight, child: Text('Mode:')));

    for (var viewerMode in ViewerMode.values) {
      if (viewerMode == ViewerMode.none ||
          viewerMode == ViewerMode.pictureArchive) {
        continue;
      }

      viewerModesWidgets.add(createIconButton(
          viewerMode.iconData,
          _viewerMode == viewerMode
              ? null
              : () async {
                  setState(() {
                    _viewerMode = viewerMode;
                  });
                },
          viewerMode.displayTitle));
    }
    columns.add(SizedBox(
        height: 35,
        child: ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: viewerModesWidgets)));
    columns.add(Container(height: 5));

    // ################################################################
    // # Camera Selection
    // ################################################################
    var cameraWidgets = <Widget>[];
    cameraWidgets.add(
        const FittedBox(fit: BoxFit.fitHeight, child: Text('Which camera:')));
    CameraHelper? cameraHelper;
    bool noneSelected = false;
    switch (_viewerMode) {
      case ViewerMode.picture:
      case ViewerMode.pictureArchive:
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
      case ViewerMode.remoteVlc:
      case ViewerMode.inAppVideo:
        if (_streamCameraHelper == null) {
          _streamCameraHelper = StreamCameraHelper(() {
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
      List<String> cameras = cameraHelper!.getCameras();
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
                    });
                  }));
      }
    }
    columns.add(SizedBox(
        height: 35,
        child: ListView(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          children: cameraWidgets,
        )));

    // ################################################################
    // # Stream Mode (Direct|Ssh)
    // ################################################################
    if (_viewerMode == ViewerMode.inAppVideo ||
        _viewerMode == ViewerMode.remoteVlc) {
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
        columns.add(Row(children: videoStreamModeWidgets));
      }

      // ################################################################
      // # Access Point
      // ################################################################
      if (_selectedVideoCamera != null && _videoStreamMode != null) {
        List<String> locations = (cameraHelper as StreamCameraHelper)
            .getLocations(_selectedVideoCamera!, _videoStreamMode!);
        if (locations.length > 1) {
          String defaultLocation = (cameraHelper as StreamCameraHelper)
              .getDefaultLocation(_selectedVideoCamera!);
          _location ??= defaultLocation;

          var locationWidgets = <Widget>[];
          locationWidgets.add(const FittedBox(
              fit: BoxFit.fitHeight, child: Text('Where (access point): ')));

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

          columns.add(Row(children: locationWidgets));
        } else {
          _location = locations[0];
        }
      }
    }

    // ################################################################
    // # Stream Type (Live|Archive)
    // ################################################################
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
      columns.add(Row(children: videoStreamTypeWidgets));
    }

    // ################################################################
    // # Quality
    // ################################################################
    if (_viewerMode == ViewerMode.inAppVideo &&
        _videoStreamType == VideoStreamType.archive) {
      _videoQuality = 'archive';
    } else if (_selectedVideoCamera != null) {
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
        columns.add(Row(children: videoQualityWidgets));
      }
    }

    // ################################################################
    // # Archive date time
    // ################################################################
    if (_viewerMode == ViewerMode.pictureArchive ||
        _videoStreamType == VideoStreamType.archive) {
      var now = DateTime.now();
      var firstDate = _viewerMode == ViewerMode.pictureArchive
          ? now.subtract(const Duration(days: 5))
          : now.subtract(const Duration(days: 30));

      columns.add(
        DateTimePicker(
          type: DateTimePickerType.dateTime,
          initialDate: _archiveDateTime,
          firstDate: firstDate,
          lastDate: DateTime(now.year, now.month, now.day),
          icon: const Icon(Icons.archive),
          dateLabelText: 'Which (date and time):',
          onChanged: (val) {
            var input = DateTime.parse(val);
            if (_viewerMode == ViewerMode.pictureArchive) {
              var rem = input.minute % 15;

              if (rem >= 8) {
                input = input.add(Duration(minutes: rem));
              } else if (rem > 0) {
                input = input.subtract(Duration(minutes: rem));
              }
            }

            setState(() {
              _archiveDateTime = input;
            });
          },
        ),
      );
    }

    // ################################################################
    // # Go Button
    // ################################################################
    bool enableGoButton = false;
    switch (_viewerMode) {
      case ViewerMode.picture:
      case ViewerMode.pictureArchive:
        enableGoButton = _selectedVideoCamera != null &&
            _videoQuality != null &&
            (_viewerMode == ViewerMode.picture || _archiveDateTime != null);
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
    if (!enableGoButton) {
      columns.add(const Text(
        'Please select appropriate options to move forward',
        style: TextStyle(color: Colors.blueAccent),
      ));
    } else {
      columns.add(createIconButton(Icons.not_started, () {
        widget.onSubmit(
            _viewerMode!,
            _videoStreamMode,
            _videoStreamType,
            _videoQuality!,
            _location,
            _archiveDateTime,
            _selectedVideoCamera!,
            _photoCameraHelper,
            _streamCameraHelper);
      }, 'Go'));
    }

    return Scaffold(
        appBar: AppBar(title: const Text('Netr App')),
        body: SingleChildScrollView(child: Column(children: columns)));
  }
}
