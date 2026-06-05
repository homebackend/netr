/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

abstract class SettingsItem {
  String name;
  
  SettingsItem(this.name);

  Map<String, dynamic> toJson();
  SettingsItem copySelf();
}
