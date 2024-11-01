/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ota_update/ota_update.dart';

import '../app_home.dart';
import '../constants.dart' as constants;
import '../cubit/startup/app_update_cubit.dart';
import '../tool.dart';

class UpdateApp extends StatefulWidget {
  final String url;
  const UpdateApp(this.url, {super.key});

  @override
  State<UpdateApp> createState() => _UpdateAppState();
}

class _UpdateAppState extends State<UpdateApp> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppUpdateCubit(),
      child: BlocBuilder<AppUpdateCubit, AppUpdateStatus>(
        builder: (context, status) {
          switch (status.state) {
            case AppUpdateState.userInput:
              return showUserInput(context);
            case AppUpdateState.inProgress:
              return showProgress(status.event!);
            case AppUpdateState.skipped:
              return AppHome();
            case AppUpdateState.error:
              showSnackBar(context,
                  'Failed to make OTA update. Details: ${status.error!}');
              return AppHome();
          }
        },
      ),
    );
  }

  Widget showUserInput(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(constants.appName),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: const Center(
                child: Text(
                  'A new version of App is available. Kindly update App to latest version.',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                createButton("Yes update", () {
                  context.read<AppUpdateCubit>().tryOtaUpdate(widget.url);
                }),
                SizedBox(width: 8.0),
                createButton("No, may be next time", () {
                  context.read<AppUpdateCubit>().skipUpdate();
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget showProgress(OtaEvent event) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(constants.appName),
        ),
        body: Center(
          child: Text(
              'Update in progress. Current status: ${event.status} : ${event.value}'),
        ),
      ),
    );
  }
}
