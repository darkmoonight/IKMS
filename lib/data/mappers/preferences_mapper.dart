import 'package:ikms/data/models/db.dart';
import 'package:ikms/domain/entities/app_preferences.dart';
import 'package:ikms/domain/entities/catalog_refs.dart';

/// Maps Isar [Settings] (+ loaded links) to [AppPreferences].
AppPreferences preferencesFromSettings(Settings settings) {
  final university = settings.university.value;
  final group = settings.group.value;
  return AppPreferences(
    theme: settings.theme ?? 'system',
    amoledTheme: settings.amoledTheme,
    materialColor: settings.materialColor,
    adsDisabled: settings.ads ?? false,
    languageCode: settings.language,
    university: university == null
        ? null
        : UniversityRef(id: university.id, name: university.name),
    group: group == null
        ? null
        : GroupRef(
            id: group.id,
            name: group.name,
            universityId: university?.id ?? group.university.value?.id ?? 0,
          ),
  );
}

/// Maps Isar [University] to [UniversityRef].
UniversityRef universityRefFromIsar(University university) =>
    UniversityRef(id: university.id, name: university.name);

/// Maps Isar [GroupSchedule] to [GroupRef].
GroupRef groupRefFromIsar(GroupSchedule group) => GroupRef(
  id: group.id,
  name: group.name,
  universityId: group.university.value?.id ?? 0,
);

/// Maps Isar [TeacherSchedule] to [TeacherRef].
TeacherRef teacherRefFromIsar(TeacherSchedule teacher, int universityId) =>
    TeacherRef(id: teacher.id, name: teacher.name, universityId: universityId);

/// Maps Isar [AudienceSchedule] to [AudienceRef].
AudienceRef audienceRefFromIsar(AudienceSchedule audience, int universityId) =>
    AudienceRef(
      id: audience.id,
      name: audience.name,
      universityId: universityId,
    );
