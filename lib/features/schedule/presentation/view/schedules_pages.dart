import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ikms/core/di/provider_refs.dart';
import 'package:ikms/core/di/settings_revision.dart';
import 'package:ikms/core/utils/navigation_helper.dart';
import 'package:ikms/data/models/db.dart';
import 'package:ikms/features/schedule/presentation/widgets/rasp_widget.dart';

/// Shared schedule-loading state for my-schedule and detail pages.
abstract class BaseSchedulePageState<T extends ConsumerStatefulWidget>
    extends ConsumerState<T> {
  bool isLoaded = false;
  bool isError = false;
  final ValueNotifier<List<Schedule>> raspData = ValueNotifier(<Schedule>[]);

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
      final group = ref.read(settingsProvider).group.value;
      final groupId = group?.id;
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
      final settings = ref.read(settingsProvider);
      final group = settings.group.value;
      final university = settings.university.value;
      _currentGroupId = group?.id;

      if (group != null && university != null) {
        final schedule = await ref
            .read(scheduleRepositoryProvider)
            .cacheGroupSchedule(university, group, forceRefresh: forceRefresh);
        raspData.value = schedule.schedules.toList();
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
  /// Creates a detail page for [entity].
  const RaspDetailPage({super.key, required this.entity});

  /// Schedule entity whose lessons are shown.
  final Object entity;

  @override
  ConsumerState<RaspDetailPage> createState() => _RaspDetailPageState();
}

class _RaspDetailPageState extends BaseSchedulePageState<RaspDetailPage> {
  @override
  Future<void> loadData({bool forceRefresh = false}) async {
    try {
      final university = await _resolveUniversity();
      if (university == null) {
        throw Exception('University is null');
      }

      final schedule = await _getScheduleForEntity(
        university,
        forceRefresh: forceRefresh,
      );
      if (mounted) {
        setState(() {
          raspData.value = schedule.schedules.toList();
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

  Future<University?> _resolveUniversity() async {
    final entity = widget.entity;
    if (entity is GroupSchedule) {
      await entity.university.load();
      return entity.university.value;
    }
    if (entity is TeacherSchedule) {
      await entity.university.load();
      return entity.university.value;
    }
    if (entity is AudienceSchedule) {
      await entity.university.load();
      return entity.university.value;
    }
    return null;
  }

  Future<({List<Schedule> schedules})> _getScheduleForEntity(
    University university, {
    required bool forceRefresh,
  }) async {
    final repo = ref.read(scheduleRepositoryProvider);
    final entity = widget.entity;
    if (entity is GroupSchedule) {
      final result = await repo.cacheGroupSchedule(
        university,
        entity,
        forceRefresh: forceRefresh,
      );
      return (schedules: result.schedules.toList());
    }
    if (entity is TeacherSchedule) {
      final result = await repo.cacheTeacherSchedule(
        university,
        entity,
        forceRefresh: forceRefresh,
      );
      return (schedules: result.schedules.toList());
    }
    if (entity is AudienceSchedule) {
      final result = await repo.cacheAudienceSchedule(
        university,
        entity,
        forceRefresh: forceRefresh,
      );
      return (schedules: result.schedules.toList());
    }
    throw Exception('Unsupported entity type: ${entity.runtimeType}');
  }

  String get _headerText {
    final entity = widget.entity;
    if (entity is GroupSchedule) return entity.name;
    if (entity is TeacherSchedule) return entity.name;
    if (entity is AudienceSchedule) return entity.name;
    return '';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: buildRefreshIndicator(
      context,
      onBackPressed: () => NavigationHelper.back(context),
      headerText: _headerText,
    ),
  );
}
