/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

part of 'internet_cubit.dart';

enum InternetConnectivityStatus {
  connected,
  connectedWifiOrEthernet,
  disconnected,
}

class InternetStatus {
  final InternetConnectivityStatus status;
  const InternetStatus(this.status);
}
