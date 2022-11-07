import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:project_cdis/app/data/schema.dart';
import 'package:project_cdis/app/modules/groups/view.dart';
import 'package:project_cdis/app/modules/university/view.dart';
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
            height: 20.w,
            thickness: 2,
            indent: 10.w,
            endIndent: 10.w,
          ),
          const SizedBox(height: 5),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'theme'.tr,
                  style: context.theme.primaryTextTheme.headline5,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(context.theme.primaryColor),
                    minimumSize: MaterialStateProperty.all(const Size(110, 40)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  onPressed: () {
                    if (Get.isDarkMode) {
                      themeController.changeThemeMode(ThemeMode.light);
                      themeController.saveTheme(false);
                    } else {
                      themeController.changeThemeMode(ThemeMode.dark);
                      themeController.saveTheme(true);
                    }
                  },
                  child: Text(
                    getTheme(),
                    style: context.theme.primaryTextTheme.subtitle2,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.w),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'university'.tr,
                  style: context.theme.primaryTextTheme.headline5,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(context.theme.primaryColor),
                    minimumSize: MaterialStateProperty.all(const Size(110, 40)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
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
                  child: Text(
                    settings.university.value?.name ?? 'no_university'.tr,
                    style: context.theme.primaryTextTheme.subtitle2,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.w),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'group'.tr,
                  style: context.theme.primaryTextTheme.headline5,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(context.theme.primaryColor),
                    minimumSize: MaterialStateProperty.all(const Size(110, 40)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
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
                  child: Text(
                    settings.group.value?.name ?? 'no_group'.tr,
                    style: context.theme.primaryTextTheme.subtitle2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getTheme() {
    final String myTheme;
    if (Get.isDarkMode) {
      myTheme = 'light'.tr;
    } else {
      myTheme = 'dark'.tr;
    }
    return myTheme;
  }
}
