import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:ikms/core/services/connectivity_service.dart';
import 'package:ikms/data/models/db.dart';
import 'package:ikms/data/universities/university_entity_id.dart';
import 'package:ikms/data/universities/university_registry.dart';

/// Caches schedule catalogs and entity schedules with a TTL policy.
class ScheduleRepository {
  ScheduleRepository(this._isar, {this.onSelectedGroupCleared});

  final Isar _isar;

  /// Called when a catalog sync deletes the currently selected group row.
  ///
  /// Settings persistence must go through [SettingsRepository.clearGroup] —
  /// this callback should not write Settings itself.
  final Future<void> Function()? onSelectedGroupCleared;

  static const int defaultCacheHours = 12;

  /// Whether [lastUpdate] is at least [cacheHours] old.
  static bool isStale(
    DateTime lastUpdate, {
    int cacheHours = defaultCacheHours,
  }) => DateTime.now().difference(lastUpdate).inHours >= cacheHours;

  /// Caches a typed selection list for [university] when stale or empty.
  ///
  /// Merges catalog names into existing Isar rows so embedded `schedules` are
  /// preserved. An empty fetch keeps the local catalog and does not advance TTL.
  Future<bool> cacheEntityList<T extends ScheduleData>({
    required University university,
    required Future<List<T>> Function() fetchData,
    required IsarCollection<T> collection,
    required IsarLinks<T> Function(University) linksGetter,
    required DateTime Function(University) lastUpdateGetter,
    required void Function(University, DateTime) lastUpdateSetter,
    int cacheHours = defaultCacheHours,
  }) async {
    final links = linksGetter(university);
    await links.load();
    if (links.isNotEmpty &&
        !isStale(lastUpdateGetter(university), cacheHours: cacheHours)) {
      return true;
    }
    try {
      final fetched = await fetchData();
      if (fetched.isEmpty) {
        return links.isNotEmpty;
      }

      final cachedList = links.toList();
      final cachedById = {for (final e in cachedList) e.id: e};
      final fetchedIds = <int>{};
      final toPut = <T>[];
      final newItems = <T>[];

      for (final item in fetched) {
        fetchedIds.add(item.id);
        final existing = cachedById[item.id];
        if (existing != null) {
          if (existing.name != item.name) {
            existing.name = item.name;
            toPut.add(existing);
          }
        } else {
          item.university.value = university;
          toPut.add(item);
          newItems.add(item);
        }
      }

      final oldIds = cachedList
          .where((e) => !fetchedIds.contains(e.id))
          .map((e) => e.id)
          .toList();

      var selectedGroupWasDeleted = false;
      if (oldIds.isNotEmpty && T == GroupSchedule) {
        final settings = await _isar.settings.where().findFirst();
        if (settings != null) {
          await settings.group.load();
          final selectedId = settings.group.value?.id;
          selectedGroupWasDeleted =
              selectedId != null && oldIds.contains(selectedId);
        }
      }

      await _isar.writeTxn(() async {
        if (oldIds.isNotEmpty) {
          await collection.deleteAll(oldIds);
        }
        if (toPut.isNotEmpty) {
          await collection.putAll(toPut);
        }
        for (final item in newItems) {
          await item.university.save();
        }
        lastUpdateSetter(university, DateTime.now());
        await _isar.universitys.put(university);
      });

      if (selectedGroupWasDeleted) {
        await onSelectedGroupCleared?.call();
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('$e');
      }
      return false;
    }
  }

  /// Refreshes audience catalog for [university].
  Future<bool> cacheAudiences(University university) async {
    final api = UniversityRegistry.apiFor(university.id);
    if (api == null) return false;
    return cacheEntityList<AudienceSchedule>(
      university: university,
      fetchData: api.getAudiencesData,
      collection: _isar.audienceSchedules,
      linksGetter: (u) => u.audiences,
      lastUpdateGetter: (u) => u.lastUpdateAudiences,
      lastUpdateSetter: (u, dt) => u.lastUpdateAudiences = dt,
    );
  }

  /// Refreshes group catalog for [university].
  Future<bool> cacheGroups(University university) async {
    final api = UniversityRegistry.apiFor(university.id);
    if (api == null) return false;
    return cacheEntityList<GroupSchedule>(
      university: university,
      fetchData: api.getGroupsData,
      collection: _isar.groupSchedules,
      linksGetter: (u) => u.groups,
      lastUpdateGetter: (u) => u.lastUpdateGroups,
      lastUpdateSetter: (u, dt) => u.lastUpdateGroups = dt,
    );
  }

  /// Refreshes teacher catalog for [university].
  Future<bool> cacheTeachers(University university) async {
    final api = UniversityRegistry.apiFor(university.id);
    if (api == null) return false;
    return cacheEntityList<TeacherSchedule>(
      university: university,
      fetchData: api.getProfessorsData,
      collection: _isar.teacherSchedules,
      linksGetter: (u) => u.teachers,
      lastUpdateGetter: (u) => u.lastUpdateTeachers,
      lastUpdateSetter: (u, dt) => u.lastUpdateTeachers = dt,
    );
  }

