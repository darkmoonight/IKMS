import 'package:isar_community/isar.dart';
import 'package:ikms/data/models/db.dart';
import 'package:ikms/data/universities/donstu/donstu_api.dart';
import 'package:ikms/data/universities/university_api.dart';
import 'package:ikms/data/universities/university_entity_id.dart';
import 'package:ikms/data/universities/university_ids.dart';

export 'package:ikms/data/universities/university_ids.dart';

/// Central registry of supported universities (seed + API clients).
abstract final class UniversityRegistry {
  /// API clients keyed by [University.id].
  static final Map<int, UniversityAPI> apis = {
    UniversityIds.donstu: DonstuAPI(),
  };

  /// Local catalog rows upserted on every app start.
  static final List<University> catalog = [
    University(id: UniversityIds.donstu, name: 'ДГТУ'),
  ];

  /// Returns the API for [universityId], or null if unsupported.
  static UniversityAPI? apiFor(int universityId) => apis[universityId];

  /// Ensures every catalog university exists in Isar (name-only upsert by id).
  ///
  /// Never overwrites persisted catalog TTL timestamps (`lastUpdate*`).
  static Future<void> ensureSeeded(Isar isar) async {
    await isar.writeTxn(() async {
      for (final seed in catalog) {
        final existing = await isar.universitys.get(seed.id);
        if (existing == null) {
          await isar.universitys.put(seed);
        } else if (existing.name != seed.name) {
          existing.name = seed.name;
          await isar.universitys.put(existing);
        }
      }
    });
  }

  /// Clears schedule catalogs stored with pre-composite Isar ids.
  ///
  /// Isar Community has no schemaVersion hook; this runs once when legacy
  /// group/teacher/audience rows are detected. Clears selected group so the
  /// user re-picks after upgrade (university selection is kept).
  static Future<void> migrateLegacyEntityIds(Isar isar) async {
    final group = await isar.groupSchedules.where().findFirst();
    final teacher = await isar.teacherSchedules.where().findFirst();
    final audience = await isar.audienceSchedules.where().findFirst();
    final needsMigration =
        (group != null && UniversityEntityId.isLegacy(group.id)) ||
        (teacher != null && UniversityEntityId.isLegacy(teacher.id)) ||
        (audience != null && UniversityEntityId.isLegacy(audience.id));
    if (!needsMigration) return;

    final epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    await isar.writeTxn(() async {
      await isar.groupSchedules.clear();
      await isar.teacherSchedules.clear();
      await isar.audienceSchedules.clear();

      final universities = await isar.universitys.where().findAll();
      for (final university in universities) {
        university.lastUpdateGroups = epoch;
        university.lastUpdateTeachers = epoch;
        university.lastUpdateAudiences = epoch;
        await isar.universitys.put(university);
      }

      final settings = await isar.settings.where().findFirst();
      if (settings != null) {
        settings.group.value = null;
        await isar.settings.put(settings);
        await settings.group.save();
      }
    });
  }
}
