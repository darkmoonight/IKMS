import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ficonsax/ficonsax.dart';
import 'package:ikms/app/modules/selection_list/view/audiences.dart';
import 'package:ikms/app/modules/selection_list/view/groups.dart';
import 'package:ikms/app/modules/rasps/view/my_schedule.dart';
import 'package:ikms/app/modules/selection_list/view/professors.dart';
import 'package:ikms/app/modules/settings/view/settings.dart';
import 'package:ikms/app/modules/todos/view/todos.dart';
import 'package:ikms/app/modules/todos/widgets/todos_action.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var tabIndex = 0;

  final pages = const [
    MySchedulePage(),
    ProfessorsPage(),
    GroupsPage(isSettings: false),
    AudiencesPage(),
    TaskPage(),
    SettingsPage(),
  ];

  void changeTabIndex(int index) {
    setState(() {
      tabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: tabIndex,
        children: pages,
      ),
      floatingActionButton: tabIndex == 4
          ? FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  enableDrag: false,
                  context: context,
                  isScrollControlled: true,
                  builder: (BuildContext context) {
                    return TodosAction(
                      text: 'create'.tr,
                      edit: false,
                    );
                  },
                );
              },
              child: const Icon(IconsaxOutline.add),
            )
          : null,
      bottomNavigationBar: SizedBox(
        height: 60,
        child: NavigationBar(
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          onDestinationSelected: (int index) => changeTabIndex(index),
          selectedIndex: tabIndex,
          destinations: [
            NavigationDestination(
              icon: const Icon(IconsaxOutline.calendar_1),
              selectedIcon: const Icon(IconsaxBold.calendar),
              label: 'schedule'.tr,
            ),
            NavigationDestination(
              icon: const Icon(IconsaxOutline.user_search),
              selectedIcon: const Icon(IconsaxBold.user_search),
              label: 'professors'.tr,
            ),
            NavigationDestination(
              icon: const Icon(IconsaxOutline.people),
              selectedIcon: const Icon(IconsaxBold.people),
              label: 'groups'.tr,
            ),
            NavigationDestination(
              icon: const Icon(IconsaxOutline.buildings_2),
              selectedIcon: const Icon(IconsaxBold.buildings_2),
              label: 'audiences'.tr,
            ),
            NavigationDestination(
              icon: const Icon(IconsaxOutline.task_square),
              selectedIcon: const Icon(IconsaxBold.task_square),
              label: 'todos'.tr,
            ),
            NavigationDestination(
              icon: const Icon(IconsaxOutline.category),
              selectedIcon: const Icon(IconsaxBold.category),
              label: 'settings'.tr,
            ),
          ],
        ),
      ),
    );
  }
}
