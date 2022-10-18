import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:project_cdis/app/data/schema.dart';
import 'package:project_cdis/main.dart';

class ThemeController extends GetxController {
  final _settings = isar.settings.where().findFirstSync()!;

  ThemeMode get theme => _settings.theme ? ThemeMode.dark : ThemeMode.light;

  void saveTheme(bool isDarkMode) async {
    _settings.theme = isDarkMode;
    isar.writeTxn(() async => isar.settings.put(_settings));
  }

  void changeTheme(ThemeData theme) => Get.changeTheme(theme);

  void changeThemeMode(ThemeMode themeMode) => Get.changeThemeMode(themeMode);
}
