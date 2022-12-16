import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ikms/app/data/schema.dart';
import 'package:ikms/app/services/isar_services.dart';
import 'package:ikms/app/widgets/todo_list.dart';

class TodosListNoDone extends StatefulWidget {
  const TodosListNoDone({super.key});

  @override
  State<TodosListNoDone> createState() => _TodosListNoDoneState();
}

class _TodosListNoDoneState extends State<TodosListNoDone> {
  final service = IsarServices();
  Color getColor(Set<MaterialState> states) {
    <MaterialState>{
      MaterialState.pressed,
    };
    return context.theme.unselectedWidgetColor;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Todos>>(
      stream: service.getTodoNoDone(),
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
                          'addTodo'.tr,
                          style: context.theme.textTheme.headline3,
                        ),
                      ],
                    ),
                  ),
                );
              }
              return TodoList(
                  todos: todos, service: service, getColor: getColor);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
        }
      },
    );
  }
}
