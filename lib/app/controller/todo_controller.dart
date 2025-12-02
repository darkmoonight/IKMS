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

  void loadTodos() => todos.assignAll(isar.todos.where().findAllSync());

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
    isar.writeTxnSync(() => isar.todos.putSync(todosCreate));
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
    final getTodos = isar.todos
        .filter()
        .nameEqualTo(title)
        .disciplineEqualTo(discipline.discipline)
        .findAllSync();
    return getTodos.isNotEmpty;
  }

  Future<void> updateTodoCheck(Todos todo) async {
    isar.writeTxnSync(() => isar.todos.putSync(todo));
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
    isar.writeTxnSync(() {
      todo.name = title;
      todo.discipline = discipline.discipline;
      todo.todoCompletedTime = date;
      isar.todos.putSync(todo);
    });
    refreshTodo(todo);
    if (date != null && now.isBefore(date)) {
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
      deleteTodoFromDB(todo);
    }
    EasyLoading.showSuccess(
      'todoDelete'.tr,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> cancelNotificationForTodo(Todos todo) async {
    if (todo.todoCompletedTime != null &&
        todo.todoCompletedTime!.isAfter(DateTime.now())) {
      await flutterLocalNotificationsPlugin.cancel(todo.id);
    }
  }

  void deleteTodoFromDB(Todos todo) {
    todos.remove(todo);
    isar.writeTxnSync(() => isar.todos.deleteSync(todo.id));
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
