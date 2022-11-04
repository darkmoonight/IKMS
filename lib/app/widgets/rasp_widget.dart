import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_cdis/app/data/schema.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RaspWidget extends StatefulWidget {
  final bool isLoaded;
  final ValueNotifier<List<Schedule>> raspElements;
  final Function()? onBackPressed;
  final String? headerText;

  const RaspWidget(
      {super.key,
      required this.isLoaded,
      required this.raspElements,
      this.onBackPressed,
      this.headerText});

  @override
  State<RaspWidget> createState() => _RaspWidgetState();
}

class _RaspWidgetState extends State<RaspWidget> {
  late List<Schedule> raspElementsFiltered;

  // TODO, ISSUE: change selected day to max value on case if schedule is old
  DateTime selectedDay = normalizeDate(DateTime.now());
  CalendarFormat calendarFormat = CalendarFormat.week;

  DateTime get firstDay => widget.raspElements.value.isNotEmpty
      ? widget.raspElements.value
          .reduce((a, b) => a.date.isBefore(b.date) ? a : b)
          .date
      : DateTime.now();

  DateTime get lastDay => widget.raspElements.value.isNotEmpty
      ? widget.raspElements.value
          .reduce((a, b) => a.date.isAfter(b.date) ? a : b)
          .date
      : DateTime.now();

  @override
  void initState() {
    super.initState();
    getRasp();
    widget.raspElements.addListener(getRasp);
  }

  @override
  void dispose() {
    widget.raspElements.removeListener(getRasp);
    super.dispose();
  }

  void getRasp() {
    setState(
      () {
        raspElementsFiltered = widget.raspElements.value.where(
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
                    style: Theme.of(context).textTheme.headline2,
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
                        iconSize: Theme.of(context).iconTheme.size,
                        color: Theme.of(context).iconTheme.color,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                      SizedBox(
                        width: 5.w,
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: 5.w),
                          child: Text(
                            widget.headerText == null
                                ? AppLocalizations.of(context)!.schedule
                                : '${AppLocalizations.of(context)!.schedule} - ${widget.headerText}',
                            style: Theme.of(context).textTheme.headline4,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          TableCalendar(
            key: ValueKey(widget.raspElements.value),
            startingDayOfWeek: StartingDayOfWeek.monday,
            firstDay: firstDay,
            lastDay: lastDay,
            focusedDay: selectedDay,
            locale: '$tag',
            selectedDayPredicate: (day) {
              return isSameDay(selectedDay, day);
            },
            onDaySelected: (selected, focused) {
              setState(() {
                selectedDay = selected;
              });
              getRasp();
            },
            onPageChanged: (focused) {
              setState(() {
                selectedDay = focused;
              });
              getRasp();
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
            color: Theme.of(context).dividerColor,
            height: 20.w,
            thickness: 2,
            indent: 10.w,
            endIndent: 10.w,
          ),
          Expanded(
            child: Visibility(
              visible: widget.isLoaded,
              replacement: const Center(
                child: CircularProgressIndicator(),
              ),
              child: Visibility(
                visible: raspElementsFiltered.isNotEmpty,
                replacement: Center(
                  child: ListView(
                    children: [
                      Image.asset(
                        'assets/images/no.png',
                        scale: 1,
                      ),
                      Text(
                        AppLocalizations.of(context)!.no_par,
                        style: Theme.of(context).textTheme.headline3,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                child: Builder(builder: (context) {
                  final seen = <String>{};
                  var raspElements = raspElementsFiltered
                      .where((element) => seen.add(element.pair.toString()))
                      .toList();
                  return ListView.builder(
                    itemCount: raspElements.length,
                    itemBuilder: (BuildContext context, int index) {
                      final raspElementPage = raspElements[index];
                      final groupList = raspElementPage.group;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15.w, vertical: 10.w),
                            child: Text(
                                '${raspElementPage.begin}-${raspElementPage.end}',
                                style: Theme.of(context).textTheme.headline6),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 5.w),
                            child: Container(
                              // TODO: check value is useless
                              // width: Get.width,
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15)),
                                  color: Theme.of(context).primaryColor),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15.w),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(child: SizedBox(height: 15.w)),
                                    Text(raspElementPage.discipline,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6),
                                    Flexible(child: SizedBox(height: 10.w)),
                                    Text(raspElementPage.teacher,
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .subtitle1),
                                    Flexible(child: SizedBox(height: 10.w)),
                                    groupList.length < 30
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(raspElementPage.audience,
                                                  style: Theme.of(context)
                                                      .primaryTextTheme
                                                      .subtitle1),
                                              Text(raspElementPage.group,
                                                  style: Theme.of(context)
                                                      .primaryTextTheme
                                                      .subtitle1),
                                            ],
                                          )
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(raspElementPage.audience,
                                                  style: Theme.of(context)
                                                      .primaryTextTheme
                                                      .subtitle1),
                                              Flexible(
                                                  child:
                                                      SizedBox(height: 10.w)),
                                              Text(raspElementPage.group,
                                                  style: Theme.of(context)
                                                      .primaryTextTheme
                                                      .subtitle1),
                                            ],
                                          ),
                                    Flexible(child: SizedBox(height: 15.w)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
