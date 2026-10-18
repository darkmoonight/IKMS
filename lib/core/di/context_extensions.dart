import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ikms/core/di/provider_refs.dart';
import 'package:ikms/core/services/connectivity_service.dart';
import 'package:ikms/core/settings/app_settings_notifier.dart';
import 'package:ikms/domain/entities/app_preferences.dart';
import 'package:ikms/domain/repositories/schedule_cache_port.dart';

/// Convenient reads of Riverpod providers from a [BuildContext].
extension IkmsContextX on BuildContext {
  /// Domain preferences snapshot.
  AppPreferences get preferences =>
      ProviderScope.containerOf(this).read(preferencesProvider);

  /// Domain schedule cache port.
  ScheduleCachePort get scheduleCache =>
      ProviderScope.containerOf(this).read(scheduleCachePortProvider);

  /// Online-status notifier.
  ValueNotifier<Future<bool>> get isOnline => ConnectivityService.isOnline;

  /// Active UI locale from [localeProvider].
  Locale get appLocale => ProviderScope.containerOf(this).read(localeProvider);
}
