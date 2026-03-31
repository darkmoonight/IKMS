import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:ikms/app/controller/ads_controller.dart';
import 'package:ikms/app/data/db.dart';
import 'package:ikms/app/ui/widgets/list_empty.dart';
import 'package:ikms/app/ui/widgets/shimmer.dart';
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
  late List<Schedule> _filteredSchedule;
  final _adsController = Get.put(AdsController());
  final _bannerAd = BannerAd(
    adUnitId: 'R-M-2101511-1',
    adSize: BannerAdSize.inline(width: Get.size.width.round(), maxHeight: 50),
    adRequest: const AdRequest(),
    onAdLoaded: () {},
    onAdFailedToLoad: (error) {},
  );

  DateTime _selectedDay = normalizeDate(DateTime.now());
  CalendarFormat _calendarFormat = CalendarFormat.week;

  static const List<MaterialColor> _eventColors = <MaterialColor>[
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
    _initializeSchedule();
    widget.raspElements.addListener(_initializeSchedule);
  }

  @override
  void dispose() {
    widget.raspElements.removeListener(_initializeSchedule);
    super.dispose();
  }

  void _initializeSchedule() {
    setState(() {
      if (_selectedDay.isAfter(_lastDay)) {
        _selectedDay = _lastDay;
      } else if (_selectedDay.isBefore(_firstDay)) {
        _selectedDay = _firstDay;
      }
      _filteredSchedule = widget.raspElements.value
          .where((element) => isSameDay(element.date, _selectedDay))
          .toList();
    });
  }

  DateTime get _firstDay => widget.raspElements.value.isNotEmpty
      ? widget.raspElements.value
            .reduce((a, b) => a.date.isBefore(b.date) ? a : b)
            .date
      : DateTime.now();

  DateTime get _lastDay => widget.raspElements.value.isNotEmpty
      ? widget.raspElements.value
            .reduce((a, b) => a.date.isAfter(b.date) ? a : b)
            .date
      : DateTime.now();

  DateTime get _normalizedSelectedDay {
    if (_selectedDay.isAfter(_lastDay)) return _lastDay;
    if (_selectedDay.isBefore(_firstDay)) return _firstDay;
    return _selectedDay;
  }

  int _getEventCountForDay(DateTime date) {
    final schedulesOnDay = widget.raspElements.value
        .where((element) => isSameDay(element.date, date))
        .toList();

    final Set<int> uniquePairs = {};
    for (final schedule in schedulesOnDay) {
      uniquePairs.add(schedule.pair);
    }

    return uniquePairs.length;
  }

  void _onDaySelected(DateTime selected, DateTime focused) {
    setState(() => _selectedDay = selected);
    _initializeSchedule();
  }

  void _onPageChanged(DateTime focused) {
    setState(() => _selectedDay = focused);
    _initializeSchedule();
  }

  void _onFormatChanged(CalendarFormat format) {
    setState(() => _calendarFormat = format);
  }

  Widget _buildEventMarker(
    BuildContext context,
    DateTime day,
    List<dynamic> events,
  ) {
    final count = _getEventCountForDay(day);
    if (count == 0) return const SizedBox();

    final color = _eventColors[count % _eventColors.length];
    return isSameDay(_normalizedSelectedDay, day)
        ? Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Center(
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          )
        : Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          );
  }

  String _cleanGroupName(String group) {
    return group
        .replaceAll(RegExp(r',\s*п/г\s*\d+\s*'), '')
        .replaceAll(RegExp(r',\s*п/г\s*[А-Яа-я]+\s*'), '')
        .trim();
  }

  Widget _buildScheduleItem(BuildContext context, Schedule element) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: IntrinsicHeight(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      element.begin,
                      style: context.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      '—',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      element.end,
                      style: context.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    Text(
                      _cleanGroupName(element.discipline),
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      element.teacher,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      spacing: 6,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                IconsaxPlusLinear.buildings_2,
                                size: 12,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onTertiaryContainer,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                element.audience,
                                style: context.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onTertiaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              element.group,
                              style: context.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() => ListView.builder(
    itemCount: 5,
    itemBuilder: (BuildContext context, int index) => Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const MyShimmer(height: 40, width: 50),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  const MyShimmer(height: 16, width: double.infinity),
                  const MyShimmer(height: 14, width: 150),
                  const MyShimmer(height: 14, width: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildEmptySchedule() =>
      ListEmpty(img: 'assets/images/no.png', text: 'no_par'.tr);

  List<Map<String, dynamic>> _getGroupedSchedules() {
    final Map<int, List<Schedule>> groupedByPair = {};

    for (final schedule in _filteredSchedule) {
      final key = schedule.pair;
      groupedByPair[key] ??= [];
      groupedByPair[key]!.add(schedule);
    }

    return groupedByPair.entries.map((entry) {
      final schedules = entry.value;
      if (schedules.length == 1) {
        return {'schedule': schedules.first, 'isGrouped': false};
      }

      final first = schedules.first;
      final teachers = schedules
          .map((s) => s.teacher)
          .where((t) => t.isNotEmpty)
          .toSet()
          .join(', ');
      final audiences = schedules
          .map((s) => s.audience)
          .where((a) => a.isNotEmpty)
          .toSet()
          .join(', ');
      final groups = schedules
          .map((s) => s.group)
          .where((g) => g.isNotEmpty)
          .toSet()
          .join(', ');

      final merged = Schedule(
        dateTime: first.date,
        begin: first.begin,
        end: first.end,
        pair: first.pair,
        discipline: first.discipline,
        teacher: teachers,
        audience: audiences,
        group: groups,
      );

      return {'schedule': merged, 'isGrouped': true};
    }).toList()..sort(
      (a, b) => (a['schedule'] as Schedule).pair.compareTo(
        (b['schedule'] as Schedule).pair,
      ),
    );
  }

  Widget _buildScheduleList() {
    final groupedSchedules = _getGroupedSchedules();

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: groupedSchedules.length,
      itemBuilder: (BuildContext context, int index) => _buildScheduleItem(
        context,
        groupedSchedules[index]['schedule'] as Schedule,
      ),
    );
  }

  Widget _buildCalendar() {
    final colorScheme = Theme.of(context).colorScheme;

    return TableCalendar(
      key: ValueKey(widget.raspElements.value),
      startingDayOfWeek: StartingDayOfWeek.monday,
      firstDay: _firstDay,
      lastDay: _lastDay,
      focusedDay: _normalizedSelectedDay,
      weekendDays: const [DateTime.sunday],
      locale: locale.languageCode,
      selectedDayPredicate: (day) => isSameDay(_normalizedSelectedDay, day),
      onDaySelected: _onDaySelected,
      onPageChanged: _onPageChanged,
      availableCalendarFormats: {
        CalendarFormat.month: 'month'.tr,
        CalendarFormat.twoWeeks: 'two_week'.tr,
        CalendarFormat.week: 'week'.tr,
      },
      calendarFormat: _calendarFormat,
      onFormatChanged: _onFormatChanged,
      calendarBuilders: CalendarBuilders(markerBuilder: _buildEventMarker),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: colorScheme.primary,
          shape: BoxShape.circle,
        ),
        todayTextStyle: TextStyle(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
        selectedTextStyle: TextStyle(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
        weekendTextStyle: TextStyle(color: colorScheme.error),
        outsideDaysVisible: false,
        markerSize: 16,
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
        formatButtonShowsNext: false,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        formatButtonTextStyle: TextStyle(
          fontSize: 13,
          color: colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
        formatButtonDecoration: BoxDecoration(
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.5),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        leftChevronIcon: Icon(
          IconsaxPlusLinear.arrow_left_1,
          color: colorScheme.onSurface,
          size: 20,
        ),
        rightChevronIcon: Icon(
          IconsaxPlusLinear.arrow_right_3,
          color: colorScheme.onSurface,
          size: 20,
        ),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        weekendStyle: TextStyle(
          color: colorScheme.error.withValues(alpha: 0.7),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildAdBanner() => Obx(
    () => Visibility(
      visible: !_adsController.ads.value,
      child: AdWidget(bannerAd: _bannerAd),
    ),
  );

  PreferredSizeWidget _buildAppBar() => AppBar(
    automaticallyImplyLeading: false,
    centerTitle: widget.onBackPressed == null,
    titleSpacing: 0,
    leading: widget.onBackPressed == null
        ? null
        : IconButton(
            onPressed: widget.onBackPressed,
            icon: const Icon(IconsaxPlusLinear.arrow_left_3, size: 20),
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
  );

  void _onSwipeLeft() {
    if (_normalizedSelectedDay.isBefore(_lastDay)) {
      setState(
        () =>
            _selectedDay = _normalizedSelectedDay.add(const Duration(days: 1)),
      );
      _initializeSchedule();
    }
  }

  void _onSwipeRight() {
    if (_normalizedSelectedDay.isAfter(_firstDay)) {
      setState(
        () =>
            _selectedDay = _normalizedSelectedDay.add(const Duration(days: -1)),
      );
      _initializeSchedule();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: _buildAppBar(),
    body: SafeArea(
      child: Column(
        children: [
          _buildCalendar(),
          const Divider(),
          Expanded(
            child: Visibility(
              visible: widget.isLoaded,
              replacement: _buildLoadingIndicator(),
              child: Swipe(
                horizontalMinDisplacement: 20,
                onSwipeLeft: _onSwipeLeft,
                onSwipeRight: _onSwipeRight,
                child: Visibility(
                  visible: _filteredSchedule.isNotEmpty,
                  replacement: _buildEmptySchedule(),
                  child: _buildScheduleList(),
                ),
              ),
            ),
          ),
          _buildAdBanner(),
        ],
      ),
    ),
  );
}
