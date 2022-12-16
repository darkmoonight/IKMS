import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:ikms/app/data/schema.dart';
import 'package:ikms/main.dart';
import 'package:isar/isar.dart';

class IsarServices {
  final titleEdit = TextEditingController().obs;
  final disciplineEdit = TextEditingController().obs;

  Stream<List<Todos>> getTodoNoDone() async* {
    yield* isar.todos.filter().doneEqualTo(false).watch(fireImmediately: true);
  }

  Stream<List<Todos>> getTodoDone() async* {
    yield* isar.todos.filter().doneEqualTo(true).watch(fireImmediately: true);
  }

  Future<void> addTodo(
    TextEditingController titleEdit,
    TextEditingController disciplineEdit,
  ) async {
    final todosCreate = Todos(
      name: titleEdit.text,
      discipline: disciplineEdit.text,
    );

    final todosCollection = isar.todos;
    List<Todos> getTodos;

    getTodos =
        await todosCollection.filter().nameEqualTo(titleEdit.text).findAll();

    if (getTodos.isEmpty) {
      await isar.writeTxn(() async {
        await isar.todos.put(todosCreate);
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
    TextEditingController disciplineEdit,
  ) async {
    await isar.writeTxn(() async {
      todo.name = titleEdit.text;
      todo.discipline = disciplineEdit.text;

      await isar.todos.put(todo);
    });
    EasyLoading.showSuccess('update'.tr,
        duration: const Duration(milliseconds: 500));
  }

  Future<void> deleteTodo(Todos todos) async {
    await isar.writeTxn(() async {
      await isar.todos.delete(todos.id);
    });
    EasyLoading.showSuccess('todoDelete'.tr,
        duration: const Duration(milliseconds: 500));
  }
}
