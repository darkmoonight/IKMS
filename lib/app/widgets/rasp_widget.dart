import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RaspData {
  final String discipline;
  final String teacher;
  final String audience;
  final DateTime date;
  final String beginning;
  final String end;

  RaspData(
      {required this.discipline,
      required this.teacher,
      required this.audience,
      required this.date,
      required this.beginning,
      required this.end});
}

class RaspWidget extends StatefulWidget {
  final ThemeData theme;
  final double squareWidth;
  final bool isLoaded;
  final List<RaspData> raspElements;
  final Function()? onBackPressed;
  final String? headerText;

  const RaspWidget(
      {super.key,
      required this.theme,
      required this.squareWidth,
      required this.isLoaded,
      required this.raspElements,
      this.onBackPressed,
      this.headerText});

  @override
  State<RaspWidget> createState() => _RaspWidgetState();
}

class _RaspWidgetState extends State<RaspWidget> {
  late List<RaspData> raspElementsFiltered;
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  CalendarFormat calendarFormat = CalendarFormat.week;

  RaspData get firstDay =>
      widget.raspElements.reduce((a, b) => a.date.isBefore(b.date) ? a : b);

  RaspData get lastDay =>
      widget.raspElements.reduce((a, b) => a.date.isAfter(b.date) ? a : b);

  @override
  void initState() {
    super.initState();
    getRasp();
  }

  void getRasp() {
    setState(
      () {
        raspElementsFiltered = widget.raspElements.where(
          (element) {
            return element.date.isAtSameMomentAs(selectedDay);
          },
        ).toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tag = Localizations.maybeLocaleOf(context)?.toLanguageTag();
    return SafeArea(
      child: Column(
        children: [
          widget.onBackPressed == null
              ? Padding(
                  padding: EdgeInsets.only(top: 15.w),
                  child: Text(
                    AppLocalizations.of(context)!.schedule,
                    style: widget.theme.textTheme.headline2,
                    textAlign: TextAlign.center,
                  ),
                )
              : Padding(
                  padding: EdgeInsets.only(top: 15.w, left: 10.w),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: widget.onBackPressed,
                        icon: const Icon(Icons.arrow_back),
                        iconSize: widget.theme.iconTheme.size,
                        color: widget.theme.iconTheme.color,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                      SizedBox(
                        width: 5.w,
                      ),
                      Expanded(
                        child: Text(
                          widget.headerText == null
                              ? AppLocalizations.of(context)!.schedule
                              : '${AppLocalizations.of(context)!.schedule} - ${widget.headerText}',
                          style: widget.theme.textTheme.headline4,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ],
                  ),
                ),
          TableCalendar(
            startingDayOfWeek: StartingDayOfWeek.monday,
            firstDay: firstDay.date,
            lastDay: lastDay.date,
            focusedDay: selectedDay,
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
            color: widget.theme.dividerColor,
            height: 20.w,
            thickness: 2,
            indent: 10.w,
            endIndent: 10.w,
          ),
          Builder(
            builder: (context) {
              // ignore: prefer_is_empty
              return raspElementsFiltered.length == 0
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
                              style: widget.theme.textTheme.headline3,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: Visibility(
                        visible: widget.isLoaded,
                        replacement: const Center(
                          child: CircularProgressIndicator(),
                        ),
                        child: ListView.builder(
                          itemCount: raspElementsFiltered.length,
                          itemBuilder: (BuildContext context, int index) {
                            final raspElementPage = raspElementsFiltered[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15.w, vertical: 10.w),
                                  child: Text(
                                      '${raspElementPage.beginning}-${raspElementPage.end}',
                                      style: widget.theme.textTheme.headline6),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.w, vertical: 5.w),
                                  child: Container(
                                    height: 120.w,
                                    width: widget.squareWidth,
                                    decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(15)),
                                        color: widget.theme.primaryColor),
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
                                              style: widget
                                                  .theme.textTheme.headline6),
                                          Flexible(
                                              child: SizedBox(height: 10.w)),
                                          Text(raspElementPage.teacher,
                                              style: widget.theme
                                                  .primaryTextTheme.subtitle1),
                                          Flexible(
                                              child: SizedBox(height: 10.w)),
                                          Text(raspElementPage.audience,
                                              style: widget.theme
                                                  .primaryTextTheme.subtitle1),
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
    );
  }
}
