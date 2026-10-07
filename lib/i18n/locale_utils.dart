import 'package:material_ui/material_ui.dart';
import 'package:ikms/i18n/strings.g.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Parses a stored language code (e.g. `en_US`) into an [AppLocale].
AppLocale appLocaleFromLanguageCode(String? language) {
  if (language == null || language.isEmpty) return AppLocale.enUs;
  return AppLocaleUtils.parse(language.replaceAll('_', '-'));
}

/// Converts a Flutter [Locale] into the closest supported [AppLocale].
AppLocale appLocaleFromFlutterLocale(Locale locale) {
  final country = locale.countryCode;
  if (country != null && country.isNotEmpty) {
    return AppLocaleUtils.parse('${locale.languageCode}-$country');
  }
  return AppLocaleUtils.parse(locale.languageCode);
}

/// Serializes [locale] to `language_COUNTRY`.
String languageCodeFromAppLocale(AppLocale locale) {
  final c = locale.countryCode;
  if (c == null || c.isEmpty) return locale.languageCode;
  return '${locale.languageCode}_${c.toUpperCase()}';
}

/// Applies slang locale and loads intl date symbols.
Future<void> applyAppLocale(AppLocale appLocale) async {
  await LocaleSettings.setLocale(appLocale);
  final languageCode = appLocale.languageCode;
  try {
    await initializeDateFormatting(languageCode);
  } catch (_) {
    await initializeDateFormatting('en');
  }
}

/// Converts [AppLocale] to a Flutter [Locale].
Locale flutterLocaleOf(AppLocale locale) {
  final country = locale.countryCode;
  if (country == null || country.isEmpty) {
    return Locale(locale.languageCode);
  }
  return Locale(locale.languageCode, country);
}

/// Supported UI languages shown in settings.
final List<Map<String, dynamic>> appLanguages = [
  {'name': 'English', 'locale': const Locale('en', 'US')},
  {'name': 'Русский', 'locale': const Locale('ru', 'RU')},
];
