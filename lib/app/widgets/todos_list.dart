import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ikms/app/data/schema.dart';
import 'package:ikms/app/services/isar_services.dart';
import 'package:ikms/app/widgets/todos_ce.dart';

class TodosList extends StatefulWidget {
  const TodosList({super.key, required this.isDone});
  final bool isDone;

  @override
  State<TodosList> createState() => _TodosListState();
}

class _TodosListState extends State<TodosList> {
  final service = IsarServices();
  Color getColor(Set<MaterialState> states) {
    <MaterialState>{
      MaterialState.pressed,
    };
    return widget.isDone == true ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Todos>>(
      stream: widget.isDone == true
          ? service.getTodoDone()
          : service.getTodoNoDone(),
      builder: (BuildContext context, AsyncSnapshot<List<Todos>> listData) {
        switch (listData.connectionState) {
          case ConnectionState.done:
          default:
            if (listData.hasData) {
              final todos = listData.data!;
              if (todos.isEmpty) {
                return Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/add.png',
                          scale: 5,
                        ),
                        Text(
                          widget.isDone == true
                              ? 'copletedTodo'.tr
                              : 'addTodo'.tr,
                          style: context.theme.textTheme.headline3,
                        ),
                      ],
                    ),
                  ),
                );
              }
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
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15))),
                                title: Text(
                                  "deletedTodo".tr,
                                  style: context.theme.textTheme.headline4,
                                ),
                                content: Text("deletedTodoQuery".tr,
                                    style: context.theme.textTheme.headline6),
                                actions: [
                                  TextButton(
                                      onPressed: () => Get.back(result: false),
                                      child: Text("cancel".tr,
                                          style: context
                                              .theme.textTheme.headline6
                                              ?.copyWith(
                                                  color: Colors.blueAccent))),
                                  TextButton(
                                      onPressed: () => Get.back(result: true),
                                      child: Text("delete".tr,
                                          style: context
                                              .theme.textTheme.headline6
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
                        child: InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              enableDrag: false,
                              backgroundColor:
                                  context.theme.scaffoldBackgroundColor,
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
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  Checkbox(
                                    checkColor: Colors.white,
                                    fillColor:
                                        MaterialStateProperty.resolveWith(
                                            getColor),
                                    value: todosList.done,
                                    shape: const CircleBorder(),
                                    onChanged: (val) {
                                      innerState(() {
                                        todosList.done = val!;
                                      });
                                      Future.delayed(
                                          const Duration(milliseconds: 300),
                                          () {
                                        service.updateTodoCheck(todosList);
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          todosList.name,
                                          style:
                                              context.theme.textTheme.headline4,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          todosList.discipline,
                                          style:
                                              context.theme.textTheme.subtitle2,
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
            } else {
              return const Center(child: CircularProgressIndicator());
            }
        }
      },
    );
  }
}
