import 'package:flutter_test/flutter_test.dart';
import 'package:ikms/domain/entities/lesson.dart';
import 'package:ikms/features/schedule/presentation/widgets/rasp_day_index.dart';

void main() {
  test('empty schedules use now for both bounds', () {
    final index = RaspDayIndex.fromLessons(const []);
    expect(index.eventCountsByDay, isEmpty);
    expect(index.firstDay.day, DateTime.now().day);
    expect(index.lastDay.day, DateTime.now().day);
  });

  test('indexes min/max days and unique pair counts', () {
    final day1 = DateTime(2026, 10, 1, 10);
    final day2 = DateTime(2026, 10, 3, 12);
    final items = [
      Lesson(date: day1, pair: 1, discipline: 'A'),
      Lesson(date: day1, pair: 1, discipline: 'B'),
      Lesson(date: day1, pair: 2, discipline: 'C'),
      Lesson(date: day2, pair: 1, discipline: 'D'),
    ];

    final index = RaspDayIndex.fromLessons(items);

    expect(index.firstDay, day1);
    expect(index.lastDay, day2);
    expect(index.eventCountFor(DateTime(2026, 10, 1)), 2);
    expect(index.eventCountFor(DateTime(2026, 10, 3)), 1);
    expect(index.eventCountFor(DateTime(2026, 10, 2)), 0);
  });
}
