import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ikms/app/modules/todos/widgets/todos_list.dart';

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TabBar(
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
            const Flexible(
              child: TabBarView(
                children: [
                  TodosList(done: false),
                  TodosList(done: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
