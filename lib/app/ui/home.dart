import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:ikms/app/ui/rasps/view/schedules_pages.dart';
import 'package:ikms/app/ui/selection_list/view/selection_pages.dart';
import 'package:ikms/app/ui/settings/view/settings.dart';
import 'package:ikms/app/ui/todos/view/todos.dart';
import 'package:ikms/app/ui/todos/widgets/todos_action.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tabIndex = 0;
  final List<Widget> pages = const [
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
      body: IndexedStack(index: tabIndex, children: pages),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return NavigationBar(
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      onDestinationSelected: changeTabIndex,
      selectedIndex: tabIndex,
      destinations: _buildNavigationDestinations(),
    );
  }

  List<NavigationDestination> _buildNavigationDestinations() {
    return [
      _buildNavigationDestination(
        icon: IconsaxPlusLinear.calendar,
        selectedIcon: IconsaxPlusBold.calendar,
        label: 'schedule'.tr,
      ),
      _buildNavigationDestination(
        icon: IconsaxPlusLinear.user_search,
        selectedIcon: IconsaxPlusBold.user_search,
        label: 'professors'.tr,
      ),
      _buildNavigationDestination(
        icon: IconsaxPlusLinear.people,
        selectedIcon: IconsaxPlusBold.people,
        label: 'groups'.tr,
      ),
      _buildNavigationDestination(
        icon: IconsaxPlusLinear.buildings_2,
        selectedIcon: IconsaxPlusBold.buildings_2,
        label: 'audiences'.tr,
      ),
      _buildNavigationDestination(
        icon: IconsaxPlusLinear.task_square,
        selectedIcon: IconsaxPlusBold.task_square,
        label: 'todos'.tr,
      ),
      _buildNavigationDestination(
        icon: IconsaxPlusLinear.category,
        selectedIcon: IconsaxPlusBold.category,
        label: 'settings'.tr,
      ),
    ];
  }

  NavigationDestination _buildNavigationDestination({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    return NavigationDestination(
      icon: Icon(icon),
      selectedIcon: Icon(selectedIcon),
      label: label,
    );
  }

  Widget? _buildFloatingActionButton() {
    if (tabIndex == 4) {
      return FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            enableDrag: false,
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return TodosAction(text: 'create'.tr, edit: false);
            },
          );
        },
        child: const Icon(IconsaxPlusLinear.add),
      );
    }
    return null;
  }
}
