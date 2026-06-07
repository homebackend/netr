/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

part of 'thumbnail_cubit.dart';

@immutable
sealed class ThumbnailState {}

final class ThumbnailGeneratorState extends ThumbnailState {
  final Camera? camera;
  final Location? location;

  ThumbnailGeneratorState({this.location, this.camera});

  ThumbnailGeneratorState copyWith({Location? location, Camera? camera}) {
    return ThumbnailGeneratorState(
      location: location ?? this.location,
      camera: camera ?? this.camera,
    );
  }
}
