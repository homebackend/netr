/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ota_update/ota_update.dart';

import '../../constants.dart' as constants;

part 'app_update_state.dart';

class AppUpdateCubit extends Cubit<AppUpdateStatus> {
  String upgradeFileName = constants.upgradeFileName;

  AppUpdateCubit() : super(AppUpdateStatus(AppUpdateState.userInput));

  Future<void> tryOtaUpdate(String baseUrl) async {
    try {
      OtaUpdate()
          .execute(
        '$baseUrl/$upgradeFileName',
        destinationFilename: upgradeFileName,
      )
          .listen(
        (OtaEvent event) {
          emit(AppUpdateStatus(AppUpdateState.inProgress, event: event));
        },
      );
    } catch (e) {
      emit(AppUpdateStatus(AppUpdateState.error, error: e.toString()));
    }
  }

  void skipUpdate() {
    emit(AppUpdateStatus(AppUpdateState.skipped));
  }
}
