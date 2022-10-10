import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:project_cdis/app/modules/audiences/view.dart';
import 'package:project_cdis/app/modules/mySchedule/view.dart';
import 'package:project_cdis/app/modules/professors/view.dart';
import 'package:project_cdis/app/modules/settings/view.dart';
import 'package:project_cdis/app/widgets/selection_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? groupId;
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
              children: [
                MySchedulePage(
                  groupId: groupId,
                  key: UniqueKey(),
                ),
                const ProfessorsPage(),
                const AudiencesPage(),
                SettingsPage(
                  onGroupSelected: (SelectionData data) {
                    setState(() {
                      groupId = data.id;
                    });
                  },
                ),
              ],
            )),
      ),
      bottomNavigationBar: Obx(
        () => Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            onTap: (int index) => changeTabIndex(index),
            currentIndex: tabIndex.value,
            backgroundColor: Theme.of(context).primaryColor,
            showUnselectedLabels: false,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey[500],
            items: [
              BottomNavigationBarItem(
                label: AppLocalizations.of(context)!.schedule,
                icon: const Icon(Icons.event_outlined),
              ),
              BottomNavigationBarItem(
                label: AppLocalizations.of(context)!.professors,
                icon: const Icon(Icons.person_outline),
              ),
              BottomNavigationBarItem(
                label: AppLocalizations.of(context)!.audiences,
                icon: const Icon(Icons.door_back_door_outlined),
              ),
              BottomNavigationBarItem(
                label: AppLocalizations.of(context)!.settings,
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
