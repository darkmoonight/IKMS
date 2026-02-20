import 'package:flutter/foundation.dart';
import 'package:ikms/app/api/api.dart';
import 'package:ikms/app/data/db.dart';
import 'package:ikms/main.dart';
import 'package:isar_community/isar.dart';

final Map<int, UniversityAPI> universityApis = {
  1: DonstuAPI(),
  // Add new: 2: NewUniAPI(),
};

class UniversityCaching {
  static Future<bool> cacheEntityList<T>({
    required University university,
    required Future<List<T>> Function() fetchData,
    required IsarCollection<T> collection,
    required IsarLinks<T> Function(University) linksGetter,
    required DateTime Function(University) lastUpdateGetter,
    required void Function(University, DateTime) lastUpdateSetter,
    int cacheHours = 12,
  }) async {
    final dif = DateTime.now().difference(lastUpdateGetter(university)).inHours;
    final links = linksGetter(university);
    if (links.isNotEmpty && dif < cacheHours) {
      return true;
    }
    try {
      final fetched = await fetchData();
      for (final item in fetched) {
        (item as dynamic).university.value = university;
      }
      final cachedList = links.toList();
      final fetchedIds = fetched.map((e) => (e as dynamic).id as int).toList();
      final cachedIds = cachedList
          .map((e) => (e as dynamic).id as int)
          .toList();

      final newItems = fetched
          .where((e) => !cachedIds.contains((e as dynamic).id))
          .toList();
      final updatedItems = fetched
          .where((e) => cachedIds.contains((e as dynamic).id))
          .toList();
      final oldItems = cachedList
          .where((e) => !fetchedIds.contains((e as dynamic).id))
          .toList();

      await isar.writeTxn(() async {
        await collection.deleteAll(
          oldItems.map((e) => (e as dynamic).id as int).toList(),
        );

        await collection.putAll([...updatedItems, ...newItems]);

        await links.load();
        links.addAll([...updatedItems, ...newItems]);
        await links.save();
        lastUpdateSetter(university, DateTime.now());
        await isar.universitys.put(university);
      });
      return true;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }

  static Future<bool> cacheAudiences(University university) async {
    final api = universityApis[university.id];
    if (api == null) return false;
    return cacheEntityList<AudienceSchedule>(
      university: university,
      fetchData: api.getAudiencesData,
      collection: isar.audienceSchedules,
      linksGetter: (u) => u.audiences,
      lastUpdateGetter: (u) => u.lastUpdateAudiences,
      lastUpdateSetter: (u, dt) => u.lastUpdateAudiences = dt,
    );
  }

  static Future<bool> cacheGroups(University university) async {
    final api = universityApis[university.id];
    if (api == null) return false;
    return cacheEntityList<GroupSchedule>(
      university: university,
      fetchData: api.getGroupsData,
      collection: isar.groupSchedules,
      linksGetter: (u) => u.groups,
      lastUpdateGetter: (u) => u.lastUpdateGroups,
      lastUpdateSetter: (u, dt) => u.lastUpdateGroups = dt,
    );
  }

  static Future<bool> cacheTeachers(University university) async {
    final api = universityApis[university.id];
    if (api == null) return false;
    return cacheEntityList<TeacherSchedule>(
      university: university,
      fetchData: api.getProfessorsData,
      collection: isar.teacherSchedules,
      linksGetter: (u) => u.teachers,
      lastUpdateGetter: (u) => u.lastUpdateTeachers,
      lastUpdateSetter: (u, dt) => u.lastUpdateTeachers = dt,
    );
  }

  static Future<AudienceSchedule> cacheAudienceSchedule(
    University university,
    AudienceSchedule entity,
  ) async {
    final api = universityApis[university.id];
    if (api == null) return entity;
    if ((DateTime.now().difference(entity.lastUpdate).inHours > 12 ||
            entity.schedules.isEmpty) &&
        await isOnline.value) {
      try {
        final schedules = await api.getRaspsAudElementData(entity.id);
        await isar.writeTxn(() async {
          entity.lastUpdate = DateTime.now();
          entity.schedules = schedules;
          await isar.audienceSchedules.put(entity);
        });
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }
    return entity;
  }

  static Future<GroupSchedule> cacheGroupSchedule(
    University university,
    GroupSchedule entity,
  ) async {
    final api = universityApis[university.id];
    if (api == null) return entity;
    if ((DateTime.now().difference(entity.lastUpdate).inHours > 12 ||
            entity.schedules.isEmpty) &&
        await isOnline.value) {
      try {
        final schedules = await api.getRaspsGroupElementData(entity.id);
        await isar.writeTxn(() async {
          entity.lastUpdate = DateTime.now();
          entity.schedules = schedules;
          await isar.groupSchedules.put(entity);
        });
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }
    return entity;
  }

  static Future<TeacherSchedule> cacheTeacherSchedule(
    University university,
    TeacherSchedule entity,
  ) async {
    final api = universityApis[university.id];
    if (api == null) return entity;
    if ((DateTime.now().difference(entity.lastUpdate).inHours > 12 ||
            entity.schedules.isEmpty) &&
        await isOnline.value) {
      try {
        final schedules = await api.getRaspsProfElementData(entity.id);
        await isar.writeTxn(() async {
          entity.lastUpdate = DateTime.now();
          entity.schedules = schedules;
          await isar.teacherSchedules.put(entity);
        });
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }
    return entity;
  }
}
