import 'package:isar_community/isar.dart';
import 'package:ikms/data/mappers/lesson_mapper.dart';
import 'package:ikms/data/mappers/preferences_mapper.dart';
import 'package:ikms/data/models/db.dart';
import 'package:ikms/data/repositories/schedule_repository.dart';
import 'package:ikms/data/universities/university_registry.dart';
import 'package:ikms/domain/entities/catalog_refs.dart';
import 'package:ikms/domain/entities/lesson.dart';
import 'package:ikms/domain/repositories/schedule_cache_port.dart';

/// Isar-backed [ScheduleCachePort] over [ScheduleRepository].
class IsarScheduleCachePort implements ScheduleCachePort {
  /// Creates the schedule cache adapter.
  IsarScheduleCachePort(
    this._isar,
    this._scheduleRepository, {
    required this._selectedGroupId,
    required this._selectedUniversityId,
  });

  final Isar _isar;
  final ScheduleRepository _scheduleRepository;
  final int? Function() _selectedGroupId;
  final int? Function() _selectedUniversityId;

  Future<University> _requireUniversity(int universityId) async {
    final university = await _isar.universitys.get(universityId);
    if (university == null) {
      throw StateError('University $universityId not found');
    }
    return university;
  }

  @override
  Future<List<UniversityRef>> ensureUniversities() async {
    await UniversityRegistry.ensureSeeded(_isar);
    final rows = await _scheduleRepository.getUniversities();
    return rows.map(universityRefFromIsar).toList();
  }

  @override
  Future<List<GroupRef>> cacheGroups(int universityId) async {
    final university = await _requireUniversity(universityId);
    await _scheduleRepository.cacheGroups(university);
    final rows = await _scheduleRepository.getGroups(
      university,
      requireCachedSchedules: false,
    );
    return [
      for (final g in rows)
        GroupRef(id: g.id, name: g.name, universityId: universityId),
    ];
  }

  @override
  Future<List<TeacherRef>> cacheTeachers(int universityId) async {
    final university = await _requireUniversity(universityId);
    await _scheduleRepository.cacheTeachers(university);
    final rows = await _scheduleRepository.getTeachers(
      university,
      requireCachedSchedules: false,
    );
    return [for (final t in rows) teacherRefFromIsar(t, universityId)];
  }

  @override
  Future<List<AudienceRef>> cacheAudiences(int universityId) async {
    final university = await _requireUniversity(universityId);
    await _scheduleRepository.cacheAudiences(university);
    final rows = await _scheduleRepository.getAudiences(
      university,
      requireCachedSchedules: false,
    );
    return [for (final a in rows) audienceRefFromIsar(a, universityId)];
  }

  @override
  Future<List<Lesson>> cacheGroupLessons(
    int universityId,
    int groupId, {
    bool forceRefresh = false,
  }) async {
    final university = await _requireUniversity(universityId);
    final group = await _isar.groupSchedules.get(groupId);
    if (group == null) return const [];
    final updated = await _scheduleRepository.cacheGroupSchedule(
      university,
      group,
      forceRefresh: forceRefresh,
    );
    return lessonsFromSchedules(updated.schedules);
  }

  @override
  Future<List<Lesson>> cacheTeacherLessons(
    int universityId,
    int teacherId, {
    bool forceRefresh = false,
  }) async {
    final university = await _requireUniversity(universityId);
    final teacher = await _isar.teacherSchedules.get(teacherId);
    if (teacher == null) return const [];
    final updated = await _scheduleRepository.cacheTeacherSchedule(
      university,
      teacher,
      forceRefresh: forceRefresh,
    );
    return lessonsFromSchedules(updated.schedules);
  }

  @override
  Future<List<Lesson>> cacheAudienceLessons(
    int universityId,
    int audienceId, {
    bool forceRefresh = false,
  }) async {
    final university = await _requireUniversity(universityId);
    final audience = await _isar.audienceSchedules.get(audienceId);
    if (audience == null) return const [];
    final updated = await _scheduleRepository.cacheAudienceSchedule(
      university,
      audience,
      forceRefresh: forceRefresh,
    );
    return lessonsFromSchedules(updated.schedules);
  }

  @override
  Future<List<String>> disciplineNamesForSelectedGroup() async {
    final universityId = _selectedUniversityId();
    final groupId = _selectedGroupId();
    if (universityId == null || groupId == null) return const [];
    final lessons = await cacheGroupLessons(universityId, groupId);
    final seen = <String>{};
    final names = <String>[];
    for (final lesson in lessons) {
      if (lesson.discipline.isEmpty) continue;
      if (seen.add(lesson.discipline)) {
        names.add(lesson.discipline);
      }
    }
    names.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return names;
  }
}
