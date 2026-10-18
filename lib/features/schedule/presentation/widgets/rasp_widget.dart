import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:ikms/core/di/context_extensions.dart';
import 'package:ikms/domain/entities/lesson.dart';
import 'package:ikms/features/schedule/presentation/widgets/rasp_banner_ads.dart';
import 'package:ikms/features/schedule/presentation/widgets/rasp_calendar.dart';
import 'package:ikms/features/schedule/presentation/widgets/rasp_day_index.dart';
import 'package:ikms/features/schedule/presentation/widgets/rasp_schedule_list.dart';
import 'package:ikms/i18n/tr.dart';
import 'package:material_ui/material_ui.dart';
import 'package:table_calendar/table_calendar.dart';

/// Calendar-driven schedule list with optional ad banner.
class RaspWidget extends ConsumerStatefulWidget {
  /// Creates a schedule widget bound to [raspElements].
  const RaspWidget({
    super.key,
    required this.isLoaded,
    required this.raspElements,
    this.isError = false,
    this.onRetry,
    this.onBackPressed,
    this.headerText,
  });

  /// Whether schedule data has finished loading.
  final bool isLoaded;

  /// Whether the last load failed.
  final bool isError;

  /// Retry callback when [isError] is true.
  final VoidCallback? onRetry;

  /// Live schedule entries to display.
  final ValueNotifier<List<Lesson>> raspElements;

  /// Optional back action for detail pages.
  final Function()? onBackPressed;

  /// Optional subtitle shown in the app bar.
  final String? headerText;

  @override
  ConsumerState<RaspWidget> createState() => _RaspWidgetState();
}

class _RaspWidgetState extends ConsumerState<RaspWidget> {
  late List<Lesson> _filteredLesson;
  DateTime _selectedDay = normalizeDate(DateTime.now());
  CalendarFormat _calendarFormat = CalendarFormat.week;
  RaspDayIndex _dayIndex = RaspDayIndex.fromLessons(const []);

  @override
  void initState() {
    super.initState();
    _initializeLesson();
    widget.raspElements.addListener(_initializeLesson);
  }

  @override
  void dispose() {
    widget.raspElements.removeListener(_initializeLesson);
    super.dispose();
  }

  void _initializeLesson() {
    _dayIndex = RaspDayIndex.fromLessons(widget.raspElements.value);
    setState(() {
      if (_selectedDay.isAfter(_dayIndex.lastDay)) {
        _selectedDay = _dayIndex.lastDay;
      } else if (_selectedDay.isBefore(_dayIndex.firstDay)) {
        _selectedDay = _dayIndex.firstDay;
      }
      _filteredLesson = widget.raspElements.value
          .where((element) => isSameDay(element.date, _selectedDay))
          .toList();
    });
  }

  DateTime get _normalizedSelectedDay {
    if (_selectedDay.isAfter(_dayIndex.lastDay)) return _dayIndex.lastDay;
    if (_selectedDay.isBefore(_dayIndex.firstDay)) return _dayIndex.firstDay;
    return _selectedDay;
  }

  void _onDaySelected(DateTime selected, DateTime focused) {
    setState(() => _selectedDay = selected);
    _initializeLesson();
  }

  void _onPageChanged(DateTime focused) {
    setState(() => _selectedDay = focused);
    _initializeLesson();
  }

  void _onFormatChanged(CalendarFormat format) {
    setState(() => _calendarFormat = format);
  }

  void _onSwipeLeft() {
    if (_normalizedSelectedDay.isBefore(_dayIndex.lastDay)) {
      setState(
        () =>
            _selectedDay = _normalizedSelectedDay.add(const Duration(days: 1)),
      );
      _initializeLesson();
    }
  }

  void _onSwipeRight() {
    if (_normalizedSelectedDay.isAfter(_dayIndex.firstDay)) {
      setState(
        () =>
            _selectedDay = _normalizedSelectedDay.add(const Duration(days: -1)),
      );
      _initializeLesson();
    }
  }

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
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          )
        : Text(
            widget.headerText == null
                ? 'schedule'.tr
                : '${'schedule'.tr} - ${widget.headerText}',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            RaspCalendar(
              calendarKey: ValueKey(widget.raspElements.value),
              firstDay: _dayIndex.firstDay,
              lastDay: _dayIndex.lastDay,
              focusedDay: _normalizedSelectedDay,
              calendarFormat: _calendarFormat,
              localeLanguageCode: context.appLocale.languageCode,
              eventCountFor: _dayIndex.eventCountFor,
              onDaySelected: _onDaySelected,
              onPageChanged: _onPageChanged,
              onFormatChanged: _onFormatChanged,
            ),
            const Divider(),
            Expanded(
              child: RaspLessonBody(
                isLoaded: widget.isLoaded,
                isError: widget.isError,
                filteredLesson: _filteredLesson,
                onSwipeLeft: _onSwipeLeft,
                onSwipeRight: _onSwipeRight,
                onRetry: widget.onRetry,
              ),
            ),
            const RaspBannerAds(),
          ],
        ),
      ),
    );
  }
}
