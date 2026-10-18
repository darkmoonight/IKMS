/// Local task item independent of Isar persistence.
class TodoItem {
  const TodoItem({
    required this.id,
    required this.name,
    required this.discipline,
    this.completedAt,
    this.done = false,
    this.index,
  });

  final int id;
  final String name;
  final String discipline;
  final DateTime? completedAt;
  final bool done;
  final int? index;

  /// Returns a copy with selectively replaced fields.
  TodoItem copyWith({
    int? id,
    String? name,
    String? discipline,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    bool? done,
    int? index,
  }) => TodoItem(
    id: id ?? this.id,
    name: name ?? this.name,
    discipline: discipline ?? this.discipline,
    completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    done: done ?? this.done,
    index: index ?? this.index,
  );
}
