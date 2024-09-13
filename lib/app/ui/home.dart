import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:ikms/app/ui/rasps/view/my_schedule.dart';
import 'package:ikms/app/ui/selection_list/view/audiences.dart';
import 'package:ikms/app/ui/selection_list/view/groups.dart';
import 'package:ikms/app/ui/selection_list/view/professors.dart';
import 'package:ikms/app/ui/settings/view/settings.dart';
import 'package:ikms/app/ui/todos/view/todos.dart';
import 'package:ikms/app/ui/todos/widgets/todos_action.dart';

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
              child: const Icon(IconsaxPlusLinear.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        onDestinationSelected: (int index) => changeTabIndex(index),
        selectedIndex: tabIndex,
        destinations: [
          NavigationDestination(
            icon: const Icon(IconsaxPlusLinear.calendar),
            selectedIcon: const Icon(IconsaxPlusBold.calendar),
            label: 'schedule'.tr,
          ),
          NavigationDestination(
            icon: const Icon(IconsaxPlusLinear.user_search),
            selectedIcon: const Icon(IconsaxPlusBold.user_search),
            label: 'professors'.tr,
          ),
          NavigationDestination(
            icon: const Icon(IconsaxPlusLinear.people),
            selectedIcon: const Icon(IconsaxPlusBold.people),
            label: 'groups'.tr,
          ),
          NavigationDestination(
            icon: const Icon(IconsaxPlusLinear.buildings_2),
            selectedIcon: const Icon(IconsaxPlusBold.buildings_2),
            label: 'audiences'.tr,
          ),
          NavigationDestination(
            icon: const Icon(IconsaxPlusLinear.task_square),
            selectedIcon: const Icon(IconsaxPlusBold.task_square),
            label: 'todos'.tr,
          ),
          NavigationDestination(
            icon: const Icon(IconsaxPlusLinear.category),
            selectedIcon: const Icon(IconsaxPlusBold.category),
            label: 'settings'.tr,
          ),
        ],
      ),
    );
  }
}
