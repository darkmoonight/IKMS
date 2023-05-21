import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void changeTabIndex(int index) {
    setState(() {
      tabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor:
            context.theme.bottomNavigationBarTheme.backgroundColor,
      ),
    );

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: IndexedStack(
        index: tabIndex,
        children: const [
          MySchedulePage(),
          ProfessorsPage(),
          GroupsPage(
            isSettings: false,
          ),
          AudiencesPage(),
          TaskPage(),
          SettingsPage(),
        ],
      ),
      floatingActionButton: tabIndex == 4
          ? FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  enableDrag: false,
                  backgroundColor: context.theme.scaffoldBackgroundColor,
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
              backgroundColor: context.theme.primaryColor,
              child: Icon(
                Iconsax.add,
                color: context.theme.iconTheme.color,
              ),
            )
          : null,
      bottomNavigationBar: Theme(
        data: context.theme.copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: CustomNavigationBar(
          backgroundColor:
              context.theme.bottomNavigationBarTheme.backgroundColor!,
          onTap: (int index) {
            changeTabIndex(index);
            FocusManager.instance.primaryFocus?.unfocus();
          },
          currentIndex: tabIndex,
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
