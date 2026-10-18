import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikms/core/di/provider_refs.dart';
import 'package:ikms/core/utils/show_snack_bar.dart';
import 'package:ikms/domain/repositories/preferences_repository.dart';
import 'package:ikms/i18n/locale_utils.dart';
import 'package:ikms/i18n/tr.dart';
import 'package:material_ui/material_ui.dart';

/// Sole writer for appearance, locale, and ads preferences.
class SettingsController {
  /// Creates a controller bound to [ref].
  SettingsController(this._ref);

  final Ref _ref;

  PreferencesRepository get _prefs => _ref.read(preferencesRepositoryProvider);

  /// Persists the theme mode key (`system` / `dark` / `light`).
  Future<void> saveTheme(String themeMode) => _prefs.saveTheme(themeMode);

  /// Persists the AMOLED (pure black) theme toggle.
  Future<void> saveOledTheme(bool isOled) => _prefs.saveOledTheme(isOled);

  /// Persists the Material You dynamic color toggle.
  Future<void> saveMaterialTheme(bool isMaterial) =>
      _prefs.saveMaterialTheme(isMaterial);

  /// Persists language and applies slang / intl locale.
  Future<void> setLocale(Locale locale) async {
    final appLocale = appLocaleFromFlutterLocale(locale);
    await _prefs.saveLanguageCode(languageCodeFromAppLocale(appLocale));
    await applyAppLocale(appLocale);
  }

  /// Toggles ads-disabled flag (save-first with rollback on failure).
  Future<void> toggleAds(bool adsDisabled) async {
    final previous = _ref.read(preferencesProvider).adsDisabled;
    try {
      await _prefs.saveAdsDisabled(adsDisabled);
    } catch (_) {
      try {
        await _prefs.saveAdsDisabled(previous);
      } catch (_) {}
      showSnackBar('errorOccurred'.tr, isError: true);
      rethrow;
    }
  }
}

/// App-wide [SettingsController] instance.
final settingsControllerProvider = Provider<SettingsController>(
  SettingsController.new,
);
