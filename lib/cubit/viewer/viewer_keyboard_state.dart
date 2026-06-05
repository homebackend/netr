/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

part of 'viewer_keyboard_cubit.dart';

sealed class ViewerKeyboardState {}

final class ViewerKeyboardInitialState extends ViewerKeyboardState {}

final class ViewerKeyboardTapState extends ViewerKeyboardState {}

enum PlayActions {
  playToggle,
  previous,
  next,
}

final class ViewerKeyboadPlayState extends ViewerKeyboardState {
  final PlayActions playActions;

  ViewerKeyboadPlayState(this.playActions);
}

final class ViewerKeyboardControllerState extends ViewerKeyboardState {
  final Matrix4 controllerValue;

  ViewerKeyboardControllerState(this.controllerValue);
}

final class ViewerKeyboardBackState extends ViewerKeyboardState {}
