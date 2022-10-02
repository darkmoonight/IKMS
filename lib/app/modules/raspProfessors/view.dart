import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_storage/get_storage.dart';
import 'package:project_cdis/app/data/shedule.dart';
import 'package:project_cdis/app/services/remote_services.dart';
import 'package:table_calendar/table_calendar.dart';

class RaspProfessorsPage extends StatefulWidget {
  const RaspProfessorsPage({super.key});

  @override
  State<RaspProfessorsPage> createState() => _RaspProfessorsPageState();
}

class _RaspProfessorsPageState extends State<RaspProfessorsPage> {
  DateTime now = DateTime.now();
  DateTime? selectedDay;
  DateTime focusedDay = DateTime.now();
  var isLoaded = false;
  String? dateNow;
  final box = GetStorage();
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
    raspElement = await RomoteServise().getRaspProfElementData();
    raspElements = await RomoteServise().getRaspsProfElementData();
    if (raspElement != null) {
      setState(() {
        isLoaded = true;
        getRasp();
      });
    }
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
    final profName = box.read('isProfessorName');
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
                      '${AppLocalizations.of(context)!.schedule} - $profName',
                      style: theme.textTheme.headline4,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                ],
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
                setState(() {
                  selectedDay = selected;
                  focusedDay = focused;
                  getRasp();
                });
              },
              onPageChanged: (focused) {
                focusedDay = focused;
              },
              availableCalendarFormats: {
                CalendarFormat.month: AppLocalizations.of(context)!.month,
                CalendarFormat.week: AppLocalizations.of(context)!.week
              },
              calendarFormat: calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  calendarFormat = format;
                });
              },
            ),
            Divider(
              color: theme.dividerColor,
              height: 20.w,
              thickness: 2,
              indent: 10.w,
              endIndent: 10.w,
            ),
            Expanded(
              child: Visibility(
                visible: isLoaded,
                replacement: const Center(
                  child: CircularProgressIndicator(),
                ),
                child: ListView.builder(
                  itemCount: raspElements?.length,
                  itemBuilder: (BuildContext context, int index) {
                    final raspElementPage = raspElements?[index];
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
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(15)),
                                color: theme.primaryColor),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(raspElementPage.discipline,
                                      style: theme.textTheme.headline6),
                                  Flexible(child: SizedBox(height: 10.w)),
                                  Text(raspElementPage.teacher,
                                      style: theme.primaryTextTheme.subtitle1),
                                  Flexible(child: SizedBox(height: 10.w)),
                                  Text(raspElementPage.audience,
                                      style: theme.primaryTextTheme.subtitle1),
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
            ),
          ],
        ),
      ),
    );
  }
}
