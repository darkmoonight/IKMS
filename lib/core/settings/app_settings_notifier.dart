import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikms/core/di/provider_refs.dart';
import 'package:ikms/core/di/settings_revision.dart';
import 'package:ikms/core/settings/app_settings_state.dart';
import 'package:ikms/i18n/locale_utils.dart';

/// Exposes derived app settings for widgets and services.
final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettingsState>(
      AppSettingsNotifier.new,
    );

/// Watches the active UI locale from [appSettingsProvider].
final localeProvider = Provider<Locale>(
  (ref) => ref.watch(appSettingsProvider).locale,
);

/// Builds [AppSettingsState] from persisted settings and applies live updates.
class AppSettingsNotifier extends Notifier<AppSettingsState> {
  /// Rebuilds derived settings whenever persisted [Settings] change.
  @override
  AppSettingsState build() {
    ref.watch(settingsRevisionProvider);
    return AppSettingsState.fromSettings(ref.watch(settingsProvider));
  }

  /// Updates in-memory settings and syncs locale changes to slang + intl.
  void update({bool? amoledTheme, bool? materialColor, Locale? locale}) {
    state = state.copyWith(
      amoledTheme: amoledTheme,
      materialColor: materialColor,
      locale: locale,
    );
    if (locale != null) {
      applyAppLocale(appLocaleFromFlutterLocale(locale));
    }
  }
}
