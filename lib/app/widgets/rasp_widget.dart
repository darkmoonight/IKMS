import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ikms/app/data/schema.dart';
import 'package:shimmer/shimmer.dart';
import 'package:swipe/swipe.dart';
import 'package:table_calendar/table_calendar.dart';

class RaspWidget extends StatefulWidget {
  final bool isLoaded;
  final ValueNotifier<List<Schedule>> raspElements;
  final Function()? onBackPressed;
  final String? headerText;

  const RaspWidget({
    super.key,
    required this.isLoaded,
    required this.raspElements,
    this.onBackPressed,
    this.headerText,
  });

  @override
  State<RaspWidget> createState() => _RaspWidgetState();
}

class _RaspWidgetState extends State<RaspWidget> {
  late List<Schedule> raspElementsFiltered;

  DateTime _selectedDay = normalizeDate(DateTime.now());

  DateTime get selectedDay =>
      _selectedDay.isAfter(lastDay) ? lastDay : _selectedDay;
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

  static const List<MaterialColor> primaries = <MaterialColor>[
    Colors.lightGreen,
    Colors.green,
    Colors.teal,
    Colors.lime,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.red,
    Colors.pink,
  ];

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

  int getCountEventsCalendar(DateTime date) {
    final seen = <String>{};
    return widget.raspElements.value
        .where((element) =>
            element.date.isAtSameMomentAs(date) &&
            seen.add(element.pair.toString()))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final tag = Localizations.maybeLocaleOf(context)?.toLanguageTag();
    return SafeArea(
      child: Column(
        children: [
          widget.onBackPressed == null
              ? Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Text(
                    'schedule'.tr,
                    style: context.theme.textTheme.headline2,
                    textAlign: TextAlign.center,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(top: 15, left: 10),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: widget.onBackPressed,
                        icon: const Icon(Iconsax.arrow_left_1),
                        iconSize: context.theme.iconTheme.size,
                        color: context.theme.iconTheme.color,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: Text(
                            widget.headerText == null
                                ? 'schedule'.tr
                                : '${'schedule'.tr} - ${widget.headerText}',
                            style: context.theme.textTheme.headline4,
                            overflow: TextOverflow.visible,
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
            weekendDays: const [DateTime.sunday],
            locale: '$tag',
            selectedDayPredicate: (day) {
              return isSameDay(selectedDay, day);
            },
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
              });
              getRasp();
            },
            onPageChanged: (focused) {
              setState(() {
                _selectedDay = focused;
              });
              getRasp();
            },
            availableCalendarFormats: {
              CalendarFormat.month: 'month'.tr,
              CalendarFormat.twoWeeks: 'two_week'.tr,
              CalendarFormat.week: 'week'.tr
            },
            calendarFormat: calendarFormat,
            onFormatChanged: (format) {
              setState(
                () {
                  calendarFormat = format;
                },
              );
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                return getCountEventsCalendar(day) != 0
                    ? selectedDay.isAtSameMomentAs(day)
                        ? Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                              color: primaries[getCountEventsCalendar(day)],
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                getCountEventsCalendar(day).toString(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        : Text(
                            getCountEventsCalendar(day).toString(),
                            style: TextStyle(
                              color: primaries[getCountEventsCalendar(day)],
                              fontWeight: FontWeight.bold,
                            ),
                          )
                    : null;
              },
            ),
          ),
          Divider(
            color: context.theme.dividerColor,
            height: 20,
            thickness: 2,
            indent: 10,
            endIndent: 10,
          ),
          Expanded(
            child: Visibility(
              visible: widget.isLoaded,
              replacement: Shimmer.fromColors(
                baseColor: context.theme.primaryColor,
                highlightColor: context.theme.unselectedWidgetColor,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: 5,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          child: Container(
                            width: 100,
                            height: 20,
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              color: context.theme.primaryColor,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          height: 110,
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15)),
                            color: context.theme.primaryColor,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              child: Swipe(
                horizontalMinDisplacement: 20,
                onSwipeLeft: () {
                  if (selectedDay.isBefore(lastDay)) {
                    _selectedDay = selectedDay.add(const Duration(days: 1));
                    getRasp();
                  }
                },
                onSwipeRight: () {
                  if (selectedDay.isAfter(firstDay)) {
                    _selectedDay = selectedDay.add(const Duration(days: -1));
                    getRasp();
                  }
                },
                child: Visibility(
                  visible: raspElementsFiltered.isNotEmpty,
                  replacement: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/no.png',
                            scale: 5,
                          ),
                          Text(
                            'no_par'.tr,
                            style: context.theme.textTheme.headline3,
                          ),
                        ],
                      ),
                    ),
                  ),
                  child: Builder(
                    builder: (context) {
                      final seen = <String>{};
                      var raspElements = raspElementsFiltered
                          .where((element) => seen.add(element.pair.toString()))
                          .toList();
                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: raspElements.length,
                        itemBuilder: (BuildContext context, int index) {
                          final raspElementPage = raspElements[index];
                          final groupList = raspElementPage.group;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                child: Text(
                                  '${raspElementPage.begin}-${raspElementPage.end}',
                                  style: context.theme.textTheme.headline6,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 15),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15)),
                                  color: context.theme.primaryColor,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      raspElementPage.discipline,
                                      style: context.theme.textTheme.headline6,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      raspElementPage.teacher,
                                      style: context
                                          .theme.primaryTextTheme.subtitle1,
                                    ),
                                    const SizedBox(height: 10),
                                    groupList.length < 30
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  raspElementPage.audience,
                                                  style: context
                                                      .theme
                                                      .primaryTextTheme
                                                      .subtitle1,
                                                  overflow:
                                                      TextOverflow.visible,
                                                ),
                                              ),
                                              Text(
                                                raspElementPage.group,
                                                style: context.theme
                                                    .primaryTextTheme.subtitle1,
                                              ),
                                            ],
                                          )
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  raspElementPage.audience,
                                                  style: context
                                                      .theme
                                                      .primaryTextTheme
                                                      .subtitle1,
                                                  overflow:
                                                      TextOverflow.visible,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                raspElementPage.audience,
                                                style: context.theme
                                                    .primaryTextTheme.subtitle1,
                                              ),
                                            ],
                                          ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
