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
  final schedules = IsarLinks<Schedule>();

  ScheduleData({super.id, super.name, super.description});
}

@collection
class Settings {
  Id id = Isar.autoIncrement;
  bool theme = false;
  bool onboard = false;

  final university = IsarLink<University>();
  final group = IsarLink<GroupSchedule>();
}

@collection
class University extends SelectionData {
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

@collection
class Schedule {
  Id id = Isar.autoIncrement;
  late DateTime date;

  late String begin;
  late String end;
  late int pair;

  late String discipline;
  late String teacher;
  late String audience;
  late String group;

  Schedule({
    required this.date,
    required this.begin,
    required this.end,
    required this.pair,
    required this.discipline,
    required this.teacher,
    required this.audience,
    required this.group,
  });
}
