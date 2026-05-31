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
    T? value,
    String Function(T) label,
    void Function(T?) changeHandler, {
    bool showEmptyOption = false,
    String hintText = 'Select an option',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$title:'),
        InputDecorator(
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            contentPadding: EdgeInsets.all(4.0),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T?>(
              isExpanded: true,
              elevation: 16,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              value: value,
              hint: Text(hintText, style: const TextStyle(color: Colors.grey)),
              items: [
                if (showEmptyOption)
                  DropdownMenuItem<T?>(
                    value: null,
                    child: Text('— $hintText —',
                        style: const TextStyle(color: Colors.grey)),
                  ),
                ...values.map((item) {
                  return DropdownMenuItem<T?>(
                    value: item,
                    child: Text(label(item)),
                  );
                }),
              ],
              onChanged: changeHandler,
            ),
          ),
        ),
      ],
    );
  }
}
