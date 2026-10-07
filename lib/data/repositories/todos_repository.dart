import 'package:isar_community/isar.dart';
import 'package:ikms/data/models/db.dart';

/// CRUD access for [Todos] stored in Isar.
class TodosRepository {
  TodosRepository(this._isar);

  final Isar _isar;

  /// Loads all todos.
  Future<List<Todos>> getAll() => _isar.todos.where().findAll();

  /// Inserts or updates a todo.
  Future<void> put(Todos todo) async {
    await _isar.writeTxn(() => _isar.todos.put(todo));
  }

  /// Deletes a todo by id.
  Future<void> delete(int id) async {
    await _isar.writeTxn(() => _isar.todos.delete(id));
  }

  /// Returns true when a todo with the same name and discipline exists.
  Future<bool> isDuplicate(String title, String discipline) async {
    final matches = await _isar.todos
        .filter()
        .nameEqualTo(title)
        .disciplineEqualTo(discipline)
        .findAll();
    return matches.isNotEmpty;
  }
}
