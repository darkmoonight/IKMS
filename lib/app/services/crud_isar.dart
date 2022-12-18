import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:ikms/app/data/schema.dart';
import 'package:ikms/main.dart';
import 'package:isar/isar.dart';

import 'notification.dart';

class IsarServices {
  final titleEdit = TextEditingController().obs;
  final timeEdit = TextEditingController().obs;

  Stream<List<Todos>> getTodoNoDone() async* {
    yield* isar.todos.filter().doneEqualTo(false).watch(fireImmediately: true);
  }

  Stream<List<Todos>> getTodoDone() async* {
    yield* isar.todos.filter().doneEqualTo(true).watch(fireImmediately: true);
  }

  Future<void> addTodo(
    TextEditingController titleEdit,
    Schedule disciplineEdit,
    TextEditingController timeEdit,
  ) async {
    final todosCreate = Todos(
      name: titleEdit.text,
      discipline: disciplineEdit.discipline,
      todoCompletedTime: DateTime.tryParse(timeEdit.text),
    );

    final todosCollection = isar.todos;
    List<Todos> getTodos;

    getTodos =
        await todosCollection.filter().nameEqualTo(titleEdit.text).findAll();

    if (getTodos.isEmpty) {
      await isar.writeTxn(() async {
        await isar.todos.put(todosCreate);
        if (timeEdit.text.isNotEmpty) {
          NotificationShow().showNotification(
            todosCreate.id,
            todosCreate.name,
            todosCreate.discipline,
            DateTime.tryParse(timeEdit.text),
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
    TextEditingController titleEdit,
    Schedule disciplineEdit,
    TextEditingController timeEdit,
  ) async {
    await isar.writeTxn(() async {
      todo.name = titleEdit.text;
      todo.discipline = disciplineEdit.discipline;
      todo.todoCompletedTime = DateTime.tryParse(timeEdit.text);
      await isar.todos.put(todo);

      if (timeEdit.text.isNotEmpty) {
        await flutterLocalNotificationsPlugin.cancel(todo.id);
        NotificationShow().showNotification(
          todo.id,
          todo.name,
          todo.discipline,
          DateTime.tryParse(timeEdit.text),
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
