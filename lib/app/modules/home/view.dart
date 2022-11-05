import 'package:flutter/material.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
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
    ShapeBorder? bottomBarShape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(25)),
    );
    SnakeBarBehaviour snakeBarStyle = SnakeBarBehaviour.floating;
    EdgeInsets padding =
        const EdgeInsets.symmetric(horizontal: 15, vertical: 10);

    SnakeShape snakeShape = SnakeShape.circle;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Obx(
          (() => IndexedStack(
                index: tabIndex.value,
                children: const [
                  MySchedulePage(),
                  ProfessorsPage(),
                  GroupsPage(
                    isSettings: false,
                    isOnBoard: false,
                  ),
                  AudiencesPage(),
                  SettingsPage(),
                ],
              )),
        ),
        bottomNavigationBar: Obx(
          () => Theme(
            data: Get.theme.copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: SnakeNavigationBar.color(
              onTap: (int index) => changeTabIndex(index),
              currentIndex: tabIndex.value,
              behaviour: snakeBarStyle,
              snakeShape: snakeShape,
              shape: bottomBarShape,
              padding: padding,
              backgroundColor: Get.theme.backgroundColor,
              snakeViewColor: Get.theme.backgroundColor,
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.grey[500],
              showSelectedLabels: false,
              showUnselectedLabels: false,
              items: const [
                BottomNavigationBarItem(
                  label: 'Shedule',
                  icon: Icon(Iconsax.calendar_1),
                ),
                BottomNavigationBarItem(
                  label: 'Professors',
                  icon: Icon(Iconsax.user_search),
                ),
                BottomNavigationBarItem(
                  label: 'Groups',
                  icon: Icon(Iconsax.people),
                ),
                BottomNavigationBarItem(
                  label: 'Audiences',
                  icon: Icon(Iconsax.buliding),
                ),
                BottomNavigationBarItem(
                  label: 'Settings',
                  icon: Icon(Iconsax.setting_2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
