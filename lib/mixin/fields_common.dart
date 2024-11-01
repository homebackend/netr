/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'package:flutter/material.dart';

mixin FieldsCommon {
  Widget verticalSpacing({double? size = 8.0}) {
    return SizedBox(height: size);
  }

  Widget horizontalSpacing({double? size = 8.0}) {
    return SizedBox(width: size);
  }

  Widget dropDownMenu<T>(
    String title,
    List<T> values,
    T value,
    String Function(T) label,
    void Function(T?) changeHandler,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$title:'),
        InputDecorator(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
            contentPadding: EdgeInsets.all(4.0),
          ),
          child: DropdownButton<T>(
            isExpanded: true,
            elevation: 16,
            borderRadius: BorderRadius.all(Radius.circular(8)),
            value: value,
            items: values.map<DropdownMenuItem<T>>(
              (value) {
                return DropdownMenuItem<T>(
                  value: value,
                  child: Text(label(value)),
                );
              },
            ).toList(),
            onChanged: (value) => changeHandler(value),
          ),
        ),
      ],
    );
  }
}
