import 'package:ikms/domain/entities/todo_item.dart';

/// Port for local task CRUD.
abstract class TodoRepository {
  /// Loads all tasks.
  Future<List<TodoItem>> getAll();

  /// Inserts or updates [item]; returns the persisted row (with id).
  Future<TodoItem> put(TodoItem todo);

  /// Deletes a task by [id].
  Future<void> delete(int id);

  /// Whether a task with the same name and discipline already exists.
  Future<bool> isDuplicate(String title, String discipline);
}
