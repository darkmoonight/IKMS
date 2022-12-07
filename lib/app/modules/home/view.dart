import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ikms/app/modules/audiences/view.dart';
import 'package:ikms/app/modules/groups/view.dart';
import 'package:ikms/app/modules/mySchedule/view.dart';
import 'package:ikms/app/modules/professors/view.dart';
import 'package:ikms/app/modules/settings/view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final tabIndex = 0.obs;

  @override
  void initState() {
    super.initState();
  }

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: context.theme.bottomAppBarColor,
      ),
    );

    return Scaffold(
      body: Obx(
        (() => IndexedStack(
              index: tabIndex.value,
              children: const [
                MySchedulePage(),
                ProfessorsPage(),
                GroupsPage(
                  isSettings: false,
                ),
                AudiencesPage(),
                SettingsPage(),
              ],
            )),
      ),
      bottomNavigationBar: Obx(
        () => Theme(
          data: context.theme.copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: CustomNavigationBar(
            onTap: (int index) => changeTabIndex(index),
            currentIndex: tabIndex.value,
            backgroundColor: context.theme.bottomAppBarColor,
            strokeColor: const Color(0x300c18fb),
            items: [
              CustomNavigationBarItem(
                icon: const Icon(Iconsax.calendar_1),
              ),
              CustomNavigationBarItem(
                icon: const Icon(Iconsax.user_search),
              ),
              CustomNavigationBarItem(
                icon: const Icon(Iconsax.people),
              ),
              CustomNavigationBarItem(
                icon: const Icon(Iconsax.buliding),
              ),
              CustomNavigationBarItem(
                icon: const Icon(Iconsax.setting_2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
