/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'constants.dart' as constants;
import 'models/app_info.dart';
import 'pages/splash.dart';
import 'tool.dart';
import 'pages/update_app.dart';

class CheckUpdate extends StatelessWidget {
  const CheckUpdate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _startupTasks(context),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashScreen();
        } else {
          String url = snapshot.data[0];
          return UpdateApp(url);
        }
      },
    );
  }

  Future<List> _startupTasks(BuildContext context) {
    return Future.wait([
      checkUpdateRequired(context),
    ]);
  }

  Future<String> checkUpdateRequired(BuildContext context) async {
    try {
      bool error = true;
      final currentInfo = await PackageInfo.fromPlatform();
      log('Current App version: ${currentInfo.buildNumber}');
      List<String> baseUrls = constants.upgradeBaseUrls;
      for (String baseUrl in baseUrls) {
        String contents;
        try {
          contents = await http.read(Uri.parse('$baseUrl/info.json'));
          error = false;
        } catch (e) {
          log('Error accessing update data: $e');
          continue;
        }
        final AppInfo appInfo = AppInfo.fromJson(jsonDecode(contents));
        log('Available App version: ${appInfo.version}');

        if (int.parse(currentInfo.buildNumber) < int.parse(appInfo.version)) {
          return baseUrl;
        }

        break;
      }

      if (error) {
        throw Exception('Unable to get update data');
      }
    } catch (e) {
      showSnackBar(
        context,
        'Unable to check for App update. Will retry later.',
      );
    }

    return '';
  }
}
