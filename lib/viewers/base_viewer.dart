import 'dart:core';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netr/tool.dart';
import 'package:netr/viewers/picture_historical_viewer.dart';
import 'package:vector_math/vector_math_64.dart' as vm64;
import 'package:wakelock/wakelock.dart';

typedef ViewerCallback = void Function(bool showInstruction);

abstract class BaseViewer extends StatefulWidget {
  const BaseViewer(this.selectedVideoCamera, this.selectedVideoQuality,
      this.location, this.callback,
      {Key? key})
      : super(key: key);

  final String selectedVideoCamera;
  final String selectedVideoQuality;
  final String location;
  final ViewerCallback callback;
}

abstract class BaseViewerState<T extends BaseViewer> extends State<T> {
  bool isInitialized = false;
  String? selectedVideoCamera;
  late TransformationController _controller;

  final double _drag = 8;
  final double _minDeltaAllowed = 1.0e-5;
  final double _minScale = 1.0;
  final double _maxScale = 8.0;
  final double _scaleFactor = 1.3034;
  final double _translationStep = 10;

  @override
  void initState() {
    super.initState();
    selectedVideoCamera = widget.selectedVideoCamera;
    _controller = TransformationController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> backButtonCleanup(context) async {}

  Future<void> next();

  Future<void> previous();

  Future<void> close() async {
    await backButtonCleanup(context);
    widget.callback(false);
  }

  Future<void> togglePlay() async {}

  Future<void> lockScreen() async {
    if (kIsWeb || !Platform.isLinux) {
      await Wakelock.enable();
    }
  }

  Future<void> unlockScreen() async {
    if (kIsWeb || !Platform.isLinux) {
      await Wakelock.disable();
    }
  }

  Widget getPreviousButton(context) {
    return createNavigatorButton(Icons.arrow_back, () async {
      Navigator.pop(context);
      await previous();
    });
  }

  Widget getNextButton(context) {
    return createNavigatorButton(Icons.arrow_forward, () async {
      Navigator.pop(context);
      await next();
    });
  }

  Widget getBackButton(context) {
    return createNavigatorButton(Icons.settings_backup_restore, () async {
      Navigator.pop(context);
      await close();
    });
  }

  void initializeViewer(BuildContext context) {}

  List<Widget> getNavigators(BuildContext context);

  Widget getMainViewWidget(BuildContext context);

  Widget getSelectionView();

  TextStyle getPopupInfoStyle() {
    return const TextStyle(
      color: Colors.green,
      fontWeight: FontWeight.bold,
      fontSize: 30,
    );
  }

  ButtonStyle getPopupItemStyle() {
    return ButtonStyle(
      alignment: Alignment.centerLeft,
      backgroundColor: MaterialStateProperty.all(Colors.black54),
      foregroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return Colors.amber;
        }
        return Colors.blue;
      }),
      textStyle: MaterialStateProperty.all(const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      )),
    );
  }

  void _scaleAndCenter(double scaleFactor) {
    Matrix4 value = Matrix4.copy(_controller.value)..scale(scaleFactor);
    double scale = value.getMaxScaleOnAxis();
    double maxWidth = MediaQuery.of(context).size.width;
    double maxHeight = MediaQuery.of(context).size.height;
    maxWidth *= scale - 1;
    maxHeight *= scale - 1;
    value.setTranslationRaw(-maxWidth / 2, -maxHeight / 2, 0);
    _controller.value = value;
  }

  void _restoreToOriginal() {
    _controller.value = Matrix4.identity();
  }

  void _translate(bool left, bool right, bool up, bool down) {
    double scale = _controller.value.getMaxScaleOnAxis();
    double maxWidth = MediaQuery.of(context).size.width;
    double maxHeight = MediaQuery.of(context).size.height;
    maxWidth *= scale - 1;
    maxHeight *= scale - 1;
    Matrix4 value = Matrix4.copy(_controller.value);
    vm64.Vector3 translation = value.getTranslation();
    double x = translation.x;
    double y = translation.y;

    double low(l) {
      if (-(l + _translationStep) > 0) {
        return _translationStep;
      } else if (-l > 0) {
        return -l;
      } else {
        return 0;
      }
    }

    double high(h, max) {
      if (-(h + _translationStep) < max) {
        return _translationStep;
      } else if (max > -h) {
        return max + h;
      } else {
        return 0;
      }
    }

    if (left) {
      x += low(x);
    }
    if (right) {
      x -= high(x, maxWidth);
    }
    if (up) {
      y += low(y);
    }
    if (down) {
      y -= high(y, maxHeight);
    }

    value.setTranslationRaw(x, y, translation.z);
    _controller.value = value;
  }

  void _zoomIn() {
    double scale = _controller.value.getMaxScaleOnAxis();
    if (scale * _scaleFactor < _maxScale) {
      _scaleAndCenter(_scaleFactor);
    } else {
      _scaleAndCenter(_maxScale / scale);
    }
  }

  void _zoomOut() {
    double scale = _controller.value.getMaxScaleOnAxis();
    if (scale / _scaleFactor > _minScale) {
      _scaleAndCenter(1 / _scaleFactor);
    } else {
      _scaleAndCenter(_minScale / scale);
    }
  }

  List<Widget> _getDialogItems() {
    List<Widget> navigators = getNavigators(context);
    navigators.add(getBackButton(context));

    return [
      SizedBox(
        height: 35,
        child: ListView(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          children: navigators,
        ),
      ),
      Text(
        this is! PictureHistoricalViewerHomeState
            ? "Select a Camera"
            : "Select Date Time",
        style: getPopupInfoStyle(),
      ),
      SizedBox(
        height: 300,
        child: getSelectionView(),
      ),
    ];
  }

  void _onTap() {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black38,
      barrierLabel: 'Camera Selection',
      barrierDismissible: true,
      pageBuilder: (_, __, ___) => Center(
        child: Material(
          color: Colors.transparent,
          child: SizedBox(
            height: 400,
            width: 400,
            child: ListView(
              scrollDirection: Axis.vertical,
              children: _getDialogItems(),
            ),
          ),
        ),
      ),
    );
  }

  bool _valueCloseToZero(double value) => value.abs() < _minDeltaAllowed;

  bool _isNotZoomedAndNotTranslated(Matrix4 value) {
    vm64.Vector3 translation = value.getTranslation();
    return _valueCloseToZero(value.getMaxScaleOnAxis() - 1.0) &&
        _valueCloseToZero(translation.x) &&
        _valueCloseToZero(translation.y) &&
        _valueCloseToZero(translation.z);
  }

  void _onInteractionEnd(ScaleEndDetails details) {
    if (_isNotZoomedAndNotTranslated(_controller.value)) {
      if (details.pointerCount == 0) {
        if (details.velocity.pixelsPerSecond.dx > _drag) {
          previous();
        }
        if (details.velocity.pixelsPerSecond.dx < -_drag) {
          next();
        }
      }
    }
  }

  void _onKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.isKeyPressed(LogicalKeyboardKey.select) ||
          event.isKeyPressed(LogicalKeyboardKey.enter) ||
          event.isKeyPressed(LogicalKeyboardKey.contextMenu)) {
        _onTap();
      } else if (event.isKeyPressed(LogicalKeyboardKey.space) ||
          event.isKeyPressed(LogicalKeyboardKey.mediaPlay) ||
          event.isKeyPressed(LogicalKeyboardKey.mediaPlayPause) ||
          event.isKeyPressed(LogicalKeyboardKey.mediaPause)) {
        togglePlay();
      } else if (event.isKeyPressed(LogicalKeyboardKey.mediaFastForward)) {
        _zoomIn();
      } else if (event.isKeyPressed(LogicalKeyboardKey.mediaRewind)) {
        _zoomOut();
      } else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
        if (_controller.value.isIdentity()) {
          previous();
        } else {
          _translate(true, false, false, false);
        }
      } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
        if (_controller.value.isIdentity()) {
          next();
        } else {
          _translate(false, true, false, false);
        }
      } else if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
        if (!_controller.value.isIdentity()) {
          _translate(false, false, true, false);
        }
      } else if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
        if (!_controller.value.isIdentity()) {
          _translate(false, false, false, true);
        }
      } else if (event.isKeyPressed(LogicalKeyboardKey.zoomOut) ||
          event.isKeyPressed(LogicalKeyboardKey.minus)) {
        _zoomOut();
      } else if (event.isKeyPressed(LogicalKeyboardKey.zoomIn) ||
          event.isKeyPressed(LogicalKeyboardKey.add)) {
        _zoomIn();
      } else if (event.isKeyPressed(LogicalKeyboardKey.backspace) ||
          event.isKeyPressed(LogicalKeyboardKey.escape)) {
        if (_controller.value.isIdentity()) {
          close();
        } else {
          _restoreToOriginal();
        }
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (_controller.value.isIdentity()) {
      await close();
    } else {
      _restoreToOriginal();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    initializeViewer(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: RawKeyboardListener(
        autofocus: true,
        focusNode: FocusNode(),
        onKey: _onKey,
        child: Scaffold(
          body: InteractiveViewer(
            panEnabled: true,
            scaleEnabled: true,
            minScale: _minScale,
            maxScale: _maxScale,
            transformationController: _controller,
            onInteractionEnd: _onInteractionEnd,
            child: SizedBox.expand(
              child: isInitialized
                  ? GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _onTap,
                      onSecondaryTap: _onTap,
                      child: getMainViewWidget(context),
                    )
                  : getBusyIndicator(),
            ),
          ),
        ),
      ),
    );
  }
}
