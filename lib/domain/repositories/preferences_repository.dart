import 'package:ikms/domain/entities/app_preferences.dart';
import 'package:ikms/domain/entities/catalog_refs.dart';

/// Port for reading and writing [AppPreferences].
abstract class PreferencesRepository {
  /// Current preferences snapshot (linked refs resolved).
  AppPreferences get current;

  /// Persists appearance / locale / ads fields from [preferences].
  Future<void> save(AppPreferences preferences);

  /// Sets theme mode key (`system` / `dark` / `light`).
  Future<void> saveTheme(String theme);

  /// Sets AMOLED pure-black toggle.
  Future<void> saveOledTheme(bool isOled);

  /// Sets Material You dynamic color toggle.
  Future<void> saveMaterialTheme(bool isMaterial);

  /// Sets language code (`en_US` style) without applying slang.
  Future<void> saveLanguageCode(String languageCode);

  /// Sets ads-disabled flag.
  Future<void> saveAdsDisabled(bool adsDisabled);

  /// Selects [university] and clears group.
  Future<void> setUniversity(UniversityRef university);

  /// Selects [group] (must belong to current university).
  Future<void> setGroup(GroupRef group);

  /// Clears the selected group.
  Future<void> clearGroup();
}
