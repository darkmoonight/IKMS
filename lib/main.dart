import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_cdis/app/data/schema.dart';
import 'package:project_cdis/app/modules/home/view.dart';
import 'package:project_cdis/app/modules/onboarding/view.dart';
import 'package:project_cdis/theme/theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'theme/theme_controller.dart';

late Isar isar;
late Settings settings;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ByteData data = await rootBundle.load('assets/lets-encrypt-r3.pem');
  SecurityContext context = SecurityContext.defaultContext;
  context.setTrustedCertificatesBytes(data.buffer.asUint8List());
  await isarInit();
  runApp(MyApp());
}

Future<void> isarInit() async {
  isar = await Isar.open([
    SettingsSchema,
    UniversitySchema,
    GroupScheduleSchema,
    TeacherScheduleSchema,
    AudienceScheduleSchema,
    ScheduleSchema
  ],
      compactOnLaunch: const CompactCondition(minRatio: 2),
      directory: (await getApplicationSupportDirectory()).path);

  settings = await isar.settings.where().findFirst() ?? Settings();

  if (isar.universitys.countSync() == 0) {
    final DonSTU = University(name: 'ДГТУ');
    await isar.writeTxn(() async => await isar.universitys.put(DonSTU));
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
          locale: settings.locale.isNotEmpty ? Locale(settings.locale) : null,
          debugShowCheckedModeBanner: false,
          themeMode: themeController.theme,
          theme: IKMSTheme.lightTheme,
          darkTheme: IKMSTheme.darkTheme,
          home: settings.onboard != 1
              ? const OnboardingScreen()
              : const HomePage(),
          builder: EasyLoading.init(),
        );
      },
    );
  }
}
