import 'package:ikms/domain/entities/catalog_refs.dart';
import 'package:ikms/domain/entities/lesson.dart';

/// Port for university catalog cache and lesson schedules.
abstract class ScheduleCachePort {
  /// Ensures universities are seeded; returns catalog refs.
  Future<List<UniversityRef>> ensureUniversities();

  /// Refreshes and returns groups for [universityId].
  Future<List<GroupRef>> cacheGroups(int universityId);

  /// Refreshes and returns teachers for [universityId].
  Future<List<TeacherRef>> cacheTeachers(int universityId);

  /// Refreshes and returns audiences for [universityId].
  Future<List<AudienceRef>> cacheAudiences(int universityId);

  /// Loads (and refreshes when stale) lessons for a group.
  Future<List<Lesson>> cacheGroupLessons(
    int universityId,
    int groupId, {
    bool forceRefresh = false,
  });

  /// Loads lessons for a teacher.
  Future<List<Lesson>> cacheTeacherLessons(
    int universityId,
    int teacherId, {
    bool forceRefresh = false,
  });

  /// Loads lessons for an audience.
  Future<List<Lesson>> cacheAudienceLessons(
    int universityId,
    int audienceId, {
    bool forceRefresh = false,
  });

  /// Distinct discipline names from the selected group's cached schedule.
  Future<List<String>> disciplineNamesForSelectedGroup();
}
