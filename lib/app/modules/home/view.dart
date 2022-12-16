import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ikms/app/modules/mySchedule/view.dart';
import 'package:ikms/app/modules/search/view.dart';
import 'package:ikms/app/modules/settings/view.dart';
import 'package:ikms/app/modules/task/view.dart';
import 'package:ikms/app/widgets/todos_ce.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var tabIndex = 0;

  void changeTabIndex(int index) {
    setState(() {
      tabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: context.theme.bottomAppBarColor,
      ),
    );

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: IndexedStack(
        index: tabIndex,
        children: const [
          MySchedulePage(),
          SearchBar(),
          TaskPage(),
          SettingsPage(),
        ],
      ),
      floatingActionButton: tabIndex == 2
          ? FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  enableDrag: false,
                  backgroundColor: context.theme.scaffoldBackgroundColor,
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (BuildContext context) {
                    return TodosCe(
                      text: 'create'.tr,
                      edit: false,
                    );
                  },
                );
              },
              backgroundColor: context.theme.primaryColor,
              child: const Icon(
                Iconsax.add,
                color: Colors.greenAccent,
              ),
            )
          : null,
      bottomNavigationBar: Theme(
        data: context.theme.copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: CustomNavigationBar(
          onTap: (int index) => changeTabIndex(index),
          currentIndex: tabIndex,
          backgroundColor: context.theme.bottomAppBarColor,
          strokeColor: const Color(0x300c18fb),
          items: [
            CustomNavigationBarItem(
              icon: const Icon(Iconsax.calendar_1),
            ),
            CustomNavigationBarItem(
              icon: const Icon(Iconsax.search_normal_1),
            ),
            CustomNavigationBarItem(
              icon: const Icon(Iconsax.task_square),
            ),
            CustomNavigationBarItem(
              icon: const Icon(Iconsax.setting_2),
            ),
          ],
        ),
      ),
    );
  }
}
