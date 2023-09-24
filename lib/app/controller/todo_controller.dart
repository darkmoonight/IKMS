import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:ikms/app/data/schema.dart';
import 'package:ikms/main.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import '../services/notification.dart';

class TodoController extends GetxController {
  final todos = <Todos>[].obs;

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
      isar.writeTxnSync(() {
        todos.add(todosCreate);
        isar.todos.putSync(todosCreate);
      });
      if (time.isNotEmpty) {
        NotificationShow().showNotification(
          todosCreate.id,
          todosCreate.name,
          todosCreate.discipline,
          date,
        );
      }
      EasyLoading.showSuccess('todoCreate'.tr,
          duration: const Duration(milliseconds: 500));
    } else {
      EasyLoading.showError('duplicateTodo'.tr,
          duration: const Duration(milliseconds: 500));
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

      var newTodo = todo;
      int oldIdx = todos.indexOf(todo);
      todos[oldIdx] = newTodo;
      todos.refresh();
    });
    if (time.isNotEmpty) {
      await flutterLocalNotificationsPlugin.cancel(todo.id);
      NotificationShow().showNotification(
        todo.id,
        todo.name,
        todo.discipline,
        date,
      );
    } else {
      await flutterLocalNotificationsPlugin.cancel(todo.id);
    }
    EasyLoading.showSuccess('update'.tr,
        duration: const Duration(milliseconds: 500));
  }

  Future<void> deleteTodo(Todos todo) async {
    isar.writeTxnSync(() {
      todos.remove(todo);
      isar.todos.deleteSync(todo.id);
    });
    if (todo.todoCompletedTime != null) {
      await flutterLocalNotificationsPlugin.cancel(todo.id);
    }
    EasyLoading.showSuccess('todoDelete'.tr,
        duration: const Duration(milliseconds: 500));
  }
}
