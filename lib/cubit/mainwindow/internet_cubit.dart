/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'internet_state.dart';

class InternetCubit extends Cubit<InternetStatus> {
  InternetCubit()
      : super(const InternetStatus(InternetConnectivityStatus.disconnected));

  Future<void> checkConnectivity() async {
    _updateConnectivity(await Connectivity().checkConnectivity());
  }

  void _updateConnectivity(List<ConnectivityResult> results) {
    bool wifi = false;
    bool connected = false;
    for (var i = 0; i < results.length; i++) {
      if (results[i] == ConnectivityResult.wifi ||
          results[i] == ConnectivityResult.ethernet) {
        wifi = true;
      } else if (results[i] != ConnectivityResult.none) {
        connected = true;
        return;
      }
    }
    if (wifi) {
      emit(const InternetStatus(
          InternetConnectivityStatus.connectedWifiOrEthernet));
      return;
    }
    if (connected) {
      emit(InternetStatus(InternetConnectivityStatus.connected));
    } else {
      emit(InternetStatus(InternetConnectivityStatus.disconnected));
    }
  }

  late StreamSubscription<List<ConnectivityResult>> _subscription;

  void trackConnectivityChange() {
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      _updateConnectivity(results);
    });
  }

  void dispose() {
    _subscription.cancel();
  }
}
