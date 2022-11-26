import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_cdis/app/data/schema.dart';
import 'package:project_cdis/app/modules/home/view.dart';
import 'package:project_cdis/app/modules/onboarding/view.dart';
import 'package:project_cdis/l10n/translation.dart';
import 'package:project_cdis/theme/theme.dart';
import 'package:project_cdis/theme/theme_controller.dart';

late Isar isar;
late Settings settings;
late University donstu;
final ValueNotifier<Future<bool>> isDeviceConnectedNotifier =
    ValueNotifier(InternetConnectionChecker().hasConnection);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ByteData data = await rootBundle.load('assets/lets-encrypt-r3.pem');
  SecurityContext context = SecurityContext.defaultContext;
  context.setTrustedCertificatesBytes(data.buffer.asUint8List());
  await isarInit();
  Connectivity()
      .onConnectivityChanged
      .listen((ConnectivityResult result) async {
    if (result != ConnectivityResult.none) {
      isDeviceConnectedNotifier.value =
          InternetConnectionChecker().hasConnection;
    } else {
      isDeviceConnectedNotifier.value = Future(() => false);
    }
  });
  runApp(MyApp());
}

Future<void> isarInit() async {
  isar = await Isar.open([
    SettingsSchema,
    UniversitySchema,
    GroupScheduleSchema,
    TeacherScheduleSchema,
    AudienceScheduleSchema,
  ],
      compactOnLaunch: const CompactCondition(minRatio: 2),
      directory: (await getApplicationSupportDirectory()).path);

  settings = await isar.settings.where().findFirst() ?? Settings();
  donstu = await isar.universitys.get(1) ?? University(id: 1, name: 'ДГТУ');

  if (await isar.settings.count() == 0) {
    await isar.writeTxn(() async => await isar.settings.put(settings));
  }

  if (await isar.universitys.count() == 0) {
    await isar.writeTxn(() async => await isar.universitys.put(donstu));
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
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          translations: Translation(),
          locale: Get.deviceLocale,
          fallbackLocale: const Locale('en', 'US'),
          supportedLocales: const [
            Locale('ru', 'RU'),
            Locale('en', 'US'),
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
          theme: IKMSTheme.lightTheme,
          darkTheme: IKMSTheme.darkTheme,
          home: (settings.university.value == null) ||
                  (settings.group.value == null)
              ? const OnBoardingScreen()
              : const HomePage(),
          builder: EasyLoading.init(),
        );
      },
    );
  }
}
