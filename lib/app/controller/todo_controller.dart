import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:ikms/app/data/db.dart';
import 'package:ikms/app/utils/notification.dart';
import 'package:ikms/main.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

class TodoController extends GetxController {
  final todos = <Todos>[].obs;

  final selectedTodo = <Todos>[].obs;
  final isMultiSelectionTodo = false.obs;

  RxBool isPop = true.obs;

  final duration = const Duration(milliseconds: 500);
  var now = DateTime.now();

  @override
  void onInit() {
    super.onInit();
    todos.assignAll(isar.todos.where().findAllSync());
  }

  Future<void> addTodo(String title, Schedule discipline, String time) async {
    DateTime? date;
    if (time.isNotEmpty) {
      date = DateFormat.yMMMEd(locale.languageCode).add_Hm().parse(time);
    }
    List<Todos> getTodos;
    getTodos = isar.todos
        .filter()
        .nameEqualTo(title)
        .disciplineEqualTo(discipline.discipline)
        .findAllSync();

    final todosCreate = Todos(
      name: title,
      discipline: discipline.discipline,
      todoCompletedTime: date,
    );

    if (getTodos.isEmpty) {
      todos.add(todosCreate);
      isar.writeTxnSync(() => isar.todos.putSync(todosCreate));
      if (time.isNotEmpty) {
        NotificationShow().showNotification(
            todosCreate.id, todosCreate.name, todosCreate.discipline, date);
      }
      EasyLoading.showSuccess('todoCreate'.tr, duration: duration);
    } else {
      EasyLoading.showError('duplicateTodo'.tr, duration: duration);
    }
  }

  Future<void> updateTodoCheck(Todos todo) async {
    isar.writeTxnSync(() => isar.todos.putSync(todo));
    todos.refresh();
  }

  Future<void> updateTodo(
      Todos todo, String title, Schedule discipline, String time) async {
    DateTime? date;
    if (time.isNotEmpty) {
      date = DateFormat.yMMMEd(locale.languageCode).add_Hm().parse(time);
    }

    isar.writeTxnSync(() {
      todo.name = title;
      todo.discipline = discipline.discipline;
      todo.todoCompletedTime = date;
      isar.todos.putSync(todo);
    });

    var newTodo = todo;
    int oldIdx = todos.indexOf(todo);
    todos[oldIdx] = newTodo;
    todos.refresh();

    if (time.isNotEmpty) {
      await flutterLocalNotificationsPlugin.cancel(todo.id);
      NotificationShow()
          .showNotification(todo.id, todo.name, todo.discipline, date);
    } else {
      await flutterLocalNotificationsPlugin.cancel(todo.id);
    }
    EasyLoading.showSuccess('update'.tr, duration: duration);
  }

  Future<void> deleteTodo(List<Todos> todoList) async {
    List<Todos> todoListCopy = List.from(todoList);
    for (var todo in todoListCopy) {
      if (todo.todoCompletedTime != null) {
        if (todo.todoCompletedTime!.isAfter(now)) {
          await flutterLocalNotificationsPlugin.cancel(todo.id);
        }
      }
      todos.remove(todo);
      isar.writeTxnSync(() => isar.todos.deleteSync(todo.id));
      EasyLoading.showSuccess('todoDelete'.tr, duration: duration);
    }
  }

  void doMultiSelectionTodo(Todos todos) {
    if (isMultiSelectionTodo.isTrue) {
      isPop.value = false;
      if (selectedTodo.contains(todos)) {
        selectedTodo.remove(todos);
      } else {
        selectedTodo.add(todos);
      }

      if (selectedTodo.isEmpty) {
        isMultiSelectionTodo.value = false;
        isPop.value = true;
      }
    }
  }

  void doMultiSelectionTodoClear() {
    selectedTodo.clear();
    isMultiSelectionTodo.value = false;
    isPop.value = true;
  }
}
