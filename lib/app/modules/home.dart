import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:ikms/app/modules/rasps/view/my_schedule.dart';
import 'package:ikms/app/modules/search/view/search.dart';
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
    SearchPage(),
    TaskPage(),
    SettingsPage(),
  ];

  void changeTabIndex(int index) {
    if (index == 1) {
      Get.to(() => const SearchPage(), transition: Transition.downToUp);
    } else {
      setState(() {
        tabIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: tabIndex,
        children: pages,
      ),
      floatingActionButton: tabIndex == 2
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
        onDestinationSelected: (int index) => changeTabIndex(index),
        selectedIndex: tabIndex,
        destinations: [
          NavigationDestination(
            icon: const Icon(IconsaxPlusLinear.calendar),
            selectedIcon: const Icon(IconsaxPlusBold.calendar),
            label: 'schedule'.tr,
          ),
          NavigationDestination(
            icon: const Icon(IconsaxPlusLinear.search_normal_1),
            selectedIcon: const Icon(IconsaxPlusBold.search_normal_1),
            label: 'search'.tr,
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
