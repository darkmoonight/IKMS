import 'package:connecteo/connecteo.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:ikms/theme/theme.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ikms/app/data/schema.dart';
import 'package:ikms/app/modules/home.dart';
import 'package:ikms/app/modules/onboarding.dart';
import 'package:ikms/translation/translation.dart';
import 'package:ikms/theme/theme_controller.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:yandex_mobileads/mobile_ads.dart';

late Isar isar;
late Settings settings;

bool amoledTheme = false;
bool materialColor = false;
Locale locale = const Locale('en', 'US');

final List appLanguages = [
  {'name': 'English', 'locale': const Locale('en', 'US')},
  {'name': 'Русский', 'locale': const Locale('ru', 'RU')},
];

late University donstu;
final ValueNotifier<Future<bool>> isDeviceConnectedNotifier =
    ValueNotifier(ConnectionChecker().isConnected);

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await isarInit();
  await setOptimalDisplayMode();
  Connectivity()
      .onConnectivityChanged
      .listen((ConnectivityResult result) async {
    if (result != ConnectivityResult.none) {
      isDeviceConnectedNotifier.value = ConnectionChecker().isConnected;
    } else {
      isDeviceConnectedNotifier.value = Future(() => false);
    }
  });
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(systemNavigationBarColor: Colors.black),
  );
  final String timeZoneName = await FlutterTimezone.getLocalTimezone();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
  MobileAds.initialize();
  runApp(const MyApp());
}

Future<void> setOptimalDisplayMode() async {
  final List<DisplayMode> supported = await FlutterDisplayMode.supported;
  final DisplayMode active = await FlutterDisplayMode.active;
  final List<DisplayMode> sameResolution = supported
      .where((DisplayMode m) =>
          m.width == active.width && m.height == active.height)
      .toList()
    ..sort((DisplayMode a, DisplayMode b) =>
        b.refreshRate.compareTo(a.refreshRate));
  final DisplayMode mostOptimalMode =
      sameResolution.isNotEmpty ? sameResolution.first : active;
  await FlutterDisplayMode.setPreferredMode(mostOptimalMode);
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

  settings = isar.settings.where().findFirstSync() ?? Settings();
  donstu = isar.universitys.getSync(1) ?? University(id: 1, name: 'ДГТУ');

  if (isar.settings.countSync() == 0) {
    isar.writeTxnSync(() => isar.settings.putSync(settings));
  }

  if (isar.universitys.countSync() == 0) {
    isar.writeTxnSync(() => isar.universitys.putSync(donstu));
  }

  if (settings.language == null) {
    settings.language = '${Get.deviceLocale}';
    isar.writeTxnSync(() => isar.settings.putSync(settings));
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  static Future<void> updateAppState(
    BuildContext context, {
    bool? newAmoledTheme,
    bool? newMaterialColor,
    Locale? newLocale,
  }) async {
    final state = context.findAncestorStateOfType<_MyAppState>()!;

    if (newAmoledTheme != null) {
      state.changeAmoledTheme(newAmoledTheme);
    }
    if (newMaterialColor != null) {
      state.changeMarerialTheme(newMaterialColor);
    }
    if (newLocale != null) {
      state.changeLocale(newLocale);
    }
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final themeController = Get.put(ThemeController());

  void changeAmoledTheme(bool newAmoledTheme) {
    setState(() {
      amoledTheme = newAmoledTheme;
    });
  }

  void changeMarerialTheme(bool newMaterialColor) {
    setState(() {
      materialColor = newMaterialColor;
    });
  }

  void changeLocale(Locale newLocale) {
    setState(() {
      locale = newLocale;
    });
  }

  @override
  void initState() {
    amoledTheme = settings.amoledTheme;
    materialColor = settings.materialColor;
    locale = Locale(
        settings.language!.substring(0, 2), settings.language!.substring(3));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
        final lightMaterialTheme =
            lightTheme(lightColorScheme?.surface, lightColorScheme);
        final darkMaterialTheme =
            darkTheme(darkColorScheme?.surface, darkColorScheme);
        final darkMaterialThemeOled = darkTheme(oledColor, darkColorScheme);

        return GetMaterialApp(
          theme: materialColor
              ? lightColorScheme != null
                  ? lightMaterialTheme
                  : lightTheme(lightColor, colorSchemeLight)
              : lightTheme(lightColor, colorSchemeLight),
          darkTheme: amoledTheme
              ? materialColor
                  ? darkColorScheme != null
                      ? darkMaterialThemeOled
                      : darkTheme(oledColor, colorSchemeDark)
                  : darkTheme(oledColor, colorSchemeDark)
              : materialColor
                  ? darkColorScheme != null
                      ? darkMaterialTheme
                      : darkTheme(darkColor, colorSchemeDark)
                  : darkTheme(darkColor, colorSchemeDark),
          themeMode: themeController.theme,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          translations: Translation(),
          locale: locale,
          fallbackLocale: const Locale('en', 'US'),
          supportedLocales:
              appLanguages.map((e) => e['locale'] as Locale).toList(),
          debugShowCheckedModeBanner: false,
          home: (settings.university.value == null) ||
                  (settings.group.value == null)
              ? const OnBoardingScreen()
              : const HomePage(),
          builder: EasyLoading.init(),
        );
      }),
    );
  }
}
