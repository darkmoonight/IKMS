import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ikms/app/data/schema.dart';
import 'package:ikms/app/modules/groups.dart';
import 'package:ikms/app/modules/university.dart';
import 'package:ikms/app/widgets/setting_links.dart';
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
          Divider(
            color: context.theme.dividerColor,
            height: 25,
            thickness: 2,
            indent: 10,
            endIndent: 10,
          ),
          SettingLinks(
            icon: const Icon(Iconsax.moon),
            text: 'theme'.tr,
            switcher: true,
            info: false,
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
          SettingLinks(
            icon: const Icon(Iconsax.buildings),
            text: 'university'.tr,
            switcher: false,
            info: false,
            description: Text(
              settings.university.value?.name ?? 'no_select'.tr,
              style: context.theme.textTheme.bodySmall,
            ),
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
          SettingLinks(
            icon: const Icon(Iconsax.people),
            text: 'group'.tr,
            switcher: false,
            info: false,
            description: Text(
              settings.group.value?.name ?? 'no_select'.tr,
              style: context.theme.textTheme.bodySmall,
            ),
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
          SettingLinks(
            icon: Icon(
              Iconsax.code_circle,
              color: context.theme.iconTheme.color,
            ),
            text: 'version'.tr,
            switcher: false,
            info: true,
            textInfo: '$appVersion',
          ),
        ],
      ),
    );
  }
}
