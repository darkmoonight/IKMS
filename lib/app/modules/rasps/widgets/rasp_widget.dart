import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:ficonsax/ficonsax.dart';
import 'package:ikms/app/data/schema.dart';
import 'package:ikms/app/widgets/list_empty.dart';
import 'package:ikms/app/widgets/shimmer.dart';
import 'package:ikms/main.dart';
import 'package:swipe/swipe.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:yandex_mobileads/mobile_ads.dart';

class RaspWidget extends StatefulWidget {
  const RaspWidget({
    super.key,
    required this.isLoaded,
    required this.raspElements,
    this.onBackPressed,
    this.headerText,
  });
  final bool isLoaded;
  final ValueNotifier<List<Schedule>> raspElements;
  final Function()? onBackPressed;
  final String? headerText;

  @override
  State<RaspWidget> createState() => _RaspWidgetState();
}

class _RaspWidgetState extends State<RaspWidget> {
  late List<Schedule> raspElementsFiltered;

  final banner = BannerAd(
    adUnitId: 'R-M-2101511-1',
    adSize: BannerAdSize.inline(width: Get.size.width.round(), maxHeight: 50),
    adRequest: const AdRequest(),
    onAdLoaded: () {},
    onAdFailedToLoad: (error) {},
  );

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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: widget.onBackPressed == null ? true : false,
        titleSpacing: 0,
        leading: widget.onBackPressed == null
            ? null
            : IconButton(
                onPressed: widget.onBackPressed,
                icon: const Icon(
                  IconsaxOutline.arrow_left_1,
                  size: 20,
                ),
              ),
        title: widget.onBackPressed == null
            ? Text(
                'schedule'.tr,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              )
            : Text(
                widget.headerText == null
                    ? 'schedule'.tr
                    : '${'schedule'.tr} - ${widget.headerText}',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            TableCalendar(
              key: ValueKey(widget.raspElements.value),
              startingDayOfWeek: StartingDayOfWeek.monday,
              firstDay: firstDay,
              lastDay: lastDay,
              focusedDay: selectedDay,
              weekendDays: const [DateTime.sunday],
              locale: locale.languageCode,
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
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            )
                          : Text(
                              getCountEventsCalendar(day).toString(),
                              style: TextStyle(
                                color: primaries[getCountEventsCalendar(day)],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            )
                      : null;
                },
              ),
            ),
            const Divider(),
            Expanded(
              child: Visibility(
                visible: widget.isLoaded,
                replacement: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (BuildContext context, int index) {
                    return const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyShimmer(
                          edgeInsetsMargin: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          hight: 20,
                          width: 100,
                        ),
                        MyShimmer(
                          edgeInsetsMargin: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          hight: 100,
                        ),
                      ],
                    );
                  },
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
                    replacement: ListEmpty(
                      img: 'assets/images/no.png',
                      text: 'no_par'.tr,
                    ),
                    child: GroupedListView<Schedule, String>(
                        elements: raspElementsFiltered,
                        groupBy: (element) {
                          return '${element.begin}-${element.end}';
                        },
                        groupSeparatorBuilder: (String groupByValue) => Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
                              child: Text(
                                groupByValue,
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        itemBuilder: (BuildContext context, Schedule element) {
                          final raspElementPage = element;
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    raspElementPage.discipline,
                                    style:
                                        context.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Flexible(
                                    child: Text(
                                      raspElementPage.teacher,
                                      style: context.textTheme.bodyMedium
                                          ?.copyWith(color: Colors.grey),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          raspElementPage.audience,
                                          style: context.textTheme.bodyMedium
                                              ?.copyWith(color: Colors.grey),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          raspElementPage.group,
                                          style: context.textTheme.bodyMedium
                                              ?.copyWith(color: Colors.grey),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
                ),
              ),
            ),
            AdWidget(bannerAd: banner),
          ],
        ),
      ),
    );
  }
}
