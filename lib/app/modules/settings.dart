import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ikms/app/data/schema.dart';
import 'package:ikms/app/modules/groups.dart';
import 'package:ikms/app/modules/university.dart';
import 'package:ikms/app/widgets/setting_card.dart';
import 'package:ikms/main.dart';
import 'package:ikms/theme/theme_controller.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final themeController = Get.put(ThemeController());
  String? appVersion;

  Future<void> infoVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
    });
  }

  @override
  void initState() {
    infoVersion();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Text(
              'settings'.tr,
              style: context.theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Divider(
            height: 25,
            thickness: 2,
            indent: 10,
            endIndent: 10,
          ),
          SettingCard(
            icon: const Icon(Iconsax.moon),
            text: 'theme'.tr,
            switcher: true,
            value: Get.isDarkMode,
            onChange: (_) {
              if (Get.isDarkMode) {
                themeController.changeThemeMode(ThemeMode.light);
                themeController.saveTheme(false);
              } else {
                themeController.changeThemeMode(ThemeMode.dark);
                themeController.saveTheme(true);
              }
            },
          ),
          SettingCard(
            icon: const Icon(Iconsax.buildings),
            text: 'university'.tr,
            info: true,
            infoSettings: true,
            textInfo: settings.university.value?.name ?? 'no_select'.tr,
            onPressed: () async {
              University? selectionData = await Get.to(
                  () => const UniversityPage(),
                  transition: Transition.downToUp);
              if (selectionData != null) {
                settings.university.value = selectionData;
                await isar.writeTxn(() async {
                  await isar.settings.put(settings);
                  await settings.university.save();
                });
                setState(() {});
              }
            },
          ),
          SettingCard(
            icon: const Icon(Iconsax.people),
            text: 'group'.tr,
            info: true,
            infoSettings: true,
            textInfo: settings.group.value?.name ?? 'no_select'.tr,
            onPressed: settings.university.value != null
                ? () async {
                    GroupSchedule? selectionData = await Get.to(
                        () => const GroupsPage(
                              isSettings: true,
                            ),
                        transition: Transition.downToUp);
                    if (selectionData != null) {
                      selectionData.university.value =
                          settings.university.value;
                      settings.group.value = selectionData;

                      await isar.writeTxn(() async {
                        await isar.groupSchedules.put(selectionData);
                        await selectionData.university.save();
                        await isar.settings.put(settings);
                        await settings.group.save();
                      });
                      setState(() {});
                    }
                  }
                : () => EasyLoading.showInfo('no_university'.tr),
          ),
          SettingCard(
            icon: const Icon(Iconsax.code_circle),
            text: 'version'.tr,
            info: true,
            textInfo: '$appVersion',
          ),
        ],
      ),
    );
  }
}
