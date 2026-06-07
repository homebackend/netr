/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:netr/helpers/thumbnail_manager.dart';

class ThumbnailWidget extends StatelessWidget {
  final String locationName;
  final String cameraName;

  const ThumbnailWidget(this.locationName, this.cameraName, {super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: ThumbnailManager.getThumbnailFilePath(locationName, cameraName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const _PlaceholderView(message: "Path error");
        }

        final String filePath = snapshot.data!;
        final File imageFile = File(filePath);

        if (!imageFile.existsSync()) {
          return const _PlaceholderView(message: "No snapshot yet");
        }

        return Image.file(
          imageFile,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return const _PlaceholderView(message: "Corrupted image");
          },
        );
      },
    );
  }
}

class _PlaceholderView extends StatelessWidget {
  final String message;
  const _PlaceholderView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900], // Dark background typical for CCTV layouts
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_off, color: Colors.grey, size: 32),
            const SizedBox(height: 4),
            Text(
              message,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
