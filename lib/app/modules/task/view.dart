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
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text(
                'todos'.tr,
                style: context.theme.textTheme.headline2,
                textAlign: TextAlign.center,
              ),
            ),
            TabBar(
              splashFactory: NoSplash.splashFactory,
              overlayColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                  return Colors.transparent;
                },
              ),
              indicatorColor: Colors.blueAccent,
              tabs: [
                Tab(text: 'unfulfilled'.tr),
                Tab(text: 'completed'.tr),
              ],
              labelStyle: context.theme.textTheme.headline6,
              labelColor: context.theme.textTheme.headline6?.color,
              unselectedLabelColor:
                  context.theme.primaryTextTheme.subtitle1?.color,
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
