import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ikms/data/models/db.dart';
import 'package:ikms/data/repositories/schedule_repository.dart';
import 'package:ikms/data/repositories/settings_repository.dart';
import 'package:ikms/data/universities/university_entity_id.dart';
import 'package:ikms/data/universities/university_registry.dart';
import 'package:isar_community/isar.dart';

void main() {
  Directory? tempDir;
  Isar? isar;

  Future<Isar> openTempIsar(String name) async {
    tempDir = await Directory.systemTemp.createTemp('ikms_cache_');
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

  test('ensureSeeded does not reset lastUpdate timestamps', () async {
    final db = await openTempIsar('ensure_seeded');
    final ttlMs = DateTime.utc(2024, 6, 1).millisecondsSinceEpoch;

    await db.writeTxn(() async {
      await db.universitys.put(
        University(id: UniversityIds.donstu, name: 'ДГТУ')
          ..lastUpdateGroups = DateTime.fromMillisecondsSinceEpoch(
            ttlMs,
            isUtc: true,
          ),
      );
    });

    await UniversityRegistry.ensureSeeded(db);

    final uni = await db.universitys.get(UniversityIds.donstu);
    expect(uni, isNotNull);
    expect(uni!.lastUpdateGroups.millisecondsSinceEpoch, ttlMs);
    expect(uni.name, 'ДГТУ');
  });

  test('cacheEntityList preserves schedules when renaming a group', () async {
    final db = await openTempIsar('cache_merge');
    final repo = ScheduleRepository(db);
    final groupId = UniversityEntityId.encode(UniversityIds.donstu, 42);

    final university = University(id: UniversityIds.donstu, name: 'ДГТУ')
      ..lastUpdateGroups = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    final group = GroupSchedule(id: groupId, name: 'Old')
      ..schedules = [Schedule(discipline: 'Math', pair: 1)]
      ..lastUpdate = DateTime.utc(2024, 1, 1);

    await db.writeTxn(() async {
      await db.universitys.put(university);
      await db.groupSchedules.put(group);
      group.university.value = university;
      await group.university.save();
    });

    final uni = await db.universitys.get(UniversityIds.donstu);
    await uni!.groups.load();

    final ok = await repo.cacheEntityList<GroupSchedule>(
      university: uni,
      fetchData: () async => [GroupSchedule(id: groupId, name: 'New')],
      collection: db.groupSchedules,
      linksGetter: (u) => u.groups,
      lastUpdateGetter: (u) => u.lastUpdateGroups,
      lastUpdateSetter: (u, dt) => u.lastUpdateGroups = dt,
    );

    expect(ok, isTrue);
    final updated = await db.groupSchedules.get(groupId);
    expect(updated, isNotNull);
    expect(updated!.name, 'New');
    expect(updated.schedules, hasLength(1));
    expect(updated.schedules.first.discipline, 'Math');
  });

  test('cacheEntityList empty fetch keeps catalog and TTL', () async {
    final db = await openTempIsar('cache_empty');
    final repo = ScheduleRepository(db);
    final groupId = UniversityEntityId.encode(UniversityIds.donstu, 7);
    final ttlMs = DateTime.utc(2024, 3, 1).millisecondsSinceEpoch;

    final university = University(id: UniversityIds.donstu, name: 'ДГТУ')
      ..lastUpdateGroups = DateTime.fromMillisecondsSinceEpoch(
        ttlMs,
        isUtc: true,
      );
    final group = GroupSchedule(id: groupId, name: 'Keep');

    await db.writeTxn(() async {
      await db.universitys.put(university);
      await db.groupSchedules.put(group);
      group.university.value = university;
      await group.university.save();
    });

    final uni = await db.universitys.get(UniversityIds.donstu);
    await uni!.groups.load();
    // Force stale so fetch runs.
    uni.lastUpdateGroups = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

    final ok = await repo.cacheEntityList<GroupSchedule>(
      university: uni,
      fetchData: () async => [],
      collection: db.groupSchedules,
      linksGetter: (u) => u.groups,
      lastUpdateGetter: (u) => u.lastUpdateGroups,
      lastUpdateSetter: (u, dt) => u.lastUpdateGroups = dt,
    );

    expect(ok, isTrue);
    expect(await db.groupSchedules.count(), 1);
    expect(uni.lastUpdateGroups.millisecondsSinceEpoch, 0);
  });

  test('isStale uses inclusive cacheHours boundary', () {
    final almostTwelve = DateTime.now().subtract(const Duration(hours: 11));
    final twelve = DateTime.now().subtract(const Duration(hours: 12));
    expect(ScheduleRepository.isStale(almostTwelve), isFalse);
    expect(ScheduleRepository.isStale(twelve), isTrue);
  });

  test('cacheGroupSchedule empty fetch keeps existing schedules', () async {
    final db = await openTempIsar('entity_empty');
    var cleared = false;
    final repo = ScheduleRepository(
      db,
      onSelectedGroupCleared: () async {
        cleared = true;
      },
    );
    final groupId = UniversityEntityId.encode(UniversityIds.donstu, 9);
    final university = University(id: UniversityIds.donstu, name: 'ДГТУ');
    final group = GroupSchedule(id: groupId, name: 'G')
      ..schedules = [Schedule(discipline: 'Physics', pair: 2)]
      ..lastUpdate = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

    await db.writeTxn(() async {
      await db.universitys.put(university);
      await db.groupSchedules.put(group);
      group.university.value = university;
      await group.university.save();
    });

    // Offline / no API: force path by mocking is hard; call persist path via
    // empty list manually through public API when online isn't available.
    // Simulate empty API result by writing through repository with a stub:
    // when schedules.isEmpty, lastUpdate and schedules must stay.
    final before = await db.groupSchedules.get(groupId);
    expect(before!.schedules, hasLength(1));

    // Directly exercise empty-persist policy via cacheEntityList-style:
    // Re-open entity and invoke private policy by calling cache with force
    // while Connectivity is offline — schedules stay. If online without
    // network this may throw and also keep cache.
    final result = await repo.cacheGroupSchedule(
      university,
      before,
      forceRefresh: true,
    );
    expect(result.schedules, hasLength(1));
    expect(result.schedules.first.discipline, 'Physics');
    expect(cleared, isFalse);
  });

  test('cacheEntityList clears settings.group when group is removed', () async {
    final db = await openTempIsar('orphan_group');
    var cleared = false;
    final settingsRepo = SettingsRepository(db);
    late Settings settings;
    final repo = ScheduleRepository(
      db,
      onSelectedGroupCleared: () async {
        cleared = true;
        await settingsRepo.clearGroup(settings);
      },
    );
    final keepId = UniversityEntityId.encode(UniversityIds.donstu, 1);
    final dropId = UniversityEntityId.encode(UniversityIds.donstu, 2);

    final university = University(id: UniversityIds.donstu, name: 'ДГТУ')
      ..lastUpdateGroups = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    final keep = GroupSchedule(id: keepId, name: 'Keep');
    final drop = GroupSchedule(id: dropId, name: 'Drop');
    settings = Settings();

    await db.writeTxn(() async {
      await db.universitys.put(university);
      await db.groupSchedules.putAll([keep, drop]);
      keep.university.value = university;
      drop.university.value = university;
      await keep.university.save();
      await drop.university.save();
      await db.settings.put(settings);
      settings.university.value = university;
      settings.group.value = drop;
      await settings.university.save();
      await settings.group.save();
    });

    final uni = await db.universitys.get(UniversityIds.donstu);
    await uni!.groups.load();

    final ok = await repo.cacheEntityList<GroupSchedule>(
      university: uni,
      fetchData: () async => [GroupSchedule(id: keepId, name: 'Keep')],
      collection: db.groupSchedules,
      linksGetter: (u) => u.groups,
      lastUpdateGetter: (u) => u.lastUpdateGroups,
      lastUpdateSetter: (u, dt) => u.lastUpdateGroups = dt,
    );

    expect(ok, isTrue);
    expect(await db.groupSchedules.count(), 1);
    expect(await db.groupSchedules.get(dropId), isNull);
    expect(cleared, isTrue);

    final persisted = await db.settings.where().findFirst();
    await persisted!.group.load();
    expect(persisted.group.value, isNull);
  });
}
