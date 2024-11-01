/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

part of 'app_initialization_cubit.dart';

enum AppInitializationState {
  initialization,
  updateApp,
  initialized,
  updateCheckFailed,
}

class AppInitializationStatus {
  final AppInitializationState state;
  String? baseUrl;

  AppInitializationStatus(this.state, {this.baseUrl});
}
