import 'package:ikms/data/models/db.dart';
import 'package:ikms/domain/entities/lesson.dart';

/// Maps embedded Isar [Schedule] to domain [Lesson].
Lesson lessonFromSchedule(Schedule schedule) => Lesson(
  date: schedule.date,
  begin: schedule.begin,
  end: schedule.end,
  pair: schedule.pair,
  discipline: schedule.discipline,
  teacher: schedule.teacher,
  audience: schedule.audience,
  group: schedule.group,
);

/// Maps domain [Lesson] to embedded Isar [Schedule].
Schedule scheduleFromLesson(Lesson lesson) => Schedule(
  dateTime: lesson.date,
  begin: lesson.begin,
  end: lesson.end,
  pair: lesson.pair,
  discipline: lesson.discipline,
  teacher: lesson.teacher,
  audience: lesson.audience,
  group: lesson.group,
);

/// Maps a list of Isar schedules to lessons.
List<Lesson> lessonsFromSchedules(List<Schedule> schedules) =>
    schedules.map(lessonFromSchedule).toList();
