import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ikms/core/di/provider_refs.dart';
import 'package:ikms/core/services/notification_service.dart';
import 'package:ikms/core/settings/app_settings_notifier.dart';
import 'package:ikms/core/utils/show_snack_bar.dart';
import 'package:ikms/domain/entities/todo_item.dart';
import 'package:ikms/i18n/tr.dart';

/// Immutable task feature state for multi-select and list rendering.
class TodoState {
  const TodoState({
    this.todos = const [],
    this.selectedTodo = const [],
    this.isMultiSelectionTodo = false,
    this.isPop = true,
  });

  final List<TodoItem> todos;
  final List<TodoItem> selectedTodo;
  final bool isMultiSelectionTodo;
  final bool isPop;

  /// Returns a copy with selectively replaced fields.
  TodoState copyWith({
    List<TodoItem>? todos,
    List<TodoItem>? selectedTodo,
    bool? isMultiSelectionTodo,
    bool? isPop,
  }) => TodoState(
    todos: todos ?? this.todos,
    selectedTodo: selectedTodo ?? this.selectedTodo,
    isMultiSelectionTodo: isMultiSelectionTodo ?? this.isMultiSelectionTodo,
    isPop: isPop ?? this.isPop,
  );
}

/// Provides task list state and CRUD actions.
final todoNotifierProvider = NotifierProvider<TodoNotifier, TodoState>(
  TodoNotifier.new,
);

/// Loads and mutates tasks with notification scheduling.
class TodoNotifier extends Notifier<TodoState> {
  @override
  TodoState build() {
    Future.microtask(loadTodos);
    return const TodoState();
  }

  /// Reloads tasks from the repository.
  Future<void> loadTodos() async {
    final todos = await ref.read(todoRepositoryProvider).getAll();
    state = state.copyWith(todos: todos);
  }

  /// Creates a task when it is not a duplicate.
  Future<void> addTodo(String title, String discipline, String time) async {
    DateTime? date;
    if (time.isNotEmpty) {
      date = parseDate(time);
    }
    if (await ref.read(todoRepositoryProvider).isDuplicate(title, discipline)) {
      showSnackBar('duplicateTodo'.tr, isError: true);
      return;
    }
    final created = await ref
        .read(todoRepositoryProvider)
        .put(
          TodoItem(
            id: 0,
            name: title,
            discipline: discipline,
            completedAt: date,
          ),
        );
    state = state.copyWith(todos: [...state.todos, created]);
    if (date != null && DateTime.now().isBefore(date)) {
      NotificationShow(ref.read(notificationsPluginProvider))
          .showNotification(created.id, created.name, created.discipline, date);
    }
    showSnackBar('todoCreate'.tr);
  }

  /// Parses a localized date-time string using the active locale.
  DateTime? parseDate(String time) {
    if (time.isEmpty) return null;
    final locale = ref.read(localeProvider);
    return DateFormat.yMMMEd(locale.languageCode).add_Hm().parse(time);
  }

  /// Persists a completed-flag change.
  Future<void> updateTodoCheck(TodoItem todo) async {
    final saved = await ref.read(todoRepositoryProvider).put(todo);
    final todos = [...state.todos];
    final idx = todos.indexWhere((t) => t.id == saved.id);
    if (idx >= 0) {
      todos[idx] = saved;
      state = state.copyWith(todos: todos);
    }
  }

  /// Updates task fields and reschedules notifications.
  Future<void> updateTodo(
    TodoItem todo,
    String title,
    String discipline,
    String time,
  ) async {
    DateTime? date;
    if (time.isNotEmpty) {
      date = parseDate(time);
    }
    final updated = todo.copyWith(
      name: title,
      discipline: discipline,
      completedAt: date,
      clearCompletedAt: time.isEmpty,
    );
    final saved = await ref.read(todoRepositoryProvider).put(updated);
    refreshTodo(saved);
    final plugin = ref.read(notificationsPluginProvider);
    if (date != null && DateTime.now().isBefore(date)) {
      await plugin.cancel(id: saved.id);
      NotificationShow(plugin)
          .showNotification(saved.id, saved.name, saved.discipline, date);
    } else {
      await plugin.cancel(id: saved.id);
    }
    showSnackBar('update'.tr);
  }

  /// Replaces a task instance in the in-memory list.
  void refreshTodo(TodoItem todo) {
    final todos = [...state.todos];
    final oldIdx = todos.indexWhere((t) => t.id == todo.id);
    if (oldIdx >= 0) {
      todos[oldIdx] = todo;
      state = state.copyWith(todos: todos);
    }
  }

  /// Deletes tasks and cancels their notifications.
  Future<void> deleteTodo(List<TodoItem> todoList) async {
    final plugin = ref.read(notificationsPluginProvider);
    final todoListCopy = List<TodoItem>.from(todoList);
    final ids = todoListCopy.map((t) => t.id).toSet();
    for (final todo in todoListCopy) {
      if (todo.completedAt != null &&
          todo.completedAt!.isAfter(DateTime.now())) {
        await plugin.cancel(id: todo.id);
      }
      await ref.read(todoRepositoryProvider).delete(todo.id);
    }
    state = state.copyWith(
      todos: state.todos.where((t) => !ids.contains(t.id)).toList(),
      selectedTodo: const [],
      isMultiSelectionTodo: false,
      isPop: true,
    );
    showSnackBar('todoDelete'.tr);
  }

  /// Toggles multi-selection membership for [item].
  void doMultiSelectionTodo(TodoItem todo) {
    if (!state.isMultiSelectionTodo) return;
    final selected = [...state.selectedTodo];
    final idx = selected.indexWhere((t) => t.id == todo.id);
    if (idx >= 0) {
      selected.removeAt(idx);
    } else {
      selected.add(todo);
    }
    state = state.copyWith(
      selectedTodo: selected,
      isMultiSelectionTodo: selected.isNotEmpty,
      isPop: selected.isEmpty,
    );
  }

  /// Clears multi-selection mode.
  void doMultiSelectionTodoClear() {
    state = state.copyWith(
      selectedTodo: const [],
      isMultiSelectionTodo: false,
      isPop: true,
    );
  }

  /// Enables multi-selection and selects [item].
  void startMultiSelection(TodoItem todo) {
    state = state.copyWith(
      isMultiSelectionTodo: true,
      selectedTodo: [todo],
      isPop: false,
    );
  }

  /// Returns whether every task in the [done] tab is selected.
  bool areAllSelectedInTab(bool done) {
    final tabTodos = state.todos.where((todo) => todo.done == done).toList();
    if (tabTodos.isEmpty) return false;
    return tabTodos.every(
      (todo) => state.selectedTodo.any((s) => s.id == todo.id),
    );
  }

  /// Selects or deselects all tasks in the [done] tab.
  void selectAllInTab({required bool select, required bool done}) {
    final tabTodos = state.todos.where((todo) => todo.done == done).toList();
    final selected = [...state.selectedTodo];
    if (select) {
      for (final todo in tabTodos) {
        if (!selected.any((s) => s.id == todo.id)) {
          selected.add(todo);
        }
      }
    } else {
      selected.removeWhere((todo) => todo.done == done);
    }
    state = state.copyWith(
      selectedTodo: selected,
      isMultiSelectionTodo: selected.isNotEmpty,
      isPop: selected.isEmpty,
    );
  }
}
