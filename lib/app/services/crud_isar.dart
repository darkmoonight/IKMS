import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:ikms/app/data/schema.dart';
import 'package:ikms/main.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'notification.dart';

class IsarServices {
  final locale = Get.locale;

  Stream<List<Todos>> getTodoNoDone() async* {
    yield* isar.todos.filter().doneEqualTo(false).watch(fireImmediately: true);
  }

  Stream<List<Todos>> getTodoDone() async* {
    yield* isar.todos.filter().doneEqualTo(true).watch(fireImmediately: true);
  }

  Future<void> addTodo(
    String title,
    Schedule discipline,
    String time,
  ) async {
    DateTime? date;
    if (time.isNotEmpty) {
      date = DateFormat.yMMMEd(locale?.languageCode).add_Hm().parse(time);
    }

    final todosCreate = Todos(
      name: title,
      discipline: discipline.discipline,
      todoCompletedTime: date,
    );

    final todosCollection = isar.todos;
    List<Todos> getTodos;

    getTodos = await todosCollection.filter().nameEqualTo(title).findAll();

    if (getTodos.isEmpty) {
      await isar.writeTxn(() async {
        await isar.todos.put(todosCreate);
        if (time.isNotEmpty) {
          NotificationShow().showNotification(
            todosCreate.id,
            todosCreate.name,
            todosCreate.discipline,
            date,
          );
        }
      });
      EasyLoading.showSuccess('todoCreate'.tr,
          duration: const Duration(milliseconds: 500));
    } else {
      EasyLoading.showError('duplicateTodo'.tr,
          duration: const Duration(milliseconds: 500));
    }
  }

  Future<void> updateTodoCheck(Todos todo) async {
    await isar.writeTxn(() async => isar.todos.put(todo));
  }

  Future<void> updateTodo(
    Todos todo,
    String title,
    Schedule discipline,
    String time,
  ) async {
    DateTime? date;
    if (time.isNotEmpty) {
      date = DateFormat.yMMMEd(locale?.languageCode).add_Hm().parse(time);
    }

    await isar.writeTxn(() async {
      todo.name = title;
      todo.discipline = discipline.discipline;
      todo.todoCompletedTime = date;
      await isar.todos.put(todo);

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
    });
    EasyLoading.showSuccess('update'.tr,
        duration: const Duration(milliseconds: 500));
  }

  Future<void> deleteTodo(Todos todos) async {
    await isar.writeTxn(() async {
      await isar.todos.delete(todos.id);
      if (todos.todoCompletedTime != null) {
        await flutterLocalNotificationsPlugin.cancel(todos.id);
      }
    });
    EasyLoading.showSuccess('todoDelete'.tr,
        duration: const Duration(milliseconds: 500));
  }
}
