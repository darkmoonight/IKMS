import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ikms/core/di/provider_refs.dart';
import 'package:ikms/core/di/settings_revision.dart';
import 'package:ikms/core/utils/navigation_helper.dart';
import 'package:ikms/domain/entities/catalog_refs.dart';
import 'package:ikms/domain/entities/lesson.dart';
import 'package:ikms/features/schedule/presentation/widgets/rasp_widget.dart';

/// Shared schedule-loading state for my-schedule and detail pages.
abstract class BaseSchedulePageState<T extends ConsumerStatefulWidget>
    extends ConsumerState<T> {
  bool isLoaded = false;
  bool isError = false;
  final ValueNotifier<List<Lesson>> raspData = ValueNotifier(<Lesson>[]);

  @protected
  Future<void> loadData({bool forceRefresh = false});

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    raspData.dispose();
    super.dispose();
  }

  /// Builds a pull-to-refresh wrapper around [RaspWidget].
  Widget buildRefreshIndicator(
    BuildContext context, {
    Function()? onBackPressed,
    String? headerText,
  }) => RefreshIndicator(
    onRefresh: () => loadData(forceRefresh: true),
    child: RaspWidget(
      isLoaded: isLoaded,
      isError: isError,
      onRetry: () => loadData(forceRefresh: true),
      raspElements: raspData,
      onBackPressed: onBackPressed,
      headerText: headerText,
    ),
  );
}

/// Home-tab schedule for the user's selected group.
class MySchedulePage extends ConsumerStatefulWidget {
  /// Creates the user's group schedule tab.
  const MySchedulePage({super.key});

  @override
  ConsumerState<MySchedulePage> createState() => _MySchedulePageState();
}

class _MySchedulePageState extends BaseSchedulePageState<MySchedulePage> {
  int? _currentGroupId;

  @override
  Widget build(BuildContext context) {
    ref.listen(settingsRevisionProvider, (_, _) {
      final groupId = ref.read(preferencesProvider).group?.id;
      if (_currentGroupId != groupId) {
        _currentGroupId = groupId;
        loadData();
      }
    });
    return buildRefreshIndicator(context);
  }

  @override
  Future<void> loadData({bool forceRefresh = false}) async {
    try {
      final preferences = ref.read(preferencesProvider);
      final group = preferences.group;
      final university = preferences.university;
      _currentGroupId = group?.id;

      if (group != null && university != null) {
        final lessons = await ref
            .read(scheduleCachePortProvider)
            .cacheGroupLessons(
              university.id,
              group.id,
              forceRefresh: forceRefresh,
            );
        raspData.value = lessons;
        if (mounted) {
          setState(() {
            isLoaded = true;
            isError = false;
          });
        }
      } else {
        raspData.value = [];
        if (mounted) {
          setState(() {
            isLoaded = true;
            isError = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading schedule: $e');
      if (mounted) {
        setState(() {
          isLoaded = true;
          isError = true;
        });
      }
    }
  }
}

/// Detail schedule for a group, teacher, or audience entity.
class RaspDetailPage extends ConsumerStatefulWidget {
  /// Creates a detail page for [target].
  const RaspDetailPage({super.key, required this.target});

  /// Schedule target whose lessons are shown.
  final ScheduleTarget target;

  @override
  ConsumerState<RaspDetailPage> createState() => _RaspDetailPageState();
}

class _RaspDetailPageState extends BaseSchedulePageState<RaspDetailPage> {
  @override
  Future<void> loadData({bool forceRefresh = false}) async {
    try {
      final port = ref.read(scheduleCachePortProvider);
      final target = widget.target;
      final lessons = switch (target.kind) {
        ScheduleTargetKind.group => await port.cacheGroupLessons(
          target.universityId,
          target.id,
          forceRefresh: forceRefresh,
        ),
        ScheduleTargetKind.teacher => await port.cacheTeacherLessons(
          target.universityId,
          target.id,
          forceRefresh: forceRefresh,
        ),
        ScheduleTargetKind.audience => await port.cacheAudienceLessons(
          target.universityId,
          target.id,
          forceRefresh: forceRefresh,
        ),
      };
      if (mounted) {
        setState(() {
          raspData.value = lessons;
          isLoaded = true;
          isError = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading schedule: $e');
      if (mounted) {
        setState(() {
          isLoaded = true;
          isError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: buildRefreshIndicator(
      context,
      onBackPressed: () => NavigationHelper.back(context),
      headerText: widget.target.name,
    ),
  );
}
