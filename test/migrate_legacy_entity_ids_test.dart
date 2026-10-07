import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ikms/data/models/db.dart';
import 'package:ikms/data/universities/university_entity_id.dart';
import 'package:ikms/data/universities/university_ids.dart';
import 'package:ikms/data/universities/university_registry.dart';
import 'package:isar_community/isar.dart';

void main() {
  Directory? tempDir;
  Isar? isar;

  Future<Isar> openTempIsar(String name) async {
    tempDir = await Directory.systemTemp.createTemp('ikms_migrate_');
    final opened = await Isar.open(
      [
        SettingsSchema,
        UniversitySchema,
        GroupScheduleSchema,
        TeacherScheduleSchema,
        AudienceScheduleSchema,
        TodosSchema,
      ],
      directory: tempDir!.path,
      name: name,
    );
    isar = opened;
    return opened;
  }

  tearDown(() async {
    final open = isar;
    if (open != null && Isar.instanceNames.contains(open.name)) {
      await open.close(deleteFromDisk: true);
    }
    isar = null;
    final dir = tempDir;
    if (dir != null && dir.existsSync()) {
      await dir.delete(recursive: true);
    }
    tempDir = null;
  });

  test(
    'legacy ids clear catalogs and group but keep appearance prefs',
    () async {
      final db = await openTempIsar('migrate_legacy');

      final university = University(id: UniversityIds.donstu, name: 'ДГТУ')
        ..lastUpdateGroups = DateTime.utc(2024, 1, 15);
      final group = GroupSchedule(id: 4242, name: 'ИВТ-11');
      final settings = Settings()
        ..theme = 'dark'
        ..language = 'ru_RU'
        ..amoledTheme = true
        ..ads = true
        ..materialColor = true;

      await db.writeTxn(() async {
        await db.universitys.put(university);
        await db.groupSchedules.put(group);
        group.university.value = university;
        await group.university.save();

        await db.settings.put(settings);
        settings.university.value = university;
        settings.group.value = group;
        await settings.university.save();
        await settings.group.save();
      });

      await UniversityRegistry.migrateLegacyEntityIds(db);

      expect(await db.groupSchedules.count(), 0);
      expect(await db.teacherSchedules.count(), 0);
      expect(await db.audienceSchedules.count(), 0);

      final migrated = await db.settings.where().findFirst();
      expect(migrated, isNotNull);
      await migrated!.university.load();
      await migrated.group.load();

      expect(migrated.group.value, isNull);
      expect(migrated.university.value?.id, UniversityIds.donstu);
      expect(migrated.theme, 'dark');
      expect(migrated.language, 'ru_RU');
      expect(migrated.amoledTheme, isTrue);
      expect(migrated.ads, isTrue);
      expect(migrated.materialColor, isTrue);

      final uni = await db.universitys.get(UniversityIds.donstu);
      expect(uni, isNotNull);
      expect(uni!.lastUpdateGroups.millisecondsSinceEpoch, 0);
      expect(uni.lastUpdateTeachers.millisecondsSinceEpoch, 0);
      expect(uni.lastUpdateAudiences.millisecondsSinceEpoch, 0);
    },
  );

  test('composite ids leave catalogs and group untouched', () async {
    final db = await openTempIsar('migrate_composite');

    final compositeId = UniversityEntityId.encode(UniversityIds.donstu, 4242);
    final university = University(id: UniversityIds.donstu, name: 'ДГТУ');
    final group = GroupSchedule(id: compositeId, name: 'ИВТ-11');
    final settings = Settings()..theme = 'light';

    await db.writeTxn(() async {
      await db.universitys.put(university);
      await db.groupSchedules.put(group);
      group.university.value = university;
      await group.university.save();

      await db.settings.put(settings);
      settings.university.value = university;
      settings.group.value = group;
      await settings.university.save();
      await settings.group.save();
    });

    await UniversityRegistry.migrateLegacyEntityIds(db);

    expect(await db.groupSchedules.count(), 1);
    expect(await db.groupSchedules.get(compositeId), isNotNull);

    final unchanged = await db.settings.where().findFirst();
    expect(unchanged, isNotNull);
    await unchanged!.group.load();
    expect(unchanged.group.value?.id, compositeId);
    expect(unchanged.theme, 'light');
  });
}
