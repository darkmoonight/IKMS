import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:project_cdis/app/modules/groups/view.dart';
import 'package:project_cdis/app/modules/university/view.dart';
import 'package:project_cdis/app/widgets/selection_list.dart';
import 'package:project_cdis/utils/theme_controller.dart';

class SettingsPage extends StatefulWidget {
  final Function(SelectionData) onGroupSelected;

  const SettingsPage({super.key, required this.onGroupSelected});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final themeController = Get.put(ThemeController());

  // TODO: finish this change
  SelectionData? group;
  SelectionData? university;

  @override
  Widget build(BuildContext context) {
    Locale locale = Localizations.localeOf(context);
    return SafeArea(
      child: ListView(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 15.w),
            child: Text(
              AppLocalizations.of(context)!.settings,
              style: Theme.of(context).textTheme.headline2,
              textAlign: TextAlign.center,
            ),
          ),
          Divider(
            color: Theme.of(context).dividerColor,
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
                  AppLocalizations.of(context)!.theme,
                  style: Theme.of(context).primaryTextTheme.headline5,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).primaryColor),
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
                    style: Theme.of(context).primaryTextTheme.subtitle2,
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
                  AppLocalizations.of(context)!.language,
                  style: Theme.of(context).primaryTextTheme.headline5,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).primaryColor),
                    minimumSize: MaterialStateProperty.all(const Size(110, 40)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  onPressed: () {
                    if (locale.toString() == 'ru') {
                      Locale locale = const Locale('en');
                      Get.updateLocale(locale);
                    } else {
                      Locale locale = const Locale('ru');
                      Get.updateLocale(locale);
                    }
                  },
                  child: Text(
                    getLocal(),
                    style: Theme.of(context).primaryTextTheme.subtitle2,
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
                  AppLocalizations.of(context)!.group,
                  style: Theme.of(context).primaryTextTheme.headline5,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).primaryColor),
                    minimumSize: MaterialStateProperty.all(const Size(110, 40)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    SelectionData? selectionData = await Get.to(
                        () => const GroupsPage(),
                        transition: Transition.downToUp);
                    if (selectionData != null) {
                      widget.onGroupSelected(selectionData);
                      setState(() {
                        group = selectionData;
                      });
                    }
                  },
                  child: Text(
                    group?.name ?? 'Группа не выбрана',
                    style: Theme.of(context).primaryTextTheme.subtitle2,
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
                  AppLocalizations.of(context)!.university,
                  style: Theme.of(context).primaryTextTheme.headline5,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).primaryColor),
                    minimumSize: MaterialStateProperty.all(const Size(110, 40)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    SelectionData? selectionData = await Get.to(
                        () => const UniversityPage(),
                        transition: Transition.downToUp);
                    if (selectionData != null) {
                      setState(() {
                        university = selectionData;
                      });
                    }
                  },
                  child: Text(
                    university?.name ?? 'Университет не выбран',
                    style: Theme.of(context).primaryTextTheme.subtitle2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getLocal() {
    Locale locale = Localizations.localeOf(context);
    final String myLocal;
    if (locale.toString() == "ru") {
      myLocal = "English";
    } else {
      myLocal = "Русский";
    }
    return myLocal;
  }

  String getTheme() {
    final String myTheme;
    if (Get.isDarkMode) {
      myTheme = AppLocalizations.of(context)!.light;
    } else {
      myTheme = AppLocalizations.of(context)!.dark;
    }
    return myTheme;
  }
}