  /// Persists [schedules] on [entity] unless the fetch is empty.
  Future<void> _persistEntitySchedules<T extends ScheduleData>({
    required T entity,
    required List<Schedule> schedules,
    required Future<Id> Function(T) put,
  }) async {
    if (schedules.isEmpty) {
      return;
    }
    await _isar.writeTxn(() async {
      entity.lastUpdate = DateTime.now();
      entity.schedules = schedules;
      await put(entity);
    });
  }

  /// Refreshes a single audience schedule when stale or [forceRefresh] is true.
  Future<AudienceSchedule> cacheAudienceSchedule(
    University university,
    AudienceSchedule entity, {
    bool forceRefresh = false,
  }) async {
    final api = UniversityRegistry.apiFor(university.id);
    if (api == null) return entity;
    final stale =
        forceRefresh || isStale(entity.lastUpdate) || entity.schedules.isEmpty;
    if (stale && await ConnectivityService.isOnline.value) {
      try {
        final remoteId = UniversityEntityId.remoteId(entity.id);
        final schedules = await api.getRaspsAudElementData(remoteId);
        await _persistEntitySchedules(
          entity: entity,
          schedules: schedules,
          put: _isar.audienceSchedules.put,
        );
      } catch (e) {
        if (kDebugMode) {
          debugPrint('$e');
        }
      }
    }
    return entity;
  }

  /// Refreshes a single group schedule when stale or [forceRefresh] is true.
  Future<GroupSchedule> cacheGroupSchedule(
    University university,
    GroupSchedule entity, {
    bool forceRefresh = false,
  }) async {
    final api = UniversityRegistry.apiFor(university.id);
    if (api == null) return entity;
    final stale =
        forceRefresh || isStale(entity.lastUpdate) || entity.schedules.isEmpty;
    if (stale && await ConnectivityService.isOnline.value) {
      try {
        final remoteId = UniversityEntityId.remoteId(entity.id);
        final schedules = await api.getRaspsGroupElementData(remoteId);
        await _persistEntitySchedules(
          entity: entity,
          schedules: schedules,
          put: _isar.groupSchedules.put,
        );
      } catch (e) {
        if (kDebugMode) {
          debugPrint('$e');
        }
      }
    }
    return entity;
  }

  /// Refreshes a single teacher schedule when stale or [forceRefresh] is true.
  Future<TeacherSchedule> cacheTeacherSchedule(
    University university,
    TeacherSchedule entity, {
    bool forceRefresh = false,
  }) async {
    final api = UniversityRegistry.apiFor(university.id);
    if (api == null) return entity;
    final stale =
        forceRefresh || isStale(entity.lastUpdate) || entity.schedules.isEmpty;
    if (stale && await ConnectivityService.isOnline.value) {
      try {
        final remoteId = UniversityEntityId.remoteId(entity.id);
        final schedules = await api.getRaspsProfElementData(remoteId);
        await _persistEntitySchedules(
          entity: entity,
          schedules: schedules,
          put: _isar.teacherSchedules.put,
        );
      } catch (e) {
        if (kDebugMode) {
          debugPrint('$e');
        }
      }
    }
    return entity;
  }

  /// Loads audiences for [university], optionally requiring cached schedules offline.
  Future<List<AudienceSchedule>> getAudiences(
    University university, {
    required bool requireCachedSchedules,
  }) {
    return _isar.audienceSchedules
        .filter()
        .university((q) => q.idEqualTo(university.id))
        .optional(
          requireCachedSchedules,
          (q) => q.schedulesLengthGreaterThan(0),
        )
        .sortByLastUpdateDesc()
        .findAll();
  }

  /// Loads groups for [university], optionally requiring cached schedules offline.
  Future<List<GroupSchedule>> getGroups(
    University university, {
    required bool requireCachedSchedules,
  }) {
    return _isar.groupSchedules
        .filter()
        .university((q) => q.idEqualTo(university.id))
        .optional(
          requireCachedSchedules,
          (q) => q.schedulesLengthGreaterThan(0),
        )
        .sortByLastUpdateDesc()
        .findAll();
  }

  /// Loads teachers for [university], optionally requiring cached schedules offline.
  Future<List<TeacherSchedule>> getTeachers(
    University university, {
    required bool requireCachedSchedules,
  }) {
    return _isar.teacherSchedules
        .filter()
        .university((q) => q.idEqualTo(university.id))
        .optional(
          requireCachedSchedules,
          (q) => q.schedulesLengthGreaterThan(0),
        )
        .sortByLastUpdateDesc()
        .findAll();
  }

  /// Returns all universities in the local catalog.
  Future<List<University>> getUniversities() =>
      _isar.universitys.where().findAll();
}
