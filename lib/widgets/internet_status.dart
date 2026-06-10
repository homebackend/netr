/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/mainwindow/internet_cubit.dart';

class InternetStatusWidget extends StatelessWidget {
  const InternetStatusWidget({super.key});

  @override
  Widget build(Object context) {
    return BlocProvider<InternetCubit>(
      create: (context) => InternetCubit(),
      child: BlocBuilder<InternetCubit, InternetStatus>(
        builder: (context, state) {
          return InternetStatusIcon();
        },
      ),
    );
  }
}

class InternetStatusIcon extends StatefulWidget {
  const InternetStatusIcon({super.key});

  @override
  State<InternetStatusIcon> createState() => _InternetStatusIconState();
}

class _InternetStatusIconState extends State<InternetStatusIcon> {
  late InternetCubit internetCubit;

  @override
  void initState() {
    super.initState();

    internetCubit = context.read<InternetCubit>();
    internetCubit.checkConnectivity();
    internetCubit.trackConnectivityChange();
  }

  @override
  void dispose() {
    internetCubit.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InternetCubit, InternetStatus>(
      builder: (context, state) {
        switch (state.status) {
          case InternetConnectivityStatus.connectedWifiOrEthernet:
            return Icon(
              Icons.wifi,
              color: Colors.green,
            );
          case InternetConnectivityStatus.connected:
            return Icon(
              Icons.four_g_mobiledata,
              color: Colors.green,
            );
          case InternetConnectivityStatus.disconnected:
            return Icon(
              Icons.wifi_off,
              color: Colors.red,
            );
        }
      },
    );
  }
}
