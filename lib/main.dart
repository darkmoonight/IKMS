import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:project_cdis/app/data/schema.dart';
import 'package:project_cdis/app/modules/home/view.dart';
import 'package:project_cdis/utils/theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'utils/theme_controller.dart';

Isar isar = Isar.openSync([
  SettingsSchema,
  UniversitySchema,
  GroupScheduleSchema,
  TeacherScheduleSchema,
  AudienceScheduleSchema,
  ScheduleSchema
], compactOnLaunch: const CompactCondition(minRatio: 2));
late Settings settings;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ByteData data = await rootBundle.load('assets/lets-encrypt-r3.pem');
  SecurityContext context = SecurityContext.defaultContext;
  context.setTrustedCertificatesBytes(data.buffer.asUint8List());
  isarInit();
  settings = isar.settings.where().findFirstSync() ?? Settings();
  runApp(MyApp());
}

void isarInit() {
  if (isar.universitys.countSync() == 0) {
    final DonSTU = University(name: 'ДГТУ');
    isar.writeTxnSync(() => isar.universitys.putSync(DonSTU));
  }
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  final themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 640),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('ru', ''),
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale?.languageCode) {
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },
          debugShowCheckedModeBanner: false,
          themeMode: themeController.theme,
          theme: ThemeApp.lightTheme,
          darkTheme: ThemeApp.darkTheme,
          home: const HomePage(),
        );
      },
    );
  }
}
