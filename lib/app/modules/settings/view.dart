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
    Locale myLocale = Localizations.localeOf(context);
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
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.theme,
                    style: theme.textTheme.headline3,
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
              padding: EdgeInsets.only(
                  left: 10.w, top: 5.w, bottom: 5.w, right: 15.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Язык',
                    style: theme.textTheme.headline3,
                  ),
                  Text(
                    "$myLocale",
                    style: theme.textTheme.headline3,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
