import 'package:ficonsax/ficonsax.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ikms/app/controller/todo_controller.dart';
import 'package:ikms/app/modules/todos/widgets/todos_list.dart';
import 'package:ikms/app/widgets/text_form.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final todoController = Get.put(TodoController());
  TextEditingController searchTodos = TextEditingController();
  String filter = '';

  applyFilter(String value) async {
    filter = value.toLowerCase();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    applyFilter('');
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => WillPopScope(
        onWillPop: () async {
          if (todoController.isMultiSelectionTodo.isTrue) {
            todoController.selectedTodo.clear();
            todoController.isMultiSelectionTodo.value = false;
            return false;
          } else {
            return true;
          }
        },
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            leading: todoController.isMultiSelectionTodo.isTrue
                ? IconButton(
                    onPressed: () {
                      todoController.selectedTodo.clear();
                      todoController.isMultiSelectionTodo.value = false;
                    },
                    icon: const Icon(
                      IconsaxOutline.close_square,
                      size: 20,
                    ),
                  )
                : null,
            title: Text(
              'todos'.tr,
              style: context.theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              Visibility(
                visible: todoController.selectedTodo.isNotEmpty,
                child: IconButton(
                  icon: const Icon(
                    IconsaxOutline.trush_square,
                    size: 20,
                  ),
                  onPressed: () async {
                    await showAdaptiveDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog.adaptive(
                          title: Text(
                            'deletedTodo'.tr,
                            style: context.textTheme.titleLarge,
                          ),
                          content: Text(
                            'deletedTodoQuery'.tr,
                            style: context.textTheme.titleMedium,
                          ),
                          actions: [
                            TextButton(
                                onPressed: () => Get.back(),
                                child: Text('cancel'.tr,
                                    style: context.textTheme.titleMedium
                                        ?.copyWith(color: Colors.blueAccent))),
                            TextButton(
                                onPressed: () {
                                  todoController
                                      .deleteTodo(todoController.selectedTodo);
                                  todoController.selectedTodo.clear();
                                  todoController.isMultiSelectionTodo.value =
                                      false;
                                  Get.back();
                                },
                                child: Text('delete'.tr,
                                    style: context.textTheme.titleMedium
                                        ?.copyWith(color: Colors.red))),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          body: DefaultTabController(
            length: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyTextForm(
                  labelText: 'searchTodo'.tr,
                  type: TextInputType.text,
                  icon: const Icon(IconsaxOutline.search_normal_1, size: 18),
                  controller: searchTodos,
                  margin: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                  onChanged: applyFilter,
                  iconButton: searchTodos.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            searchTodos.clear();
                            applyFilter('');
                          },
                          icon: const Icon(
                            IconsaxOutline.close_circle,
                            color: Colors.grey,
                            size: 20,
                          ),
                        )
                      : null,
                ),
                TabBar(
                  tabAlignment: TabAlignment.start,
                  isScrollable: true,
                  dividerColor: Colors.transparent,
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                      return Colors.transparent;
                    },
                  ),
                  tabs: [
                    Tab(text: 'doing'.tr),
                    Tab(text: 'done'.tr),
                  ],
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: TabBarView(
                      children: [
                        TodosList(
                          done: false,
                          searchTodo: filter,
                        ),
                        TodosList(
                          done: true,
                          searchTodo: filter,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
