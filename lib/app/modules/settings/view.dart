import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:project_cdis/app/data/schema.dart';
import 'package:project_cdis/app/modules/groups/view.dart';
import 'package:project_cdis/app/modules/university/view.dart';
import 'package:project_cdis/app/widgets/setting_links.dart';
import 'package:project_cdis/main.dart';
import 'package:project_cdis/theme/theme_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final themeController = Get.put(ThemeController());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 15.w),
            child: Text(
              'settings'.tr,
              style: context.theme.textTheme.headline2,
              textAlign: TextAlign.center,
            ),
          ),
          Divider(
            color: context.theme.dividerColor,
            height: 25.w,
            thickness: 2,
            indent: 10.w,
            endIndent: 10.w,
          ),
          SettingLinks(
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
          SettingLinks(
            icon: const Icon(Iconsax.buliding),
            text: 'university'.tr,
            switcher: false,
            description: Text(
              settings.university.value?.name ?? 'no_select'.tr,
              style: context.theme.primaryTextTheme.subtitle2,
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
            description: Text(
              settings.group.value?.name ?? 'no_select'.tr,
              style: context.theme.primaryTextTheme.subtitle2,
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
        ],
      ),
    );
  }
}
