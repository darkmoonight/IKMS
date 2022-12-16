import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ikms/app/data/schema.dart';
import 'package:ikms/app/services/isar_services.dart';
import 'package:ikms/app/widgets/todos_ce.dart';

class TodoList extends StatelessWidget {
  const TodoList({
    super.key,
    required this.todos,
    required this.service,
    required this.getColor,
  });
  final List<Todos> todos;
  final IsarServices service;
  final Color Function(Set<MaterialState>) getColor;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, innerState) {
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: todos.length,
          itemBuilder: (context, index) {
            final todosList = todos[index];
            return Dismissible(
              key: ObjectKey(todosList),
              direction: DismissDirection.endToStart,
              confirmDismiss: (DismissDirection direction) async {
                return await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: context.theme.primaryColor,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      title: Text(
                        "deletedTodos".tr,
                        style: context.theme.textTheme.headline4,
                      ),
                      content: Text("deletedTodosQuery".tr,
                          style: context.theme.textTheme.headline6),
                      actions: [
                        TextButton(
                            onPressed: () => Get.back(result: false),
                            child: Text("cancel".tr,
                                style: context.theme.textTheme.headline6
                                    ?.copyWith(color: Colors.blueAccent))),
                        TextButton(
                            onPressed: () => Get.back(result: true),
                            child: Text("delete".tr,
                                style: context.theme.textTheme.headline6
                                    ?.copyWith(color: Colors.red))),
                      ],
                    );
                  },
                );
              },
              onDismissed: (DismissDirection direction) {
                service.deleteTodo(todosList);
              },
              background: Container(
                alignment: Alignment.centerRight,
                child: const Padding(
                  padding: EdgeInsets.only(
                    right: 15,
                  ),
                  child: Icon(
                    Iconsax.trush_square,
                    color: Colors.red,
                  ),
                ),
              ),
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    enableDrag: false,
                    backgroundColor: context.theme.scaffoldBackgroundColor,
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (BuildContext context) {
                      return TodosCe(
                        text: 'editing'.tr,
                        edit: true,
                        todo: todosList,
                      );
                    },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      color: context.theme.primaryColor,
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          checkColor: Colors.white,
                          fillColor:
                              MaterialStateProperty.resolveWith(getColor),
                          value: todosList.done,
                          shape: const CircleBorder(),
                          onChanged: (val) {
                            innerState(() {
                              todosList.done = val!;
                            });
                            Future.delayed(const Duration(milliseconds: 300),
                                () {
                              service.updateTodoCheck(todosList);
                            });
                          },
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                todosList.name,
                                style: context.theme.textTheme.headline4,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                todosList.discipline,
                                style: context.theme.textTheme.subtitle2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
