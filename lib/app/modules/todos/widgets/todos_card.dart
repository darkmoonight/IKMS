import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ikms/app/controller/todo_controller.dart';
import 'package:ikms/app/data/schema.dart';
import 'package:ikms/app/modules/todos/widgets/todos_action.dart';
import 'package:ikms/app/services/notification.dart';
import 'package:intl/intl.dart';
import '../../../../main.dart';

class TodosCard extends StatefulWidget {
  const TodosCard({
    super.key,
    required this.todos,
  });
  final Todos todos;

  @override
  State<TodosCard> createState() => _TodosCardState();
}

class _TodosCardState extends State<TodosCard> {
  final todoController = Get.put(TodoController());

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, innerState) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                showModalBottomSheet(
                  enableDrag: false,
                  context: context,
                  isScrollControlled: true,
                  builder: (BuildContext context) {
                    return TodosAction(
                      text: 'editing'.tr,
                      edit: true,
                      todo: widget.todos,
                    );
                  },
                );
              },
              child: Row(
                children: [
                  Checkbox(
                    value: widget.todos.done,
                    shape: const CircleBorder(),
                    onChanged: (val) {
                      innerState(() {
                        widget.todos.done = val!;
                      });
                      widget.todos.done
                          ? flutterLocalNotificationsPlugin
                              .cancel(widget.todos.id)
                          : widget.todos.todoCompletedTime != null
                              ? NotificationShow().showNotification(
                                  widget.todos.id,
                                  widget.todos.name,
                                  widget.todos.discipline,
                                  widget.todos.todoCompletedTime,
                                )
                              : null;
                      Future.delayed(const Duration(milliseconds: 300),
                          () => todoController.updateTodoCheck(widget.todos));
                    },
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.todos.name,
                          style: context.theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.visible,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.todos.discipline,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.visible,
                        ),
                        const SizedBox(height: 3),
                        widget.todos.todoCompletedTime != null
                            ? Text(
                                widget.todos.todoCompletedTime != null
                                    ? DateFormat.yMMMEd(locale.languageCode)
                                        .add_Hm()
                                        .format(
                                          widget.todos.todoCompletedTime!,
                                        )
                                    : '',
                                style:
                                    context.theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
