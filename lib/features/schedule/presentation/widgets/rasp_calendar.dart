import 'package:flutter/material.dart' as flutter;
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:ikms/i18n/tr.dart';
import 'package:material_ui/material_ui.dart';
import 'package:table_calendar/table_calendar.dart';

/// Schedule [TableCalendar] with event-count markers.
class RaspCalendar extends StatelessWidget {
  /// Creates the calendar section.
  const RaspCalendar({
    super.key,
    required this.firstDay,
    required this.lastDay,
    required this.focusedDay,
    required this.calendarFormat,
    required this.localeLanguageCode,
    required this.eventCountFor,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.onFormatChanged,
    this.calendarKey,
  });

  final Key? calendarKey;
  final DateTime firstDay;
  final DateTime lastDay;
  final DateTime focusedDay;
  final CalendarFormat calendarFormat;
  final String localeLanguageCode;
  final int Function(DateTime day) eventCountFor;
  final void Function(DateTime selected, DateTime focused) onDaySelected;
  final void Function(DateTime focused) onPageChanged;
  final void Function(CalendarFormat format) onFormatChanged;

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

  Widget _buildEventMarker(
    BuildContext context,
    DateTime day,
    List<dynamic> events,
  ) {
    final count = eventCountFor(day);
    if (count == 0) return const SizedBox();

    final color = _eventColors[count % _eventColors.length];
    return isSameDay(focusedDay, day)
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // table_calendar uses flutter/material InkWell; material_ui Material is
    // behind a LookupBoundary, so wrap with SDK Material for ink ancestors.
    return flutter.Material(
      type: flutter.MaterialType.transparency,
      child: TableCalendar(
        key: calendarKey,
        startingDayOfWeek: StartingDayOfWeek.monday,
        firstDay: firstDay,
        lastDay: lastDay,
        focusedDay: focusedDay,
        weekendDays: const [DateTime.sunday],
        locale: localeLanguageCode,
        selectedDayPredicate: (day) => isSameDay(focusedDay, day),
        onDaySelected: onDaySelected,
        onPageChanged: onPageChanged,
        availableCalendarFormats: {
          CalendarFormat.month: 'month'.tr,
          CalendarFormat.twoWeeks: 'two_week'.tr,
          CalendarFormat.week: 'week'.tr,
        },
        calendarFormat: calendarFormat,
        onFormatChanged: onFormatChanged,
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
      ),
    );
  }
}
