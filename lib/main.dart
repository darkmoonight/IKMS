import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:display_mode/display_mode.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:ikms/theme/theme.dart';
import 'package:ikms/app/utils/device_info.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ikms/app/data/db.dart';
import 'package:ikms/app/ui/home.dart';
import 'package:ikms/app/ui/onboarding.dart';
import 'package:ikms/translation/translation.dart';
import 'package:ikms/theme/theme_controller.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:yandex_mobileads/mobile_ads.dart';
import 'app/utils/snackbar_overlay.dart';

late Isar isar;
late Settings settings;

late List<University> universities;
late University selectedUniversity;

bool amoledTheme = false;
bool materialColor = false;
Locale locale = const Locale('en', 'US');

final List<Map<String, dynamic>> appLanguages = [
  {'name': 'English', 'locale': const Locale('en', 'US')},
  {'name': 'Русский', 'locale': const Locale('ru', 'RU')},
];

final ValueNotifier<Future<bool>> isOnline = ValueNotifier(
  InternetConnection().hasInternetAccess,
);

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeApp() async {
  await isarInit();
  await setOptimalDisplayMode();
  await initializeNotifications();
  await initializeTimeZone();
  DeviceFeature().init();
}

Future<void> initializeTimeZone() async {
  final TimezoneInfo timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation(timeZoneName.identifier));
}

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
  );
}

Future<void> setOptimalDisplayMode() async {
  final List<DisplayModeJson> supported = await FlutterDisplayMode.supported;
  final DisplayModeJson active = await FlutterDisplayMode.active;
  final List<DisplayModeJson> sameResolution =
      supported
          .where(
            (DisplayModeJson m) =>
                m.width == active.width && m.height == active.height,
          )
          .toList()
        ..sort(
          (DisplayModeJson a, DisplayModeJson b) =>
              b.refreshRate.compareTo(a.refreshRate),
        );
  final DisplayModeJson mostOptimalMode = sameResolution.isNotEmpty
      ? sameResolution.first
      : active;
  await FlutterDisplayMode.setPreferredMode(mostOptimalMode);
}

Future<void> isarInit() async {
  isar = await Isar.open(
    [
      SettingsSchema,
      UniversitySchema,
      GroupScheduleSchema,
      TeacherScheduleSchema,
      AudienceScheduleSchema,
      TodosSchema,
    ],
    compactOnLaunch: const CompactCondition(minRatio: 2),
    directory: (await getApplicationSupportDirectory()).path,
  );
  settings = await isar.settings.where().findFirst() ?? Settings();
  universities = await isar.universitys.where().findAll();
  if (universities.isEmpty) {
    final donstu = University(id: 1, name: 'ДГТУ');
    await isar.writeTxn(() async => await isar.universitys.put(donstu));
    universities = [donstu];
  }
  selectedUniversity = settings.university.value ?? universities.first;
  if (settings.language == null) {
    settings.language = '${Get.deviceLocale}';
    await isar.writeTxn(() async => await isar.settings.put(settings));
  }
  if (settings.theme == null) {
    settings.theme = 'system';
    await isar.writeTxn(() async => await isar.settings.put(settings));
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeApp();
  Connectivity().onConnectivityChanged.listen(
    (List<ConnectivityResult> result) =>
        result.contains(ConnectivityResult.none)
        ? isOnline.value = Future(() => false)
        : isOnline.value = InternetConnection().hasInternetAccess,
  );
  YandexAds.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  static Future<void> updateAppState(
    BuildContext context, {
    bool? newAmoledTheme,
    bool? newMaterialColor,
    Locale? newLocale,
  }) async {
    final state = context.findAncestorStateOfType<_MyAppState>()!;
    if (newAmoledTheme != null) state.changeAmoledTheme(newAmoledTheme);
    if (newMaterialColor != null) state.changeMaterialTheme(newMaterialColor);
    if (newLocale != null) state.changeLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final themeController = Get.put(ThemeController());
  void changeAmoledTheme(bool newAmoledTheme) =>
      setState(() => amoledTheme = newAmoledTheme);
  void changeMaterialTheme(bool newMaterialColor) =>
      setState(() => materialColor = newMaterialColor);
  void changeLocale(Locale newLocale) => setState(() => locale = newLocale);

  @override
  void initState() {
    amoledTheme = settings.amoledTheme;
    materialColor = settings.materialColor;
    locale = Locale(
      settings.language!.substring(0, 2),
      settings.language!.substring(3),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final edgeToEdgeAvailable = DeviceFeature().isEdgeToEdgeAvailable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: DynamicColorBuilder(
        builder: (lightColorScheme, darkColorScheme) {
          final lightMaterialTheme = lightTheme(
            lightColorScheme?.surface,
            lightColorScheme,
            edgeToEdgeAvailable,
          );
          final darkMaterialTheme = darkTheme(
            darkColorScheme?.surface,
            darkColorScheme,
            edgeToEdgeAvailable,
          );
          final darkMaterialThemeOled = darkTheme(
            oledColor,
            darkColorScheme,
            edgeToEdgeAvailable,
          );
          return GetMaterialApp(
            theme: materialColor
                ? lightColorScheme != null
                      ? lightMaterialTheme
                      : lightTheme(
                          lightColor,
                          colorSchemeLight,
                          edgeToEdgeAvailable,
                        )
                : lightTheme(lightColor, colorSchemeLight, edgeToEdgeAvailable),
            darkTheme: amoledTheme
                ? materialColor
                      ? darkColorScheme != null
                            ? darkMaterialThemeOled
                            : darkTheme(
                                oledColor,
                                colorSchemeDark,
                                edgeToEdgeAvailable,
                              )
                      : darkTheme(
                          oledColor,
                          colorSchemeDark,
                          edgeToEdgeAvailable,
                        )
                : materialColor
                ? darkColorScheme != null
                      ? darkMaterialTheme
                      : darkTheme(
                          darkColor,
                          colorSchemeDark,
                          edgeToEdgeAvailable,
                        )
                : darkTheme(darkColor, colorSchemeDark, edgeToEdgeAvailable),
            themeMode: themeController.theme,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            translations: Translation(),
            locale: locale,
            fallbackLocale: const Locale('en', 'US'),
            supportedLocales: appLanguages
                .map((e) => e['locale'] as Locale)
                .toList(),
            debugShowCheckedModeBanner: false,
            home:
                (settings.university.value == null) ||
                    (settings.group.value == null)
                ? const OnBoardingScreen()
                : const HomePage(),
            title: 'IKMS',
            builder: (context, child) {
              return Stack(children: [child!, const SnackBarOverlayWidget()]);
            },
          );
        },
      ),
    );
  }
}
