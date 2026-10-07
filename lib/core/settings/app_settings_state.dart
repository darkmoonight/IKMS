import 'package:material_ui/material_ui.dart';
import 'package:ikms/data/models/db.dart';
import 'package:ikms/i18n/locale_utils.dart';

/// In-memory snapshot of user-facing app settings for UI and services.
class AppSettingsState {
  const AppSettingsState({
    this.amoledTheme = false,
    this.materialColor = false,
    this.locale = const Locale('en', 'US'),
  });

  final bool amoledTheme;
  final bool materialColor;
  final Locale locale;

  /// Returns a copy with selectively replaced fields.
  AppSettingsState copyWith({
    bool? amoledTheme,
    bool? materialColor,
    Locale? locale,
  }) => AppSettingsState(
    amoledTheme: amoledTheme ?? this.amoledTheme,
    materialColor: materialColor ?? this.materialColor,
    locale: locale ?? this.locale,
  );

  /// Builds the live snapshot from persisted [Settings].
  factory AppSettingsState.fromSettings(Settings settings) {
    return AppSettingsState(
      amoledTheme: settings.amoledTheme,
      materialColor: settings.materialColor,
      locale: flutterLocaleOf(appLocaleFromLanguageCode(settings.language)),
    );
  }
}
