/// Single schedule lesson slot for UI and cache consumers.
class Lesson {
  const Lesson({
    required this.date,
    this.begin = '',
    this.end = '',
    this.pair = -1,
    this.discipline = '',
    this.teacher = '',
    this.audience = '',
    this.group = '',
  });

  final DateTime date;
  final String begin;
  final String end;
  final int pair;
  final String discipline;
  final String teacher;
  final String audience;
  final String group;

  /// Returns a copy with selectively replaced fields.
  Lesson copyWith({
    DateTime? date,
    String? begin,
    String? end,
    int? pair,
    String? discipline,
    String? teacher,
    String? audience,
    String? group,
  }) => Lesson(
    date: date ?? this.date,
    begin: begin ?? this.begin,
    end: end ?? this.end,
    pair: pair ?? this.pair,
    discipline: discipline ?? this.discipline,
    teacher: teacher ?? this.teacher,
    audience: audience ?? this.audience,
    group: group ?? this.group,
  );
}
