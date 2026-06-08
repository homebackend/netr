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

class AppUpdateDialog extends StatelessWidget {
  final String? downloadUrl;
  final String? latestVersion;
  final String? changeLog;
  final VoidCallback? onProceed;
  final VoidCallback? onDismiss;

  const AppUpdateDialog({
    super.key,
    required this.downloadUrl,
    required this.latestVersion,
    required this.changeLog,
    this.onProceed,
    this.onDismiss,
  });

  Future<void> _launchDownloadUrl() async {
    if (downloadUrl == null || downloadUrl!.isEmpty) {
      log('Cannot launch download: URL is empty');
      return;
    }

    final Uri url = Uri.parse(downloadUrl!);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch browser context for: $downloadUrl';
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
              'Latest Version: ${latestVersion ?? "Unknown"}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            if (downloadUrl != null) ...[
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
                    changeLog ?? 'No direct commit information provided.',
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
        if (onDismiss != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDismiss!();
            },
            child: const Text('Dismiss'),
          ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (onProceed != null) onProceed!();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(onProceed == null ? 'OK' : 'Install Update'),
        ),
      ],
    );
  }
}
