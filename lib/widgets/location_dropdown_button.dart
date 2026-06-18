/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter/material.dart';

class LocationDropdownButton extends StatefulWidget {
  final List<String> locations;
  final ValueChanged<String> onLocationSelected;
  final String initialLocation;

  const LocationDropdownButton({
    super.key,
    required this.locations,
    required this.onLocationSelected,
    this.initialLocation = 'My Location',
  });

  @override
  State<LocationDropdownButton> createState() => _LocationDropdownButtonState();
}

class _LocationDropdownButtonState extends State<LocationDropdownButton> {
  bool _isHovering = false;
  late String _currentTitle;

  @override
  void initState() {
    super.initState();
    _currentTitle = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: "Select Location",
      constraints: const BoxConstraints(maxHeight: 300, maxWidth: 300),
      position: PopupMenuPosition.over,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      offset: const Offset(0, 45),
      splashRadius: 0,
      padding: EdgeInsets.zero,
      onSelected: (String index) {
        final selectedValue = widget.locations[int.parse(index)];
        setState(() {
          _currentTitle = selectedValue;
        });
        widget.onLocationSelected(selectedValue);
      },
      itemBuilder: (BuildContext context) {
        return widget.locations.indexed.map((pair) {
          var (index, location) = pair;
          return PopupMenuItem<String>(
            value: index.toString(),
            child: ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              leading: Icon(Icons.location_pin, color: Colors.blue.shade900),
              title: Text(
                location,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(color: Colors.blue.shade900),
              ),
            ),
          );
        }).toList();
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
          decoration: ShapeDecoration(
            color: _isHovering ? const Color(0xFFF3F0FC) : Colors.white,
            shape: const StadiumBorder(
              side: BorderSide(
                color: Color(0xFFE2DDF3),
                width: 1.0,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.my_location,
                size: 16.0,
                color: Color(0xFF4A3E7D),
              ),
              const SizedBox(width: 8),
              Text(
                _currentTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF4A3E7D),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
