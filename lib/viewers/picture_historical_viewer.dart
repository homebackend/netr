import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:netr/tool.dart';
import 'package:netr/viewers/base_viewer.dart';
import 'package:netr/helpers/historical_photo_camera_helper.dart';
import 'package:window_manager/window_manager.dart';

class PictureHistoricalViewerHome extends BaseViewer {
  const PictureHistoricalViewerHome(
      this.historicalPhotoCameraHelper,
      this.currentDateTime,
      this.index,
      selectedVideoCamera,
      selectedVideoQuality,
      location,
      callback,
      {Key? key})
      : super(selectedVideoCamera, selectedVideoQuality, location, callback,
            key: key);

  final HistoricalPhotoCameraHelper historicalPhotoCameraHelper;
  final DateTime currentDateTime;
  final int index;

  @override
  PictureHistoricalViewerHomeState createState() =>
      PictureHistoricalViewerHomeState();
}

class PictureHistoricalViewerHomeState
    extends BaseViewerState<PictureHistoricalViewerHome> {
  DateTime? _currentDateTime;
  int? _index;
  String? _imageUrl;
  int _frequency = 15;
  bool _isPlayingForward = false;
  bool _isPlayingBackward = false;

  @override
  void initState() {
    super.initState();
    if (isDesktopPlatform()) {
      _initWindow();
    }

    _currentDateTime = widget.currentDateTime;
    _index = widget.index;
    _frequency =
        widget.historicalPhotoCameraHelper.getFrequency(selectedVideoCamera!);
    _setImageUrl(_currentDateTime!);
  }

  Future<void> _initWindow() async {
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    await windowManager.maximize();
  }

  Future<bool> _setImageUrl(DateTime oldDateTime) async {
    var url = await widget.historicalPhotoCameraHelper.getHistoricalImageUrl(
        _currentDateTime!,
        selectedVideoCamera!,
        _index!,
        widget.selectedVideoQuality);
    if (url == null) {
      showSnackBar(context,
          'No such image: ${toDisplayText(selectedVideoCamera!)} [${DateFormat("yyyy-MM-dd-HH:mm").format(_currentDateTime!)}]');
      _currentDateTime = oldDateTime;
      return false;
    }
    _imageUrl = url;
    log('Image url: $_imageUrl');
    setState(() {
      isInitialized = true;
    });
    return true;
  }

  @override
  void dispose() {
    _isPlayingBackward = false;
    _isPlayingForward = false;

    if (isDesktopPlatform()) {
      windowManager.unmaximize();
      windowManager.setTitleBarStyle(TitleBarStyle.normal);
      windowManager.center();
    }

    super.dispose();
  }

  @override
  Widget getMainViewWidget(BuildContext context) {
    return Image.network(_imageUrl!);
  }

  @override
  List<Widget> getNavigators(BuildContext context) {
    List<Widget> navigators = <Widget>[];
    if (!_isPlayingBackward && !_isPlayingForward) {
      navigators.add(getPreviousButton(context));
      navigators.add(getNextButton(context));
      navigators.add(createNavigatorButton(Icons.fast_rewind, () {
        Navigator.pop(context);
        _changeImage(const Duration(days: 1), false);
      }));
      navigators.add(createNavigatorButton(Icons.fast_forward, () {
        Navigator.pop(context);
        _changeImage(const Duration(days: 1), true);
      }));
    }
    if (_isPlayingBackward) {
      navigators.add(createNavigatorButton(Icons.pause, () {
        Navigator.pop(context);
        _isPlayingForward = false;
        _isPlayingBackward = false;
      }));
    } else {
      navigators.add(createNavigatorButton(Icons.skip_previous, () {
        Navigator.pop(context);
        _isPlayingForward = false;
        _isPlayingBackward = true;
        _changeImageTimed(
            Duration(minutes: _frequency), false, const Duration(seconds: 5));
      }));
    }
    if (_isPlayingForward) {
      navigators.add(createNavigatorButton(Icons.pause, () {
        Navigator.pop(context);
        _isPlayingForward = false;
        _isPlayingBackward = false;
      }));
    } else {
      navigators.add(createNavigatorButton(Icons.skip_next, () {
        Navigator.pop(context);
        _isPlayingBackward = false;
        _isPlayingForward = true;
        _changeImageTimed(
            Duration(minutes: _frequency), true, const Duration(seconds: 5));
      }));
    }
    return navigators;
  }

  Future _changeImageTimed(
      Duration duration, bool add, Duration repeatAfter) async {
    if (!_isPlayingBackward && !_isPlayingForward) {
      setState(() {});
      return;
    }

    if (!await _changeImage(duration, add)) {
      setState(() {
        _isPlayingForward = false;
        _isPlayingBackward = false;
      });
      return;
    }

    if (add && _isPlayingForward || !add && _isPlayingBackward) {
      Timer(repeatAfter, () {
        _changeImageTimed(duration, add, repeatAfter);
      });
    }
  }

  Future<bool> _changeImage(Duration duration, bool add) async {
    DateTime oldDateTime = _currentDateTime!;
    _currentDateTime = add
        ? _currentDateTime?.add(duration)
        : _currentDateTime?.subtract(duration);
    return await _setImageUrl(oldDateTime);
  }

  @override
  Future<void> next() async {
    _changeImage(Duration(minutes: _frequency), true);
  }

  @override
  Future<void> previous() async {
    _changeImage(Duration(minutes: _frequency), false);
  }

  @override
  Widget getSelectionView() {
    List<DateTime> dateTimes = [];
    DateTime now = DateTime.now();
    now = DateTime(now.year, now.month, now.day, now.hour,
        now.minute - now.minute % _frequency, 0);
    DateTime oldest = now.subtract(const Duration(days: 2));
    oldest = DateTime(oldest.year, oldest.month, oldest.day, 0, 0, 0);

    while (!now.isBefore(oldest)) {
      dateTimes.add(now);
      now = now.subtract(Duration(minutes: _frequency));
    }

    bool first = true;
    List<Widget> dateTimeWidgets = [];
    for (DateTime now in dateTimes) {
      if (first || (now.hour == 23 && now.minute == 45)) {
        first = false;
        dateTimeWidgets.add(
          Text(
            DateFormat('EE, dd/LL').format(now),
            style: getPopupInfoStyle(),
          ),
        );
      }

      dateTimeWidgets.add(createButton(
        DateFormat('KK:mm a').format(now),
        () {
          Navigator.pop(context);
          DateTime oldDateTime = _currentDateTime!;
          _currentDateTime = now;
          _setImageUrl(oldDateTime);
        },
        getPopupItemStyle(),
      ));
    }

    return ListView(
      children: dateTimeWidgets,
    );
  }
}
