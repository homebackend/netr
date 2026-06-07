/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vector_math/vector_math_64.dart' as vm64;

part 'viewer_keyboard_state.dart';

class ViewerKeyboardCubit extends Cubit<ViewerKeyboardState> {
  static const double _drag = 8.0;
  static const double minDeltaAllowed = 1.0e-5;
  static const double minScale = 1.0;
  static const double maxScale = 8.0;
  static const double scaleFactor = 1.3034;
  static const double translationStep = 10;

  Matrix4 controllerValue;
  double maxWidth;
  double maxHeight;

  ViewerKeyboardCubit(
    this.controllerValue,
    this.maxWidth,
    this.maxHeight,
  ) : super(ViewerKeyboardInitialState());

  void updateControllerValue(Matrix4 value) {
    controllerValue = value;
  }

  void updateMaxWidth(double maxWidth) {
    this.maxWidth = maxWidth;
  }

  void updateMaxHeight(double maxHeight) {
    this.maxHeight = maxHeight;
  }

  void zoomIn() {
    double scale = controllerValue.getMaxScaleOnAxis();
    if (scale * scaleFactor < maxScale) {
      _scaleAndCenter(scaleFactor);
    } else {
      _scaleAndCenter(maxScale / scale);
    }

    emit(ViewerKeyboardControllerState(controllerValue));
  }

  void zoomOut() {
    double scale = controllerValue.getMaxScaleOnAxis();
    if (scale / scaleFactor > minScale) {
      _scaleAndCenter(1 / scaleFactor);
    } else {
      _scaleAndCenter(minScale / scale);
    }

    emit(ViewerKeyboardControllerState(controllerValue));
  }

  void _scaleAndCenter(double scaleFactor) {
    Matrix4 value = Matrix4.copy(controllerValue)
      ..scaleByDouble(
        scaleFactor,
        scaleFactor,
        scaleFactor,
        1.0,
      );
    double scale = value.getMaxScaleOnAxis();
    maxWidth *= scale - 1;
    maxHeight *= scale - 1;
    value.setTranslationRaw(-maxWidth / 2, -maxHeight / 2, 0);
    controllerValue = value;
  }

  void _translate(bool left, bool right, bool up, bool down) {
    double scale = controllerValue.getMaxScaleOnAxis();
    maxWidth *= scale - 1;
    maxHeight *= scale - 1;
    Matrix4 value = Matrix4.copy(controllerValue);
    vm64.Vector3 translation = value.getTranslation();
    double x = translation.x;
    double y = translation.y;

    double low(l) {
      if (-(l + translationStep) > 0) {
        return translationStep;
      } else if (-l > 0) {
        return -l;
      } else {
        return 0;
      }
    }

    double high(h, max) {
      if (-(h + translationStep) < max) {
        return translationStep;
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
    controllerValue = value;
  }

  bool handleKeyPress(KeyEvent event) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.f11:
        case LogicalKeyboardKey.keyF:
          emit(ViewerKeyboardFullscreenState());
          break;
        case LogicalKeyboardKey.select:
        case LogicalKeyboardKey.contextMenu:
          emit(ViewerKeyboardTapState());
          break;
        case LogicalKeyboardKey.enter:
          if (HardwareKeyboard.instance.isAltPressed) {
            emit(ViewerKeyboardFullscreenState());
          } else {
            emit(ViewerKeyboardTapState());
          }
          break;
        case LogicalKeyboardKey.space:
        case LogicalKeyboardKey.mediaPlay:
        case LogicalKeyboardKey.mediaPlayPause:
        case LogicalKeyboardKey.mediaPause:
        case LogicalKeyboardKey.keyP:
          emit(ViewerKeyboardPlayState(PlayActions.playToggle));
          break;
        case LogicalKeyboardKey.zoomIn:
        case LogicalKeyboardKey.add:
        case LogicalKeyboardKey.mediaFastForward:
          zoomIn();
          break;
        case LogicalKeyboardKey.zoomOut:
        case LogicalKeyboardKey.minus:
        case LogicalKeyboardKey.mediaRewind:
          zoomOut();
          break;
        case LogicalKeyboardKey.arrowLeft:
          if (controllerValue.isIdentity()) {
            emit(ViewerKeyboardPlayState(PlayActions.previous));
          } else {
            _translate(true, false, false, false);
            emit(ViewerKeyboardControllerState(controllerValue));
          }
          break;
        case LogicalKeyboardKey.arrowRight:
          if (controllerValue.isIdentity()) {
            emit(ViewerKeyboardPlayState(PlayActions.next));
          } else {
            _translate(false, true, false, false);
            emit(ViewerKeyboardControllerState(controllerValue));
          }
          break;
        case LogicalKeyboardKey.arrowUp:
          if (!controllerValue.isIdentity()) {
            _translate(false, false, true, false);
            emit(ViewerKeyboardControllerState(controllerValue));
          } else {
            return false;
          }
          break;
        case LogicalKeyboardKey.arrowDown:
          if (!controllerValue.isIdentity()) {
            _translate(false, false, false, true);
            emit(ViewerKeyboardControllerState(controllerValue));
          } else {
            return false;
          }
          break;
        case LogicalKeyboardKey.backspace:
        case LogicalKeyboardKey.escape:
          if (controllerValue.isIdentity()) {
            emit(ViewerKeyboardBackState());
          } else {
            controllerValue = Matrix4.identity();
            emit(ViewerKeyboardControllerState(controllerValue));
          }
          break;
        default:
          return false;
      }

      return true;
    }

    return false;
  }

  bool _valueCloseToZero(double value) => value.abs() < minDeltaAllowed;

  bool _isNotZoomedAndNotTranslated(Matrix4 value) {
    vm64.Vector3 translation = value.getTranslation();
    return _valueCloseToZero(value.getMaxScaleOnAxis() - 1.0) &&
        _valueCloseToZero(translation.x) &&
        _valueCloseToZero(translation.y) &&
        _valueCloseToZero(translation.z);
  }

  void handleInteractionEnd(ScaleEndDetails details) {
    if (_isNotZoomedAndNotTranslated(controllerValue)) {
      if (details.pointerCount == 0) {
        if (details.velocity.pixelsPerSecond.dx > _drag) {
          emit(ViewerKeyboardPlayState(PlayActions.previous));
        }
        if (details.velocity.pixelsPerSecond.dx < -_drag) {
          emit(ViewerKeyboardPlayState(PlayActions.next));
        }
      }
    }
  }
}
