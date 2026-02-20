import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:ikms/app/data/db.dart';
import 'package:ikms/app/utils/notification.dart';
import 'package:ikms/main.dart';
import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';

class TodoController extends GetxController {
  final todos = <Todos>[].obs;
  final selectedTodo = <Todos>[].obs;
  final isMultiSelectionTodo = false.obs;
  final isPop = true.obs;
  final duration = const Duration(milliseconds: 500);
  var now = DateTime.now();

  @override
  void onInit() {
    super.onInit();
    loadTodos();
  }

  Future<void> loadTodos() async => todos.assignAll(await isar.todos.where().findAll());

  Future<void> addTodo(String title, Schedule discipline, String time) async {
    DateTime? date;
    if (time.isNotEmpty) {
      date = parseDate(time);
    }
    if (await isTodoDuplicate(title, discipline, date)) {
      EasyLoading.showError('duplicateTodo'.tr, duration: duration);
      return;
    }
    final todosCreate = Todos(
      name: title,
      discipline: discipline.discipline,
      todoCompletedTime: date,
    );
    todos.add(todosCreate);
    await isar.writeTxn(() async => await isar.todos.put(todosCreate));
    if (date != null && now.isBefore(date)) {
      NotificationShow().showNotification(
        todosCreate.id,
        todosCreate.name,
        todosCreate.discipline,
        date,
      );
    }
    EasyLoading.showSuccess('todoCreate'.tr, duration: duration);
  }

  DateTime? parseDate(String time) {
    if (time.isEmpty) return null;
    return DateFormat.yMMMEd(locale.languageCode).add_Hm().parse(time);
  }

  Future<bool> isTodoDuplicate(
    String title,
    Schedule discipline,
    DateTime? date,
  ) async {
    final getTodos = await isar.todos
        .filter()
        .nameEqualTo(title)
        .disciplineEqualTo(discipline.discipline)
        .findAll();
    return getTodos.isNotEmpty;
  }

  Future<void> updateTodoCheck(Todos todo) async {
    await isar.writeTxn(() async => await isar.todos.put(todo));
    todos.refresh();
  }

  Future<void> updateTodo(
    Todos todo,
    String title,
    Schedule discipline,
    String time,
  ) async {
    DateTime? date;
    if (time.isNotEmpty) {
      date = parseDate(time);
    }
    await isar.writeTxn(() async {
      todo.name = title;
      todo.discipline = discipline.discipline;
      todo.todoCompletedTime = date;
      await isar.todos.put(todo);
    });
    refreshTodo(todo);
    if (date != null && now.isBefore(date)) {
      await flutterLocalNotificationsPlugin.cancel(id: todo.id);
      NotificationShow().showNotification(
        todo.id,
        todo.name,
        todo.discipline,
        date,
      );
    } else {
      await flutterLocalNotificationsPlugin.cancel(id: todo.id);
    }
    EasyLoading.showSuccess('update'.tr, duration: duration);
  }

  void refreshTodo(Todos todo) {
    int oldIdx = todos.indexOf(todo);
    todos[oldIdx] = todo;
    todos.refresh();
  }

  Future<void> deleteTodo(List<Todos> todoList) async {
    List<Todos> todoListCopy = List.from(todoList);
    for (var todo in todoListCopy) {
      await cancelNotificationForTodo(todo);
      await deleteTodoFromDB(todo);
    }
    EasyLoading.showSuccess(
      'todoDelete'.tr,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> cancelNotificationForTodo(Todos todo) async {
    if (todo.todoCompletedTime != null &&
        todo.todoCompletedTime!.isAfter(DateTime.now())) {
      await flutterLocalNotificationsPlugin.cancel(id: todo.id);
    }
  }

  Future<void> deleteTodoFromDB(Todos todo) async {
    todos.remove(todo);
    await isar.writeTxn(() async => await isar.todos.delete(todo.id));
  }

  void doMultiSelectionTodo(Todos todo) {
    if (isMultiSelectionTodo.isTrue) {
      isPop.value = false;
      if (selectedTodo.contains(todo)) {
        selectedTodo.remove(todo);
      } else {
        selectedTodo.add(todo);
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
