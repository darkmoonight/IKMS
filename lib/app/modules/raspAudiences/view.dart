import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_storage/get_storage.dart';
import 'package:project_cdis/app/data/shedule.dart';
import 'package:project_cdis/app/services/remote_services.dart';
import 'package:table_calendar/table_calendar.dart';

class RaspAudiencesPage extends StatefulWidget {
  const RaspAudiencesPage({super.key});

  @override
  State<RaspAudiencesPage> createState() => _RaspAudiencesPageState();
}

class _RaspAudiencesPageState extends State<RaspAudiencesPage> {
  DateTime now = DateTime.now();
  DateTime? selectedDay;
  DateTime focusedDay = DateTime.now();
  var isLoaded = false;
  String? dateNow;
  final box = GetStorage();
  CalendarFormat calendarFormat = CalendarFormat.week;

  List<RaspElement>? raspElements;
  List<RaspElement>? raspElementsFiltered;

  @override
  void initState() {
    super.initState();
    selectedDay = DateTime(now.year, now.month, now.day);

    getData();
  }

  getData() async {
    raspElements = await RomoteServise().getRaspsAudElementData();
    raspElementsFiltered = raspElements;
    if (raspElements != null) {
      setState(
        () {
          isLoaded = true;
          getRasp();
        },
      );
    }
  }

  void getRasp() {
    var value = selectedDay!.toIso8601String().substring(0, 19);
    setState(
      () {
        raspElementsFiltered = raspElements?.where(
          (element) {
            var raspTitle = element.date;
            return raspTitle.contains(value);
          },
        ).toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var tag = Localizations.maybeLocaleOf(context)?.toLanguageTag();
    var theme = Theme.of(context);
    final squareWidth = Get.width;
    final audName = box.read('isAudName');
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 15.w, left: 10.w),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(Icons.arrow_back),
                    iconSize: theme.iconTheme.size,
                    color: theme.iconTheme.color,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                  SizedBox(
                    width: 5.w,
                  ),
                  Expanded(
                    child: Text(
                      '${AppLocalizations.of(context)!.schedule} - $audName',
                      style: theme.textTheme.headline4,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                ],
              ),
            ),
            TableCalendar(
              startingDayOfWeek: StartingDayOfWeek.monday,
              // TODO: add calendar limit from schedule
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
                CalendarFormat.month: AppLocalizations.of(context)!.month,
                CalendarFormat.twoWeeks: AppLocalizations.of(context)!.two_week,
                CalendarFormat.week: AppLocalizations.of(context)!.week
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
                return raspElementsFiltered?.length == 0
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
                            itemCount: raspElementsFiltered?.length,
                            itemBuilder: (BuildContext context, int index) {
                              final raspElementPage =
                                  raspElementsFiltered?[index];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15.w, vertical: 10.w),
                                    child: Text(
                                        '${raspElementPage!.beginning}-${raspElementPage.end}',
                                        style: theme.textTheme.headline6),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10.w, vertical: 5.w),
                                    child: Container(
                                      height: 120.w,
                                      width: squareWidth,
                                      decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(15)),
                                          color: theme.primaryColor),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15.w),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(raspElementPage.discipline,
                                                style:
                                                    theme.textTheme.headline6),
                                            Flexible(
                                                child: SizedBox(height: 10.w)),
                                            Text(raspElementPage.teacher,
                                                style: theme.primaryTextTheme
                                                    .subtitle1),
                                            Flexible(
                                                child: SizedBox(height: 10.w)),
                                            Text(raspElementPage.audience,
                                                style: theme.primaryTextTheme
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
    );
  }
}
