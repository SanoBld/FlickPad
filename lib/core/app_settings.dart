import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Holds and persists user-configurable app settings
class AppSettings extends ChangeNotifier {
  bool useDynamicColor = true;
  Color accentColor = Colors.deepPurple;
  bool notificationsEnabled = true;
  bool dataSaverEnabled = false;
  String region = 'FR';
  String language = 'fr';

  static const _kDynamicColor = 'use_dynamic_color';
  static const _kAccent = 'accent_color';
  static const _kNotif = 'notifications_enabled';
  static const _kDataSaver = 'data_saver_enabled';
  static const _kRegion = 'region';
  static const _kLanguage = 'language';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    useDynamicColor = prefs.getBool(_kDynamicColor) ?? true;
    accentColor = Color(prefs.getInt(_kAccent) ?? Colors.deepPurple.toARGB32());
    notificationsEnabled = prefs.getBool(_kNotif) ?? true;
    dataSaverEnabled = prefs.getBool(_kDataSaver) ?? false;
    region = prefs.getString(_kRegion) ?? 'FR';
    language = prefs.getString(_kLanguage) ?? 'fr';
    notifyListeners();
  }

  Future<void> setDynamicColor(bool value) async {
    useDynamicColor = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDynamicColor, value);
  }

  Future<void> setAccentColor(Color color) async {
    accentColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kAccent, color.toARGB32());
  }

  Future<void> setNotifications(bool value) async {
    notificationsEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotif, value);
  }

  Future<void> setDataSaver(bool value) async {
    dataSaverEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDataSaver, value);
  }

  Future<void> setRegion(String value) async {
    region = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kRegion, value);
  }

  Future<void> setLanguage(String value) async {
    language = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLanguage, value);
  }
}
