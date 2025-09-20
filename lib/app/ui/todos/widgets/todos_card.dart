import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:ikms/app/controller/todo_controller.dart';
import 'package:ikms/app/data/db.dart';
import 'package:ikms/app/utils/notification.dart';
import 'package:ikms/main.dart';
import 'package:intl/intl.dart';

class TodosCard extends StatefulWidget {
  final Todos todo;
  final VoidCallback onLongPress;
  final VoidCallback onTap;

  const TodosCard({
    super.key,
    required this.todo,
    required this.onLongPress,
    required this.onTap,
  });

  @override
  State<TodosCard> createState() => _TodosCardState();
}

class _TodosCardState extends State<TodosCard> {
  final _todoController = Get.find<TodoController>();
  final _dateFormatter = DateFormat.yMMMEd(locale.languageCode).add_Hm();

  @override
  Widget build(BuildContext context) {
    final isSelected = _todoController.isMultiSelectionTodo.isTrue &&
        _todoController.selectedTodo.contains(widget.todo);

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Card(
        shape: isSelected
            ? RoundedRectangleBorder(
          side: BorderSide(
            color: context.theme.colorScheme.onPrimaryContainer,
          ),
          borderRadius: BorderRadius.circular(20),
        )
            : null,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              _buildCheckbox(),
              const Gap(8),
              _buildTodoContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox() {
    return Checkbox(
      value: widget.todo.done,
      shape: const CircleBorder(),
      onChanged: _handleCheckboxChanged,
    );
  }

  Widget _buildTodoContent() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTodoTitle(),
          const Gap(3),
          _buildTodoDiscipline(),
          const Gap(3),
          _buildTodoDeadline(),
        ],
      ),
    );
  }

  Widget _buildTodoTitle() {
    return Text(
      widget.todo.name,
      style: context.theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      overflow: TextOverflow.visible,
    );
  }

  Widget _buildTodoDiscipline() {
    return Text(
      widget.todo.discipline,
      style: context.theme.textTheme.bodySmall?.copyWith(
        color: Colors.grey,
      ),
      overflow: TextOverflow.visible,
    );
  }

  Widget _buildTodoDeadline() {
    if (widget.todo.todoCompletedTime == null) {
      return const SizedBox.shrink();
    }

    return Text(
      _dateFormatter.format(widget.todo.todoCompletedTime!),
      style: context.theme.textTheme.bodySmall?.copyWith(
        color: Colors.grey,
      ),
    );
  }

  Future<void> _handleCheckboxChanged(bool? value) async {
    if (value == null) return;

    setState(() {
      widget.todo.done = value;
    });

    if (value) {
      await flutterLocalNotificationsPlugin.cancel(widget.todo.id);
    } else if (widget.todo.todoCompletedTime != null) {
      await NotificationShow().showNotification(
        widget.todo.id,
        widget.todo.name,
        widget.todo.discipline,
        widget.todo.todoCompletedTime,
      );
    }

    Future.delayed(
      const Duration(milliseconds: 300),
          () => _todoController.updateTodoCheck(widget.todo),
    );
  }
}
