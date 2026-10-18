import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:ikms/core/widgets/list_empty.dart';
import 'package:ikms/core/widgets/shimmer.dart';
import 'package:ikms/domain/entities/lesson.dart';
import 'package:ikms/i18n/tr.dart';
import 'package:material_ui/material_ui.dart';

/// Day list / loading / empty / error body for the schedule screen.
class RaspLessonBody extends StatelessWidget {
  /// Creates the schedule list body.
  const RaspLessonBody({
    super.key,
    required this.isLoaded,
    required this.isError,
    required this.filteredLesson,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    this.onRetry,
  });

  final bool isLoaded;
  final bool isError;
  final List<Lesson> filteredLesson;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final VoidCallback? onRetry;

  static String cleanGroupName(String group) {
    return group
        .replaceAll(RegExp(r',\s*п/г\s*\d+\s*'), '')
        .replaceAll(RegExp(r',\s*п/г\s*[А-Яа-я]+\s*'), '')
        .trim();
  }

  static List<Lesson> groupLessons(List<Lesson> filtered) {
    final Map<String, List<Lesson>> grouped = {};

    for (final schedule in filtered) {
      final key = '${schedule.pair}|${schedule.discipline}';
      grouped.putIfAbsent(key, () => []).add(schedule);
    }

    return grouped.entries.map((entry) {
      final schedules = entry.value;
      if (schedules.length == 1) {
        return schedules.first;
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

      return Lesson(
        date: first.date,
        begin: first.begin,
        end: first.end,
        pair: first.pair,
        discipline: first.discipline,
        teacher: teachers,
        audience: audiences,
        group: groups,
      );
    }).toList()..sort((a, b) => a.pair.compareTo(b.pair));
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isLoaded,
      replacement: const _RaspLoadingIndicator(),
      child: isError
          ? _RaspErrorState(onRetry: onRetry)
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragEnd: (details) {
                final vx = details.primaryVelocity ?? 0;
                if (vx <= -200) {
                  onSwipeLeft();
                } else if (vx >= 200) {
                  onSwipeRight();
                }
              },
              child: Visibility(
                visible: filteredLesson.isNotEmpty,
                replacement: ListEmpty(
                  img: 'assets/images/no.png',
                  text: 'no_par'.tr,
                ),
                child: _RaspLessonList(schedules: filteredLesson),
              ),
            ),
    );
  }
}

class _RaspLessonList extends StatelessWidget {
  const _RaspLessonList({required this.schedules});

  final List<Lesson> schedules;

  @override
  Widget build(BuildContext context) {
    final grouped = RaspLessonBody.groupLessons(schedules);
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: grouped.length,
      itemBuilder: (context, index) => _RaspLessonItem(element: grouped[index]),
    );
  }
}

class _RaspLessonItem extends StatelessWidget {
  const _RaspLessonItem({required this.element});

  final Lesson element;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${element.begin} — ${element.end}',
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,
                children: [
                  Text(
                    RaspLessonBody.cleanGroupName(element.discipline),
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (element.teacher.isNotEmpty)
                    Text(
                      element.teacher,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Row(
                    spacing: 6,
                    children: [
                      if (element.audience.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                IconsaxPlusLinear.buildings_2,
                                size: 12,
                                color: colorScheme.onTertiaryContainer,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                element.audience,
                                style: textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onTertiaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (element.group.isNotEmpty)
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              element.group,
                              style: textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSecondaryContainer,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RaspLoadingIndicator extends StatelessWidget {
  const _RaspLoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 4, bottom: 4),
              child: MyShimmer(height: 20, width: 80, margin: EdgeInsets.zero),
            ),
            Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    MyShimmer(
                      height: 16,
                      width: double.infinity,
                      margin: EdgeInsets.zero,
                    ),
                    MyShimmer(height: 14, width: 150, margin: EdgeInsets.zero),
                    MyShimmer(height: 14, width: 100, margin: EdgeInsets.zero),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RaspErrorState extends StatelessWidget {
  const _RaspErrorState({this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'error_loading_data'.tr,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 8),
              ElevatedButton(onPressed: onRetry, child: Text('try_again'.tr)),
            ],
          ],
        ),
      ),
    );
  }
}
