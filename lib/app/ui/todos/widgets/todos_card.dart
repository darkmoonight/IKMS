import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:ikms/app/controller/todo_controller.dart';
import 'package:ikms/app/data/db.dart';
import 'package:ikms/app/utils/notification.dart';
import 'package:ikms/main.dart';
import 'package:intl/intl.dart';

class TodosCard extends StatefulWidget {
  const TodosCard({
    super.key,
    required this.todo,
    required this.onLongPress,
    required this.onTap,
  });
  final Todos todo;
  final Function() onLongPress;
  final Function() onTap;

  @override
  State<TodosCard> createState() => _TodosCardState();
}

class _TodosCardState extends State<TodosCard> {
  final todoController = Get.put(TodoController());

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, innerState) {
        return GestureDetector(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          child: Card(
            shape:
                todoController.isMultiSelectionTodo.isTrue &&
                    todoController.selectedTodo.contains(widget.todo)
                ? RoundedRectangleBorder(
                    side: BorderSide(
                      color: context.theme.colorScheme.onPrimaryContainer,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                  )
                : null,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Checkbox(
                    value: widget.todo.done,
                    shape: const CircleBorder(),
                    onChanged: (val) {
                      innerState(() {
                        widget.todo.done = val!;
                      });
                      widget.todo.done
                          ? flutterLocalNotificationsPlugin.cancel(
                              widget.todo.id,
                            )
                          : widget.todo.todoCompletedTime != null
                          ? NotificationShow().showNotification(
                              widget.todo.id,
                              widget.todo.name,
                              widget.todo.discipline,
                              widget.todo.todoCompletedTime,
                            )
                          : null;
                      Future.delayed(
                        const Duration(milliseconds: 300),
                        () => todoController.updateTodoCheck(widget.todo),
                      );
                    },
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.todo.name,
                          style: context.theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.visible,
                        ),
                        const Gap(3),
                        Text(
                          widget.todo.discipline,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.visible,
                        ),
                        const Gap(3),
                        widget.todo.todoCompletedTime != null
                            ? Text(
                                widget.todo.todoCompletedTime != null
                                    ? DateFormat.yMMMEd(
                                        locale.languageCode,
                                      ).add_Hm().format(
                                        widget.todo.todoCompletedTime!,
                                      )
                                    : '',
                                style: context.theme.textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
