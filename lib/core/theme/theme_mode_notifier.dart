import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikms/core/di/provider_refs.dart';
import 'package:ikms/core/settings/settings_controller.dart';
import 'package:ikms/domain/entities/app_preferences.dart';
import 'package:ikms/i18n/tr.dart';

/// Provides the persisted theme mode preference as [ThemeMode].
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

/// User-visible label for a persisted theme preference.
String themePreferenceLabel(String? themeKey) => (themeKey ?? 'system').tr;

/// Exposes theme mode; writes go through [SettingsController].
class ThemeModeNotifier extends Notifier<ThemeMode> {
  /// Initializes theme mode from [preferencesProvider].
  @override
  ThemeMode build() => _fromPreferences(ref.watch(preferencesProvider));

  ThemeMode _fromPreferences(AppPreferences preferences) {
    switch (preferences.theme) {
      case 'system':
        return ThemeMode.system;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.light;
    }
  }

  /// Persists the selected theme mode string.
  Future<void> saveTheme(String themeMode) =>
      ref.read(settingsControllerProvider).saveTheme(themeMode);

  /// Persists the AMOLED (pure black) theme toggle.
  Future<void> saveOledTheme(bool isOled) =>
      ref.read(settingsControllerProvider).saveOledTheme(isOled);

  /// Persists the Material You dynamic color toggle.
  Future<void> saveMaterialTheme(bool isMaterial) =>
      ref.read(settingsControllerProvider).saveMaterialTheme(isMaterial);
}
