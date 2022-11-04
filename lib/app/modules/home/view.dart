import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:project_cdis/app/modules/audiences/view.dart';
import 'package:project_cdis/app/modules/groups/view.dart';
import 'package:project_cdis/app/modules/mySchedule/view.dart';
import 'package:project_cdis/app/modules/professors/view.dart';
import 'package:project_cdis/app/modules/settings/view.dart';

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
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: DotNavigationBar(
            onTap: (int index) => changeTabIndex(index),
            currentIndex: tabIndex.value,
            backgroundColor: Theme.of(context).primaryColor,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey[500],
            enablePaddingAnimation: false,
            marginR: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.w),
            items: [
              DotNavigationBarItem(
                icon: const Icon(Iconsax.calendar_1),
              ),
              DotNavigationBarItem(
                icon: const Icon(Iconsax.user_search),
              ),
              DotNavigationBarItem(
                icon: const Icon(Iconsax.people),
              ),
              DotNavigationBarItem(
                icon: const Icon(Iconsax.buliding),
              ),
              DotNavigationBarItem(
                icon: const Icon(Iconsax.setting_2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
