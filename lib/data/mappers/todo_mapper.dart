import 'package:isar_community/isar.dart';
import 'package:ikms/data/models/db.dart';
import 'package:ikms/domain/entities/todo_item.dart';

/// Maps Isar [Todos] to domain [TodoItem].
TodoItem todoItemFromIsar(Todos todo) => TodoItem(
  id: todo.id,
  name: todo.name,
  discipline: todo.discipline,
  completedAt: todo.todoCompletedTime,
  done: todo.done,
  index: todo.index,
);

/// Maps domain [TodoItem] to Isar [Todos] (for put).
Todos todosFromTodoItem(TodoItem item) => Todos(
  id: item.id > 0 ? item.id : Isar.autoIncrement,
  name: item.name,
  discipline: item.discipline,
  todoCompletedTime: item.completedAt,
  done: item.done,
  index: item.index,
);
