import 'package:isar_community/isar.dart';
import 'package:ikms/data/mappers/todo_mapper.dart';
import 'package:ikms/data/models/db.dart';
import 'package:ikms/domain/entities/todo_item.dart';
import 'package:ikms/domain/repositories/todo_repository.dart';

/// Isar-backed [TodoRepository].
class TodosRepository implements TodoRepository {
  TodosRepository(this._isar);

  final Isar _isar;

  @override
  Future<List<TodoItem>> getAll() async {
    final rows = await _isar.todos.where().findAll();
    return rows.map(todoItemFromIsar).toList();
  }

  @override
  Future<TodoItem> put(TodoItem todo) async {
    final row = todosFromTodoItem(todo);
    await _isar.writeTxn(() => _isar.todos.put(row));
    return todoItemFromIsar(row);
  }

  @override
  Future<void> delete(int id) async {
    await _isar.writeTxn(() => _isar.todos.delete(id));
  }

  @override
  Future<bool> isDuplicate(String title, String discipline) async {
    final matches = await _isar.todos
        .filter()
        .nameEqualTo(title)
        .disciplineEqualTo(discipline)
        .findAll();
    return matches.isNotEmpty;
  }
}
