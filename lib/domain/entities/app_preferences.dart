import 'package:ikms/domain/entities/catalog_refs.dart';

/// User-facing preferences and selected schedule targets.
class AppPreferences {
  const AppPreferences({
    this.theme = 'system',
    this.amoledTheme = false,
    this.materialColor = false,
    this.adsDisabled = false,
    this.languageCode,
    this.university,
    this.group,
  });

  final String theme;
  final bool amoledTheme;
  final bool materialColor;

  /// `true` when ads are turned off by the user.
  final bool adsDisabled;
  final String? languageCode;
  final UniversityRef? university;
  final GroupRef? group;

  /// Whether onboarding must collect university and group.
  bool get needsOnboarding => university == null || group == null;

  /// Returns a copy with selectively replaced fields.
  AppPreferences copyWith({
    String? theme,
    bool? amoledTheme,
    bool? materialColor,
    bool? adsDisabled,
    String? languageCode,
    UniversityRef? university,
    GroupRef? group,
    bool clearUniversity = false,
    bool clearGroup = false,
  }) => AppPreferences(
    theme: theme ?? this.theme,
    amoledTheme: amoledTheme ?? this.amoledTheme,
    materialColor: materialColor ?? this.materialColor,
    adsDisabled: adsDisabled ?? this.adsDisabled,
    languageCode: languageCode ?? this.languageCode,
    university: clearUniversity ? null : (university ?? this.university),
    group: clearGroup ? null : (group ?? this.group),
  );
}
