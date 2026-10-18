import 'package:ikms/domain/entities/lesson.dart';

/// Cached first/last calendar days and per-day event counts for a schedule.
class RaspDayIndex {
  /// Creates an index from precomputed bounds and counts.
  const RaspDayIndex({
    required this.firstDay,
    required this.lastDay,
    required this.eventCountsByDay,
  });

  /// Inclusive earliest schedule day (or [DateTime.now] when empty).
  final DateTime firstDay;

  /// Inclusive latest schedule day (or [DateTime.now] when empty).
  final DateTime lastDay;

  /// Unique pair counts keyed by date at midnight local.
  final Map<DateTime, int> eventCountsByDay;

  /// Builds an index from [items]; empty list uses "now" for both bounds.
  factory RaspDayIndex.fromLessons(List<Lesson> items) {
    if (items.isEmpty) {
      final now = DateTime.now();
      return RaspDayIndex(
        firstDay: now,
        lastDay: now,
        eventCountsByDay: const {},
      );
    }

    var minDate = items.first.date;
    var maxDate = items.first.date;
    final pairsByDay = <DateTime, Set<int>>{};

    for (final lesson in items) {
      if (lesson.date.isBefore(minDate)) minDate = lesson.date;
      if (lesson.date.isAfter(maxDate)) maxDate = lesson.date;
      final key = DateTime(
        lesson.date.year,
        lesson.date.month,
        lesson.date.day,
      );
      (pairsByDay[key] ??= <int>{}).add(lesson.pair);
    }

    return RaspDayIndex(
      firstDay: minDate,
      lastDay: maxDate,
      eventCountsByDay: {
        for (final entry in pairsByDay.entries) entry.key: entry.value.length,
      },
    );
  }

  /// Number of unique pairs on [date], or `0`.
  int eventCountFor(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    return eventCountsByDay[key] ?? 0;
  }
}
