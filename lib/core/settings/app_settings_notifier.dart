import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikms/core/di/provider_refs.dart';
import 'package:ikms/core/settings/app_settings_state.dart';

/// Exposes derived app settings for widgets and services.
final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettingsState>(
      AppSettingsNotifier.new,
    );

/// Watches the active UI locale from [appSettingsProvider].
final localeProvider = Provider<Locale>(
  (ref) => ref.watch(appSettingsProvider).locale,
);

/// Builds [AppSettingsState] from [preferencesProvider] (read-only).
class AppSettingsNotifier extends Notifier<AppSettingsState> {
  /// Rebuilds derived settings whenever preferences change.
  @override
  AppSettingsState build() =>
      AppSettingsState.fromPreferences(ref.watch(preferencesProvider));
}
