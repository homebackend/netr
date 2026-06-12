/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter/material.dart';

class StreamQualitySelector extends StatefulWidget {
  final bool value;
  final void Function(bool value) onToggle;
  const StreamQualitySelector(
      {required this.value, required this.onToggle, super.key});

  @override
  State<StreamQualitySelector> createState() => _StreamQualitySelectorState();
}

class _StreamQualitySelectorState extends State<StreamQualitySelector> {
  bool _isHighQuality = false;
  bool _isHovered = false;

  static const Color purpleThemeColor = Color(0xFF4A3E7D);

  @override
  void initState() {
    setState(() {
      _isHighQuality = widget.value;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _isHighQuality = !_isHighQuality;
          });
          widget.onToggle(_isHighQuality);
        },
        onHover: (hovering) {
          setState(() {
            _isHovered = hovering;
          });
        },
        customBorder: const StadiumBorder(),
        splashColor: const Color(0xFFE2DDF3).withValues(alpha: 0.2),
        highlightColor: Colors.transparent,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
          decoration: ShapeDecoration(
            color: _isHovered ? const Color(0xFFF3F0FC) : Colors.white,
            shape: const StadiumBorder(
              side: BorderSide(
                color: Color(0xFFE2DDF3),
                width: 1.0,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.video_settings,
                size: 16.0,
                color: purpleThemeColor,
              ),
              const SizedBox(width: 6.0),
              const Text(
                'Stream Quality ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: purpleThemeColor,
                ),
              ),
              const Text(
                'Low ',
                style: TextStyle(
                  color: purpleThemeColor,
                  fontSize: 13,
                ),
              ),
              IgnorePointer(
                child: SizedBox(
                  height: 24.0,
                  child: Switch(
                    value: _isHighQuality,
                    onChanged: (_) {},
                    activeThumbColor: const Color(0xFF4CAF50),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
              const Text(
                ' High',
                style: TextStyle(
                  color: purpleThemeColor,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
