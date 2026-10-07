import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikms/core/widgets/list_empty.dart';
import 'package:ikms/data/models/db.dart';
import 'package:ikms/features/todos/application/todo_notifier.dart';
import 'package:ikms/features/todos/presentation/widgets/todos_action.dart';
import 'package:ikms/features/todos/presentation/widgets/todos_card.dart';
import 'package:ikms/i18n/tr.dart';
import 'package:material_ui/material_ui.dart';

/// Filtered list of todos for a doing/done tab.
class TodosList extends ConsumerWidget {
  /// Creates a todos list for [done] status filtered by [searchTodo].
  const TodosList({super.key, required this.done, required this.searchTodo});

  /// Whether to show completed todos.
  final bool done;

  /// Case-insensitive name filter.
  final String searchTodo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoState = ref.watch(todoNotifierProvider);
    final filteredTodos = _filterTodos(todoState.todos);

    if (filteredTodos.isEmpty) {
      return _buildEmptyState();
    }

    return _buildTodoList(context, ref, filteredTodos, todoState);
  }

  List<Todos> _filterTodos(List<Todos> todos) => todos
      .where(
        (todo) =>
            todo.done == done &&
            (searchTodo.isEmpty ||
                todo.name.toLowerCase().contains(searchTodo.toLowerCase())),
      )
      .toList();

  Widget _buildEmptyState() => ListEmpty(
    img: 'assets/images/add.png',
    text: done ? 'completedTodo'.tr : 'addTodo'.tr,
  );

  Widget _buildTodoList(
    BuildContext context,
    WidgetRef ref,
    List<Todos> todos,
    TodoState todoState,
  ) => ListView.builder(
    itemCount: todos.length,
    itemBuilder: (context, index) =>
        _buildTodoItem(context, ref, todos[index], todoState),
  );

  Widget _buildTodoItem(
    BuildContext context,
    WidgetRef ref,
    Todos todo,
    TodoState todoState,
  ) => TodosCard(
    key: ValueKey(todo.id),
    todo: todo,
    onTap: () => _handleTodoTap(context, ref, todo, todoState),
    onLongPress: () =>
        ref.read(todoNotifierProvider.notifier).startMultiSelection(todo),
  );

  void _handleTodoTap(
    BuildContext context,
    WidgetRef ref,
    Todos todo,
    TodoState todoState,
  ) {
    if (todoState.isMultiSelectionTodo) {
      ref.read(todoNotifierProvider.notifier).doMultiSelectionTodo(todo);
    } else {
      _showTodoActions(context, todo);
    }
  }

  void _showTodoActions(BuildContext context, Todos todo) =>
      showModalBottomSheet(
        enableDrag: false,
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) =>
            TodosAction(text: 'editing'.tr, edit: true, todo: todo),
      );
}
