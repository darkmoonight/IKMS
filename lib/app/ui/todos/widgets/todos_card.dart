import 'package:flutter/material.dart';
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

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = date.difference(now);

    if (diff.inDays > 7) {
      return DateFormat('dd MMM, HH:mm', locale.languageCode).format(date);
    } else if (diff.inDays > 0) {
      return '${'through'.tr} ${diff.inDays} ${'days_short'.tr}';
    } else if (diff.inHours > 0) {
      return '${'through'.tr} ${diff.inHours} ${'hours_short'.tr}';
    } else if (diff.inMinutes > 0) {
      return '${'through'.tr} ${diff.inMinutes} ${'minutes_short'.tr}';
    } else {
      return 'overdue'.tr;
    }
  }

  Color _getDeadlineColor(Todos todo) {
    if (todo.done) return context.theme.colorScheme.onSurfaceVariant;
    if (todo.todoCompletedTime == null) {
      return context.theme.colorScheme.onSurfaceVariant;
    }

    final diff = todo.todoCompletedTime!.difference(DateTime.now());
    if (diff.inDays < 1) {
      return context.theme.colorScheme.error;
    } else if (diff.inDays < 3) {
      return context.theme.colorScheme.tertiary;
    }
    return context.theme.colorScheme.onSurfaceVariant;
  }

  @override
  Widget build(BuildContext context) {
    final isSelected =
        _todoController.isMultiSelectionTodo.isTrue &&
        _todoController.selectedTodo.contains(widget.todo);

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Card(
        shape: isSelected
            ? RoundedRectangleBorder(
                side: BorderSide(
                  color: context.theme.colorScheme.primary,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Checkbox(
                value: widget.todo.done,
                shape: const CircleBorder(),
                onChanged: _handleCheckboxChanged,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      widget.todo.name,
                      style: context.theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: widget.todo.done
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.todo.discipline,
                            style: context.theme.textTheme.labelSmall?.copyWith(
                              color: context.theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.todo.todoCompletedTime != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  _getDeadlineColor(widget.todo) ==
                                      context.theme.colorScheme.error
                                  ? context.theme.colorScheme.errorContainer
                                  : context.theme.colorScheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _formatDate(widget.todo.todoCompletedTime),
                              style: context.theme.textTheme.labelSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color:
                                        _getDeadlineColor(widget.todo) ==
                                            context.theme.colorScheme.error
                                        ? context
                                              .theme
                                              .colorScheme
                                              .onErrorContainer
                                        : context
                                              .theme
                                              .colorScheme
                                              .onTertiaryContainer,
                                  ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleCheckboxChanged(bool? value) async {
    if (value == null) return;

    setState(() => widget.todo.done = value);

    if (value) {
      await flutterLocalNotificationsPlugin.cancel(id: widget.todo.id);
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
      () async => await _todoController.updateTodoCheck(widget.todo),
    );
  }
}
