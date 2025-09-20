import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ikms/app/controller/todo_controller.dart';
import 'package:ikms/app/data/db.dart';
import 'package:ikms/app/ui/todos/widgets/todos_action.dart';
import 'package:ikms/app/ui/todos/widgets/todos_card.dart';
import 'package:ikms/app/ui/widgets/list_empty.dart';

class TodosList extends StatefulWidget {
  final bool done;
  final String searchTodo;

  const TodosList({
    super.key,
    required this.done,
    required this.searchTodo,
  });

  @override
  State<TodosList> createState() => _TodosListState();
}

class _TodosListState extends State<TodosList> {
  final _todoController = Get.find<TodoController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final filteredTodos = _filterTodos();

      if (filteredTodos.isEmpty) {
        return _buildEmptyState();
      }

      return _buildTodoList(filteredTodos);
    });
  }

  List<Todos> _filterTodos() {
    return _todoController.todos
        .where((todo) =>
    todo.done == widget.done &&
        (widget.searchTodo.isEmpty ||
            todo.name.toLowerCase().contains(widget.searchTodo.toLowerCase())))
        .toList();
  }

  Widget _buildEmptyState() {
    return ListEmpty(
      img: 'assets/images/add.png',
      text: widget.done ? 'completedTodo'.tr : 'addTodo'.tr,
    );
  }

  Widget _buildTodoList(List<Todos> todos) {
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        return _buildTodoItem(todos[index]);
      },
    );
  }

  Widget _buildTodoItem(Todos todo) {
    return TodosCard(
      key: ValueKey(todo.id),
      todo: todo,
      onTap: () => _handleTodoTap(todo),
      onLongPress: () => _handleTodoLongPress(todo),
    );
  }

  void _handleTodoTap(Todos todo) {
    if (_todoController.isMultiSelectionTodo.isTrue) {
      _todoController.doMultiSelectionTodo(todo);
    } else {
      _showTodoActions(todo);
    }
  }

  void _handleTodoLongPress(Todos todo) {
    _todoController.isMultiSelectionTodo.value = true;
    _todoController.doMultiSelectionTodo(todo);
  }

  void _showTodoActions(Todos todo) {
    showModalBottomSheet(
      enableDrag: false,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return TodosAction(
          text: 'editing'.tr,
          edit: true,
          todo: todo,
        );
      },
    );
  }
}
