import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ThemeController extends GetxController {

  ThemeMode get theme => _loadTheme() ? ThemeMode.dark : ThemeMode.light;

  // TODO: wrap with settings save
  bool _loadTheme() => false;

  void saveTheme(bool isDarkMode) {
    // TODO: wrap with settings save
  }

  void changeTheme(ThemeData theme) => Get.changeTheme(theme);

  void changeThemeMode(ThemeMode themeMode) => Get.changeThemeMode(themeMode);
}
