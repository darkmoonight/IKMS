import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project_cdis/app/data/shedule.dart';
import 'package:project_cdis/app/modules/audiences/view.dart';
import 'package:project_cdis/app/modules/professors/view.dart';
import 'package:project_cdis/app/modules/settings/view.dart';
import 'package:project_cdis/main.dart';
import 'package:project_cdis/app/widgets/rasp_widget.dart';

import '../../services/remote_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var isLoaded = false;
  List<RaspData> raspData = <RaspData>[];
  final tabIndex = 0.obs;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    final raspElements = await RomoteServise()
        .getRaspsElementData(objectbox.settings.group.target?.id);
    setState(() {
      raspData = raspElements
          .map((RaspElement element) => RaspData(
              discipline: element.discipline,
              teacher: element.teacher,
              audience: element.audience,
              date: DateFormat("yyyy-MM-ddThh:mm:ss").parseUTC(element.date),
              beginning: element.beginning,
              end: element.end))
          .toList();
      isLoaded = true;
    });
  }

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    final squareWidth = Get.width;
    return Scaffold(
      body: Obx(
        (() => IndexedStack(
              index: tabIndex.value,
              children: [
                RaspWidget(
                  theme: theme,
                  squareWidth: squareWidth,
                  isLoaded: isLoaded,
                  raspElements: raspData,
                ),
                const ProfessorsPage(),
                const AudiencesPage(),
                const SettingsPage(),
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
            backgroundColor: theme.primaryColor,
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
