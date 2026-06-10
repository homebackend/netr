/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/camera.dart';
import '../../models/location.dart';

part 'thumbnail_state.dart';

class ThumbnailCubit extends Cubit<ThumbnailState> {
  ThumbnailCubit() : super(ThumbnailGeneratorState());

  void generate({Location? location, Camera? camera}) {
    emit((state as ThumbnailGeneratorState).copyWith(
      location: location,
      camera: camera,
    ));
  }
}
