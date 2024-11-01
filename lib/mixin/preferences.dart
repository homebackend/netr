/*
 * Copyright (c) 2024 Neeraj Jakhar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import 'dart:convert';
import 'dart:developer';

import 'package:netr/models/settings_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

mixin Preferences {
  static const String keyCameras = 'cameras';
  static const String keyCredentials = 'credentials';
  static const String keyEncryptionIV = 'encryptionIV';
  static const String keyLastUsedDirectory = 'lastUsedDirectory';
  static const String keyLocations = 'locations';
  static const String keyNvrs = 'nvrs';
  static const String keyUseDarkTheme = 'useDarkTheme';

  Future<List<T>> loadItems<T extends SettingsItem>(
      String keyItems, T Function(Map<String, dynamic>) itemFromMap,
      {List<T>? items}) async {
    items ??= [];

    items.clear();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> array = prefs.getStringList(keyItems) ?? [];
      for (int i = 0; i < array.length; i++) {
        Map<String, dynamic> map = jsonDecode(array[i]);
        items.add(itemFromMap(map));
      }
    } catch (e) {
      log('Failed to read $keyItems: $e');
    }

    return items;
  }

  Future<void> saveItems<T extends SettingsItem>(
    String keyItems,
    List<T> items,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> array = items.map((location) {
      return jsonEncode(location.toJson());
    }).toList();
    await prefs.setStringList(keyItems, array);
  }

  Future<String?> loadString(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> saveString(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  Future<bool?> loadBool(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  Future<void> saveBool(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  Future<List<String>> loadStringList(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key) ?? <String>[];
  }

  Future<void> saveStringList(String key, List<String> values) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(key, values);
  }

  Future<T> loadEnum<T extends Enum>(String key, List<T> possibleValues) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return possibleValues[prefs.getInt(key) ?? 0];
  }

  Future<void> saveEnum<T extends Enum>(String key, T value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, value.index);
  }

  void setPref(Map<String, dynamic> prefsMap, String key, var value) {
    if (value != null) {
      prefsMap[key] = value;
    }
  }

  Future<String?> getDefaultDirectory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyLastUsedDirectory);
  }

  Future<void> setDefaultDirectory(String lastUsedDirectory) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyLastUsedDirectory, lastUsedDirectory);
  }

  Future<String> getAllPreferencesAsString() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> prefsMap = {};
      setPref(prefsMap, keyCameras, prefs.getStringList(keyCameras));
      setPref(prefsMap, keyCredentials, prefs.getStringList(keyCredentials));
      setPref(prefsMap, keyEncryptionIV, prefs.getString(keyEncryptionIV));
      setPref(prefsMap, keyLastUsedDirectory,
          prefs.getString(keyLastUsedDirectory));
      setPref(prefsMap, keyLocations, prefs.getStringList(keyLocations));
      setPref(prefsMap, keyNvrs, prefs.getStringList(keyNvrs));
      setPref(prefsMap, keyUseDarkTheme, prefs.getBool(keyUseDarkTheme));
      return jsonEncode(prefsMap);
    } catch (e) {
      log('Error getting all preferences: $e');
      return '';
    }
  }

  Future<void> setAllPreferencesFromString(String prefsJson) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Map<String, dynamic> prefsMap = jsonDecode(prefsJson);
      for (String key in prefsMap.keys) {
        var value = prefsMap[key];
        switch (key) {
          case keyUseDarkTheme:
            await prefs.setBool(key, value);
            break;
          case keyEncryptionIV:
          case keyLastUsedDirectory:
            await prefs.setString(key, value);
            break;
          case keyCameras:
          case keyCredentials:
          case keyLocations:
          case keyNvrs:
            await prefs.setStringList(key, List<String>.from(value));
            break;
        }
      }
    } catch (e) {
      log('Error during setting preferences: $e');
    }
  }
}
