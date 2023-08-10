import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ikms/app/modules/audiences.dart';
import 'package:ikms/app/modules/groups.dart';
import 'package:ikms/app/modules/my_schedule.dart';
import 'package:ikms/app/modules/professors.dart';
import 'package:ikms/app/modules/settings.dart';
import 'package:ikms/app/modules/task.dart';
import 'package:ikms/app/widgets/todos_ce.dart';

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
    GroupsPage(
      isSettings: false,
    ),
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
                    return TodosCe(
                      text: 'create'.tr,
                      edit: false,
                    );
                  },
                );
              },
              child: const Icon(Iconsax.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        onDestinationSelected: (int index) => changeTabIndex(index),
        selectedIndex: tabIndex,
        destinations: [
          NavigationDestination(
            icon: const Icon(Iconsax.calendar_1),
            label: 'schedule'.tr,
          ),
          NavigationDestination(
            icon: const Icon(Iconsax.user_search),
            label: 'professors'.tr,
          ),
          NavigationDestination(
            icon: const Icon(Iconsax.people),
            label: 'groups'.tr,
          ),
          NavigationDestination(
            icon: const Icon(Iconsax.buliding),
            label: 'audiences'.tr,
          ),
          NavigationDestination(
            icon: const Icon(Iconsax.task_square),
            label: 'todos'.tr,
          ),
          NavigationDestination(
            icon: const Icon(Iconsax.setting_2),
            label: 'settings'.tr,
          ),
        ],
      ),
    );
  }
}
