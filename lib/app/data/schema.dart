import 'package:isar/isar.dart';

part 'schema.g.dart';

class SelectionData {
  Id id;
  String name;
  String description;

  SelectionData(
      {this.id = Isar.autoIncrement, this.name = '', this.description = ''});
}

class ScheduleData extends SelectionData {
  DateTime lastUpdate = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  final university = IsarLink<University>();

  List<Schedule> schedules = <Schedule>[];

  ScheduleData({super.id, super.name, super.description});
}

@collection
class University extends SelectionData {
  DateTime lastUpdateGroups =
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  DateTime lastUpdateTeachers =
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  DateTime lastUpdateAudiences =
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  @Backlink(to: 'university')
  final groups = IsarLinks<GroupSchedule>();
  @Backlink(to: 'university')
  final teachers = IsarLinks<TeacherSchedule>();
  @Backlink(to: 'university')
  final audiences = IsarLinks<AudienceSchedule>();

  University({super.id, super.name, super.description});
}

@collection
class GroupSchedule extends ScheduleData {
  GroupSchedule({super.id, super.name, super.description});

  GroupSchedule.fromSelectionData(SelectionData data)
      : super(
          id: data.id,
          name: data.name,
          description: data.description,
        );
}

@collection
class TeacherSchedule extends ScheduleData {
  TeacherSchedule({super.id, super.name, super.description});

  TeacherSchedule.fromSelectionData(SelectionData data)
      : super(
          id: data.id,
          name: data.name,
          description: data.description,
        );
}

@collection
class AudienceSchedule extends ScheduleData {
  AudienceSchedule({super.id, super.name, super.description});

  AudienceSchedule.fromSelectionData(SelectionData data)
      : super(
          id: data.id,
          name: data.name,
          description: data.description,
        );
}

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

@collection
class Settings {
  Id id = Isar.autoIncrement;
  bool? theme;
  bool materialColor = false;
  bool amoledTheme = false;
  String? language;

  final university = IsarLink<University>();
  final group = IsarLink<GroupSchedule>();
}

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
