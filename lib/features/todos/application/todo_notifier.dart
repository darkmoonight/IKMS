import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ikms/core/di/provider_refs.dart';
import 'package:ikms/core/services/notification_service.dart';
import 'package:ikms/core/settings/app_settings_notifier.dart';
import 'package:ikms/core/utils/show_snack_bar.dart';
import 'package:ikms/data/models/db.dart';
import 'package:ikms/i18n/tr.dart';

/// Immutable todo feature state for multi-select and list rendering.
class TodoState {
  const TodoState({
    this.todos = const [],
    this.selectedTodo = const [],
    this.isMultiSelectionTodo = false,
    this.isPop = true,
  });

  final List<Todos> todos;
  final List<Todos> selectedTodo;
  final bool isMultiSelectionTodo;
  final bool isPop;

  /// Returns a copy with selectively replaced fields.
  TodoState copyWith({
    List<Todos>? todos,
    List<Todos>? selectedTodo,
    bool? isMultiSelectionTodo,
    bool? isPop,
  }) => TodoState(
    todos: todos ?? this.todos,
    selectedTodo: selectedTodo ?? this.selectedTodo,
    isMultiSelectionTodo: isMultiSelectionTodo ?? this.isMultiSelectionTodo,
    isPop: isPop ?? this.isPop,
  );
}

/// Provides todo list state and CRUD actions.
final todoNotifierProvider = NotifierProvider<TodoNotifier, TodoState>(
  TodoNotifier.new,
);

/// Loads and mutates todos with notification scheduling.
class TodoNotifier extends Notifier<TodoState> {
  @override
  TodoState build() {
    Future.microtask(loadTodos);
    return const TodoState();
  }

  /// Reloads todos from Isar.
  Future<void> loadTodos() async {
    final todos = await ref.read(todosRepositoryProvider).getAll();
    state = state.copyWith(todos: todos);
  }

  /// Creates a todo when it is not a duplicate.
  Future<void> addTodo(String title, Schedule discipline, String time) async {
    DateTime? date;
    if (time.isNotEmpty) {
      date = parseDate(time);
    }
    if (await ref
        .read(todosRepositoryProvider)
        .isDuplicate(title, discipline.discipline)) {
      showSnackBar('duplicateTodo'.tr, isError: true);
      return;
    }
    final todosCreate = Todos(
      name: title,
      discipline: discipline.discipline,
      todoCompletedTime: date,
    );
    await ref.read(todosRepositoryProvider).put(todosCreate);
    state = state.copyWith(todos: [...state.todos, todosCreate]);
    if (date != null && DateTime.now().isBefore(date)) {
      NotificationShow(ref.read(notificationsPluginProvider)).showNotification(
        todosCreate.id,
        todosCreate.name,
        todosCreate.discipline,
        date,
      );
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
  Future<void> updateTodoCheck(Todos todo) async {
    await ref.read(todosRepositoryProvider).put(todo);
    state = state.copyWith(todos: [...state.todos]);
  }

  /// Updates todo fields and reschedules notifications.
  Future<void> updateTodo(
    Todos todo,
    String title,
    Schedule discipline,
    String time,
  ) async {
    DateTime? date;
    if (time.isNotEmpty) {
      date = parseDate(time);
    }
    todo.name = title;
    todo.discipline = discipline.discipline;
    todo.todoCompletedTime = date;
    await ref.read(todosRepositoryProvider).put(todo);
    refreshTodo(todo);
    final plugin = ref.read(notificationsPluginProvider);
    if (date != null && DateTime.now().isBefore(date)) {
      await plugin.cancel(id: todo.id);
      NotificationShow(plugin)
          .showNotification(todo.id, todo.name, todo.discipline, date);
    } else {
      await plugin.cancel(id: todo.id);
    }
    showSnackBar('update'.tr);
  }

  /// Replaces a todo instance in the in-memory list.
  void refreshTodo(Todos todo) {
    final todos = [...state.todos];
    final oldIdx = todos.indexOf(todo);
    if (oldIdx >= 0) {
      todos[oldIdx] = todo;
      state = state.copyWith(todos: todos);
    }
  }

  /// Deletes todos and cancels their notifications.
  Future<void> deleteTodo(List<Todos> todoList) async {
    final plugin = ref.read(notificationsPluginProvider);
    final todoListCopy = List<Todos>.from(todoList);
    for (final todo in todoListCopy) {
      if (todo.todoCompletedTime != null &&
          todo.todoCompletedTime!.isAfter(DateTime.now())) {
        await plugin.cancel(id: todo.id);
      }
      await ref.read(todosRepositoryProvider).delete(todo.id);
    }
    state = state.copyWith(
      todos: state.todos.where((t) => !todoListCopy.contains(t)).toList(),
      selectedTodo: const [],
      isMultiSelectionTodo: false,
      isPop: true,
    );
    showSnackBar('todoDelete'.tr);
  }

  /// Toggles multi-selection membership for [todo].
  void doMultiSelectionTodo(Todos todo) {
    if (!state.isMultiSelectionTodo) return;
    final selected = [...state.selectedTodo];
    if (selected.contains(todo)) {
      selected.remove(todo);
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

  /// Enables multi-selection and selects [todo].
  void startMultiSelection(Todos todo) {
    state = state.copyWith(
      isMultiSelectionTodo: true,
      selectedTodo: [todo],
      isPop: false,
    );
  }

  /// Returns whether every todo in the [done] tab is selected.
  bool areAllSelectedInTab(bool done) {
    final tabTodos = state.todos.where((todo) => todo.done == done).toList();
    if (tabTodos.isEmpty) return false;
    return tabTodos.every((todo) => state.selectedTodo.contains(todo));
  }

  /// Selects or deselects all todos in the [done] tab.
  void selectAllInTab({required bool select, required bool done}) {
    final tabTodos = state.todos.where((todo) => todo.done == done).toList();
    final selected = [...state.selectedTodo];
    if (select) {
      for (final todo in tabTodos) {
        if (!selected.contains(todo)) {
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
