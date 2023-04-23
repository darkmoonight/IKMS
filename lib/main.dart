import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_yandex_mobile_ads/yandex.dart';
import 'package:get/get.dart';
import 'package:ikms/theme/theme.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ikms/app/data/schema.dart';
import 'package:ikms/app/modules/home.dart';
import 'package:ikms/app/modules/onboarding.dart';
import 'package:ikms/translation/translation.dart';
import 'package:ikms/theme/theme_controller.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

late Isar isar;
late Settings settings;
late University donstu;
final ValueNotifier<Future<bool>> isDeviceConnectedNotifier =
    ValueNotifier(InternetConnectionChecker().hasConnection);

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
  Yandex.initialize();
  runApp(MyApp());
}

Future<void> isarInit() async {
  isar = await Isar.open([
    SettingsSchema,
    UniversitySchema,
    GroupScheduleSchema,
    TeacherScheduleSchema,
    AudienceScheduleSchema,
    TodosSchema,
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
        Locale('en', 'US'),
        Locale('ru', 'RU'),
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
      home:
          (settings.university.value == null) || (settings.group.value == null)
              ? const OnBoardingScreen()
              : const HomePage(),
      builder: EasyLoading.init(),
    );
  }
}
