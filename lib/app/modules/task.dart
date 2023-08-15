import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ikms/app/widgets/todos_list.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'todos'.tr,
            style: context.theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Column(
          children: [
            TabBar(
              splashFactory: NoSplash.splashFactory,
              overlayColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                  return Colors.transparent;
                },
              ),
              tabs: [
                Tab(text: 'unfulfilled'.tr),
                Tab(text: 'completed'.tr),
              ],
            ),
            const Flexible(
              child: TabBarView(
                children: [
                  TodosList(isDone: false),
                  TodosList(isDone: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
