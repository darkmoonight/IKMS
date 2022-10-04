import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:project_cdis/main.dart';

class ThemeController extends GetxController {

  ThemeMode get theme => _loadTheme() ? ThemeMode.dark : ThemeMode.light;

  bool _loadTheme() => objectbox.settings.theme ?? false;

  void saveTheme(bool isDarkMode) {
    objectbox.settings.theme = isDarkMode;
    objectbox.settingsBox.put(objectbox.settings);
  }

  void changeTheme(ThemeData theme) => Get.changeTheme(theme);

  void changeThemeMode(ThemeMode themeMode) => Get.changeThemeMode(themeMode);
}
