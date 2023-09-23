import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ikms/app/data/schema.dart';
import 'package:ikms/main.dart';

class ThemeController extends GetxController {
  ThemeMode get theme => settings.theme == null
      ? ThemeMode.system
      : settings.theme == true
          ? ThemeMode.dark
          : ThemeMode.light;

  void saveOledTheme(bool isOled) {
    settings.amoledTheme = isOled;
    isar.writeTxnSync(() => isar.settings.putSync(settings));
  }

  void saveMaterialTheme(bool isMaterial) {
    settings.materialColor = isMaterial;
    isar.writeTxnSync(() => isar.settings.putSync(settings));
  }

  void saveTheme(bool isDarkMode) {
    settings.theme = isDarkMode;
    isar.writeTxnSync(() => isar.settings.putSync(settings));
  }

  void changeTheme(ThemeData theme) => Get.changeTheme(theme);

  void changeThemeMode(ThemeMode themeMode) => Get.changeThemeMode(themeMode);
}
