/*
 * Copyright (c) 2026 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter/material.dart';

class DateTimePicker {
  static Future<DateTime?> pickDateTime(
    BuildContext context, {
    DateTime? now,
    required DateTime firstDate,
    required DateTime lastDate,
    required String helpText,
  }) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: helpText,
      builder: (context, child) {
        return Theme(data: Theme.of(context), child: child!);
      },
    );

    if (pickedDate == null) return null; // User cancelled the interaction

    if (!context.mounted) return null;
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Select Stream Time',
    );

    if (pickedTime == null) return null;

    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }
}
