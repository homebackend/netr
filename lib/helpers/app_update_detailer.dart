/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../cubit/startup/app_initialization_cubit.dart';

class AppUpdateDialog extends StatelessWidget {
  final AppInitializationStatus status;
  final VoidCallback onProceed;

  const AppUpdateDialog({
    super.key,
    required this.status,
    required this.onProceed,
  });

  Future<void> _launchDownloadUrl() async {
    final String? targetUrl = status.downloadUrl;
    if (targetUrl == null || targetUrl.isEmpty) {
      log('Cannot launch download: URL is empty');
      return;
    }

    final Uri url = Uri.parse(targetUrl);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch browser context for: $targetUrl';
      }
    } catch (e) {
      log('URL redirection failure: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.system_update_alt, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          const Text('New Update Available'),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Latest Version: ${status.latestVersion ?? "Unknown"}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),

            if (status.downloadUrl != null) ...[
              GestureDetector(
                onTap: _launchDownloadUrl,
                child: Text(
                  'Download Package Link 🔗',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            const Divider(),
            const SizedBox(height: 8),

            // Changes Header
            Text(
              'Changelog / Commits:',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    status.changeLog ??
                        'No direct commit information provided.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Dismiss'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(); // Dismiss the dialog frame
            onProceed(); // Execute the success action mapping loop
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
