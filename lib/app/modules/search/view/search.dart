import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:ikms/app/modules/selection_list/view/audiences.dart';
import 'package:ikms/app/modules/selection_list/view/groups.dart';
import 'package:ikms/app/modules/selection_list/view/professors.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var tabIndex = 0;

  final pages = const [
    ProfessorsPage(),
    GroupsPage(isSettings: false),
    AudiencesPage(),
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
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) => changeTabIndex(index),
        selectedIndex: tabIndex,
        destinations: [
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
        ],
      ),
    );
  }
}
