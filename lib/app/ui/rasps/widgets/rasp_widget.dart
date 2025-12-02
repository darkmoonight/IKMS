import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
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

  void _initializeSchedule() => setState(
    () => _filteredSchedule = widget.raspElements.value
        .where((element) => element.date.isAtSameMomentAs(_selectedDay))
        .toList(),
  );

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
    final seen = <String>{};
    return widget.raspElements.value
        .where(
          (element) =>
              element.date.isAtSameMomentAs(date) &&
              seen.add(element.pair.toString()),
        )
        .length;
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

  Widget _buildScheduleItem(BuildContext context, Schedule element) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          Text(
            element.discipline,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          Flexible(
            child: Text(
              element.teacher,
              style: context.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  element.audience,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: Text(
                  element.group,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
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

  Widget _buildLoadingIndicator() => ListView.builder(
    itemCount: 5,
    itemBuilder: (BuildContext context, int index) => const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyShimmer(
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          height: 20,
          width: 100,
        ),
        MyShimmer(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          height: 100,
        ),
      ],
    ),
  );

  Widget _buildEmptySchedule() =>
      ListEmpty(img: 'assets/images/no.png', text: 'no_par'.tr);

  Widget _buildScheduleList() => GroupedListView<Schedule, String>(
    physics: const AlwaysScrollableScrollPhysics(),
    elements: _filteredSchedule,
    groupBy: (element) => '${element.begin}-${element.end}',
    groupSeparatorBuilder: (String groupByValue) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Text(
        groupByValue,
        style: context.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    itemBuilder: _buildScheduleItem,
  );

  Widget _buildCalendar() => TableCalendar(
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
  );

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
