import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:project_cdis/app/data/shedule.dart';
import 'package:project_cdis/app/modules/audiences/view.dart';
import 'package:project_cdis/app/modules/professors/view.dart';
import 'package:project_cdis/app/modules/settings/view.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../services/remote_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime now = DateTime.now();
  DateTime? selectedDay;
  DateTime focusedDay = DateTime.now();
  var isLoaded = false;
  String? dateNow;
  final tabIndex = 0.obs;
  CalendarFormat calendarFormat = CalendarFormat.week;

  Rasp? raspElement;
  List<RaspElement>? raspElements;

  @override
  void initState() {
    super.initState();
    selectedDay = DateTime(now.year, now.month, now.day);

    getData();
  }

  getData() async {
    raspElement = await RomoteServise().getRaspElementData();
    raspElements = await RomoteServise().getRaspsElementData();
    if (raspElement != null) {
      setState(() {
        isLoaded = true;
        getRasp();
      });
    }
  }

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }

  void getRasp() {
    var value = selectedDay!.toIso8601String().substring(0, 19);
    setState(() {
      raspElements = raspElement?.data.rasp.where((element) {
        var raspTitle = element.date;
        return raspTitle.contains(value);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    var tag = Localizations.maybeLocaleOf(context)?.toLanguageTag();
    var theme = Theme.of(context);
    final squareWidth = Get.width;
    return Scaffold(
      body: Obx(
        (() => IndexedStack(
              index: tabIndex.value,
              children: [
                SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 15.w),
                        child: Text(
                          AppLocalizations.of(context)!.schedule,
                          style: theme.textTheme.headline2,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      TableCalendar(
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        firstDay: DateTime(2022, 09, 01),
                        lastDay: DateTime(2100, 09, 01),
                        focusedDay: selectedDay!,
                        locale: '$tag',
                        selectedDayPredicate: (day) {
                          return isSameDay(selectedDay, day);
                        },
                        onDaySelected: (selected, focused) {
                          setState(
                            () {
                              selectedDay = selected;
                              focusedDay = focused;
                              getRasp();
                            },
                          );
                        },
                        onPageChanged: (focused) {
                          focusedDay = focused;
                        },
                        availableCalendarFormats: {
                          CalendarFormat.month:
                              AppLocalizations.of(context)!.month,
                          CalendarFormat.twoWeeks:
                              AppLocalizations.of(context)!.two_week,
                          CalendarFormat.week:
                              AppLocalizations.of(context)!.week
                        },
                        calendarFormat: calendarFormat,
                        onFormatChanged: (format) {
                          setState(
                            () {
                              calendarFormat = format;
                            },
                          );
                        },
                      ),
                      Divider(
                        color: theme.dividerColor,
                        height: 20.w,
                        thickness: 2,
                        indent: 10.w,
                        endIndent: 10.w,
                      ),
                      Builder(
                        builder: (context) {
                          // ignore: prefer_is_empty
                          return raspElements?.length == 0
                              ? Expanded(
                                  child: Center(
                                    child: ListView(
                                      children: [
                                        Image.asset(
                                          'assets/images/no.png',
                                          scale: 1,
                                        ),
                                        Text(
                                          AppLocalizations.of(context)!.no_par,
                                          style: theme.textTheme.headline3,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Expanded(
                                  child: Visibility(
                                    visible: isLoaded,
                                    replacement: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    child: ListView.builder(
                                      itemCount: raspElements?.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final raspElementPage =
                                            raspElements?[index];
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 15.w,
                                                  vertical: 10.w),
                                              child: Text(
                                                  '${raspElementPage!.beginning}-${raspElementPage.end}',
                                                  style: theme
                                                      .textTheme.headline6),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10.w,
                                                  vertical: 5.w),
                                              child: Container(
                                                height: 120.w,
                                                width: squareWidth,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                15)),
                                                    color: theme.primaryColor),
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 15.w),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                          raspElementPage
                                                              .discipline,
                                                          style: theme.textTheme
                                                              .headline6),
                                                      Flexible(
                                                          child: SizedBox(
                                                              height: 10.w)),
                                                      Text(
                                                          raspElementPage
                                                              .teacher,
                                                          style: theme
                                                              .primaryTextTheme
                                                              .subtitle1),
                                                      Flexible(
                                                          child: SizedBox(
                                                              height: 10.w)),
                                                      Text(
                                                          raspElementPage
                                                              .audience,
                                                          style: theme
                                                              .primaryTextTheme
                                                              .subtitle1),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                );
                        },
                      ),
                    ],
                  ),
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
