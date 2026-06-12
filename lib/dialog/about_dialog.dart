/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart' as constants;

class AboutAppDialog extends StatelessWidget {
  const AboutAppDialog({super.key});

  void _shareLatestAppInstallation(BuildContext context) {
    final String installationInstructions =
        '📥 Install Netr App (Latest Version)\n\n'
        'Download Link:\n'
        'https://github.com/${constants.githubOrganization}/${constants.githubRepo}/releases\n\n'
        '🤖 Android Installation Instructions:\n'
        '1. Tap the link above to view the newest release.\n'
        '2. Scroll down to "Assets" and download the .apk file.\n'
        '3. Open the file. If blocked, tap "Settings" -> "Allow from this source".\n'
        '4. If Play Protect flags it, select "More details" -> "Install anyway".\n\n'
        '💻 Desktop Installation:\n'
        '• Expand "Assets" and download the matching installer for your desktop OS.';

    final RenderBox? box = context.findRenderObject() as RenderBox?;
    final Rect? sharePositionOrigin =
        box != null ? (box.localToGlobal(Offset.zero) & box.size) : null;

    SharePlus.instance.share(ShareParams(
      text: installationInstructions,
      subject: 'Netr App - Download Latest Release',
      sharePositionOrigin: sharePositionOrigin,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dialogWidth = screenWidth > 600 ? 450 : screenWidth * 0.85;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      content: SizedBox(
        width: dialogWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Image.asset(
                    constants.appEyeIcon,
                    height: 80,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Netr',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  FutureBuilder<String>(
                    future: () async {
                      final packageInfo = await PackageInfo.fromPlatform();
                      return packageInfo.version.toString();
                    }(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LinearProgressIndicator();
                      }
                      if (snapshot.hasData) {
                        return Text(
                          'Version: ${snapshot.data}',
                          style: TextStyle(color: Colors.grey),
                        );
                      }
                      return const Text('Failed to load version');
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.blue),
              title: const Text('Share App Link & Instructions'),
              subtitle: const Text(
                  'Send download guides to other mobile or desktop devices'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _shareLatestAppInstallation(context),
            ),
            ListTile(
              leading: const Icon(Icons.code, color: Colors.purple),
              title: const Text('View Source Code'),
              subtitle: const Text(
                'github.com/${constants.githubOrganization}/${constants.githubRepo}',
              ),
              trailing: const Icon(Icons.open_in_new),
              onTap: () async {
                final Uri url = Uri.parse(
                  'https://github.com/${constants.githubOrganization}/${constants.githubRepo}/',
                );
                try {
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    throw 'Could not launch browser context';
                  }
                } catch (e) {
                  log('URL redirection failure: $e');
                }
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Netr is a cross-platform application designed to monitor CCTV '
                'cameras securely over both local networks (Intranet) and '
                'remote connections (Internet via SSH tunneling). Built for '
                'Mobile, Android TV, FireStick, and Desktop environments. '
                'Thank you for supporting this project!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
                const SizedBox(width: 8),
              ],
            )
          ],
        ),
      ),
    );
  }
}
