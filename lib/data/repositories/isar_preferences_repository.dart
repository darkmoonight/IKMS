import 'package:isar_community/isar.dart';
import 'package:ikms/data/mappers/preferences_mapper.dart';
import 'package:ikms/data/models/db.dart';
import 'package:ikms/data/repositories/settings_repository.dart';
import 'package:ikms/domain/entities/app_preferences.dart';
import 'package:ikms/domain/entities/catalog_refs.dart';
import 'package:ikms/domain/repositories/preferences_repository.dart';

/// Isar-backed [PreferencesRepository] over the bootstrap [Settings] row.
class IsarPreferencesRepository implements PreferencesRepository {
  /// Creates a preferences adapter.
  IsarPreferencesRepository({
    required this._settings,
    required this._settingsRepository,
    required this._isar,
  });

  final Settings _settings;
  final SettingsRepository _settingsRepository;
  final Isar _isar;

  @override
  AppPreferences get current => preferencesFromSettings(_settings);

  Future<void> _ensureLinksLoaded() async {
    await _settings.university.load();
    await _settings.group.load();
    final group = _settings.group.value;
    if (group != null) {
      await group.university.load();
    }
  }

  @override
  Future<void> save(AppPreferences preferences) async {
    _settings.theme = preferences.theme;
    _settings.amoledTheme = preferences.amoledTheme;
    _settings.materialColor = preferences.materialColor;
    _settings.ads = preferences.adsDisabled;
    _settings.language = preferences.languageCode;
    await _settingsRepository.save(_settings);
  }

  @override
  Future<void> saveTheme(String theme) async {
    _settings.theme = theme;
    await _settingsRepository.save(_settings);
  }

  @override
  Future<void> saveOledTheme(bool isOled) async {
    _settings.amoledTheme = isOled;
    await _settingsRepository.save(_settings);
  }

  @override
  Future<void> saveMaterialTheme(bool isMaterial) async {
    _settings.materialColor = isMaterial;
    await _settingsRepository.save(_settings);
  }

  @override
  Future<void> saveLanguageCode(String languageCode) async {
    _settings.language = languageCode;
    await _settingsRepository.save(_settings);
  }

  @override
  Future<void> saveAdsDisabled(bool adsDisabled) async {
    _settings.ads = adsDisabled;
    await _settingsRepository.save(_settings);
  }

  @override
  Future<void> setUniversity(UniversityRef university) async {
    final row = await _isar.universitys.get(university.id);
    if (row == null) {
      throw StateError('University ${university.id} not found');
    }
    await _settingsRepository.setUniversity(_settings, row);
  }

  @override
  Future<void> setGroup(GroupRef group) async {
    final row = await _isar.groupSchedules.get(group.id);
    if (row == null) {
      throw StateError('Group ${group.id} not found');
    }
    await row.university.load();
    await _settingsRepository.setGroup(_settings, row);
  }

  @override
  Future<void> clearGroup() async {
    await _ensureLinksLoaded();
    await _settingsRepository.clearGroup(_settings);
  }
}
