import 'package:display_mode/display_mode.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:isar_community/isar.dart';
import 'package:ikms/core/bootstrap/app_bootstrap.dart';
import 'package:ikms/core/database/isar_database.dart';
import 'package:ikms/core/utils/device_info.dart';
import 'package:ikms/data/models/db.dart';
import 'package:ikms/data/universities/university_registry.dart';
import 'package:ikms/i18n/locale_utils.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:yandex_mobileads/mobile_ads.dart';

/// One-time startup: DB, locale, notifications, display mode, and ads.
class AppInitializer {
  /// Runs all bootstrap steps and returns the loaded [AppBootstrap].
  static Future<AppBootstrap> initialize() async {
    await _initializeTimeZone();
    final bootstrap = await _initializeIsar();
    await _initializeNotifications(bootstrap.notificationsPlugin);
    await _setOptimalDisplayMode();
    await DeviceFeature().init();
    YandexAds.initialize();
    return bootstrap;
  }

  /// Opens Isar, seeds defaults, and applies the stored locale.
  static Future<AppBootstrap> _initializeIsar() async {
    final isar = await openIkmsIsar();
    await UniversityRegistry.migrateLegacyEntityIds(isar);
    await UniversityRegistry.ensureSeeded(isar);

    var settings = await isar.settings.where().findFirst();
    var changed = settings == null;
    settings ??= Settings();

    if (settings.language == null) {
      settings.language = languageCodeFromAppLocale(
        appLocaleFromFlutterLocale(PlatformDispatcher.instance.locale),
      );
      changed = true;
    }
    if (settings.theme == null) {
      settings.theme = 'system';
      changed = true;
    }
    // Links require a managed Isar object; persist first when seeding.
    if (changed) {
      await isar.writeTxn(() async => await isar.settings.put(settings!));
    }

    await settings.university.load();
    await settings.group.load();

    await applyAppLocale(appLocaleFromLanguageCode(settings.language));

    return AppBootstrap(
      isar: isar,
      settings: settings,
      notificationsPlugin: FlutterLocalNotificationsPlugin(),
    );
  }

  static Future<void> _initializeTimeZone() async {
    try {
      final TimezoneInfo timeZoneName =
          await FlutterTimezone.getLocalTimezone();
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation(timeZoneName.identifier));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('timezone init failed: $e');
      }
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.UTC);
    }
  }

  static Future<void> _initializeNotifications(
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await plugin.initialize(settings: settings);
  }

  /// Picks the highest refresh rate matching the current display resolution.
  static Future<void> _setOptimalDisplayMode() async {
    try {
      final supported = await FlutterDisplayMode.supported;
      final active = await FlutterDisplayMode.active;
      final sameResolution =
          supported
              .where(
                (m) => m.width == active.width && m.height == active.height,
              )
              .toList()
            ..sort((a, b) => b.refreshRate.compareTo(a.refreshRate));
      final mostOptimalMode = sameResolution.isNotEmpty
          ? sameResolution.first
          : active;
      await FlutterDisplayMode.setPreferredMode(mostOptimalMode);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('display_mode: $e');
      }
    }
  }
}
