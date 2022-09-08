import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../utils/theme_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          children: [
            SizedBox(height: 15.w),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Text(
                AppLocalizations.of(context)!.settings,
                style: theme.textTheme.headline2,
                textAlign: TextAlign.center,
              ),
            ),
            Divider(
              color: theme.dividerColor,
              height: 20.w,
              thickness: 2,
              indent: 10.w,
              endIndent: 10.w,
            ),
            Padding(
              padding: EdgeInsets.only(right: 10.w, left: 10.w, top: 5.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.theme,
                    style: theme.textTheme.headline6,
                  ),
                  IconButton(
                    onPressed: () {
                      if (Get.isDarkMode) {
                        themeController.changeThemeMode(ThemeMode.light);
                        themeController.saveTheme(false);
                      } else {
                        themeController.changeThemeMode(ThemeMode.dark);
                        themeController.saveTheme(true);
                      }
                    },
                    icon: Icon(
                      Icons.brightness_4_outlined,
                      size: theme.iconTheme.size,
                      color: theme.iconTheme.color,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.language,
                    style: theme.textTheme.headline6,
                  ),
                  Text(
                    getLocal(),
                    style: theme.primaryTextTheme.subtitle2,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.group,
                    style: theme.textTheme.headline6,
                  ),
                  Text(
                    "ВПИ42",
                    style: theme.primaryTextTheme.subtitle2,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.university,
                    style: theme.textTheme.headline6,
                  ),
                  Text(
                    "ДГТУ",
                    style: theme.primaryTextTheme.subtitle2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getLocal() {
    Locale locale = Localizations.localeOf(context);
    final String myLocal;
    if (locale.toString() == "ru") {
      myLocal = "Русский";
    } else {
      myLocal = "English";
    }
    return myLocal;
  }
}
