import 'package:isar_community/isar.dart';

part 'db.g.dart';

/// Shared identity fields for selectable catalog entities.
class SelectionData {
  Id id;
  String name;
  String description;

  SelectionData({
    this.id = Isar.autoIncrement,
    this.name = '',
    this.description = '',
  });
}

/// Catalog entity that owns a list of [Schedule] lessons and a university link.
class ScheduleData extends SelectionData {
  DateTime lastUpdate = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  final university = IsarLink<University>();

  List<Schedule> schedules = <Schedule>[];

  ScheduleData({super.id, super.name, super.description});
}

/// University entry with cached group/teacher/audience catalogs.
@collection
class University extends SelectionData {
  DateTime lastUpdateGroups = DateTime.fromMillisecondsSinceEpoch(
    0,
    isUtc: true,
  );
  DateTime lastUpdateTeachers = DateTime.fromMillisecondsSinceEpoch(
    0,
    isUtc: true,
  );
  DateTime lastUpdateAudiences = DateTime.fromMillisecondsSinceEpoch(
    0,
    isUtc: true,
  );

  @Backlink(to: 'university')
  final groups = IsarLinks<GroupSchedule>();
  @Backlink(to: 'university')
  final teachers = IsarLinks<TeacherSchedule>();
  @Backlink(to: 'university')
  final audiences = IsarLinks<AudienceSchedule>();

  University({super.id, super.name, super.description});
}

/// Group schedule entity linked to a [University].
@collection
class GroupSchedule extends ScheduleData {
  GroupSchedule({super.id, super.name, super.description});
}

/// Teacher schedule entity linked to a [University].
@collection
class TeacherSchedule extends ScheduleData {
  TeacherSchedule({super.id, super.name, super.description});
}

/// Audience schedule entity linked to a [University].
@collection
class AudienceSchedule extends ScheduleData {
  AudienceSchedule({super.id, super.name, super.description});
}

/// Single lesson slot embedded in group/teacher/audience schedules.
@embedded
class Schedule {
  DateTime date;

  String begin;
  String end;
  int pair;

  String discipline;
  String teacher;
  String audience;
  String group;

  Schedule({
    DateTime? dateTime,
    this.begin = '',
    this.end = '',
    this.pair = -1,
    this.discipline = '',
    this.teacher = '',
    this.audience = '',
    this.group = '',
  }) : date = dateTime ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
}

/// Persisted user preferences and selected university/group links.
@collection
class Settings {
  Id id = Isar.autoIncrement;
  String? theme = 'system';
  bool materialColor = false;
  bool amoledTheme = false;
  bool? ads = false;
  String? language;

  final university = IsarLink<University>();
  final group = IsarLink<GroupSchedule>();
}

/// Local todo item with optional completion deadline.
@collection
class Todos {
  Id id;
  String name;
  String discipline;
  DateTime? todoCompletedTime;
  int? index;
  bool done;

  Todos({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.discipline,
    this.todoCompletedTime,
    this.done = false,
    this.index,
  });
}
