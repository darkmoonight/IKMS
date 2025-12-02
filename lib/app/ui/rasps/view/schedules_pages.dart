import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ikms/app/api/caching.dart';
import 'package:ikms/app/data/db.dart';
import 'package:ikms/app/ui/rasps/widgets/rasp_widget.dart';
import 'package:ikms/main.dart';

abstract class BaseSchedulePageState<T extends StatefulWidget>
    extends State<T> {
  bool isLoaded = false;
  final ValueNotifier<List<Schedule>> raspData = ValueNotifier(<Schedule>[]);

  @protected
  Future<void> loadData();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Widget buildRefreshIndicator(
    BuildContext context, {
    Function()? onBackPressed,
    String? headerText,
  }) => RefreshIndicator(
    onRefresh: loadData,
    child: RaspWidget(
      isLoaded: isLoaded,
      raspElements: raspData,
      onBackPressed: onBackPressed,
      headerText: headerText,
    ),
  );
}

class MySchedulePage extends StatefulWidget {
  const MySchedulePage({super.key});

  @override
  State<MySchedulePage> createState() => _MySchedulePageState();
}

class _MySchedulePageState extends BaseSchedulePageState<MySchedulePage> {
  GroupSchedule? _currentGroup;

  @override
  void initState() {
    _currentGroup = settings.group.value;
    isar.settings.watchLazy().listen((_) {
      if (_currentGroup != settings.group.value) {
        _currentGroup = settings.group.value;
        loadData();
      }
    });
    super.initState();
  }

  @override
  Future<void> loadData() async {
    try {
      final group = settings.group.value;
      final university = settings.university.value;

      if (group != null && university != null) {
        final schedule = await UniversityCaching.cacheGroupSchedule(
          university,
          group,
        );
        raspData.value = schedule.schedules.toList();
      }
    } catch (e) {
      debugPrint('Error loading schedule: $e');
    } finally {
      if (mounted) {
        setState(() => isLoaded = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) => buildRefreshIndicator(context);
}

class RaspDetailPage extends StatefulWidget {
  const RaspDetailPage({super.key, required this.entity});

  final dynamic entity;

  @override
  State<RaspDetailPage> createState() => _RaspDetailPageState();
}

class _RaspDetailPageState extends BaseSchedulePageState<RaspDetailPage> {
  @override
  Future<void> loadData() async {
    try {
      final university = widget.entity.university.value;
      if (university == null) {
        throw Exception('University is null');
      }

      final schedule = await _getScheduleForEntity(university);
      if (mounted) {
        setState(() {
          raspData.value = schedule.schedules.toList();
          isLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading schedule: $e');
      if (mounted) {
        setState(() => isLoaded = true);
      }
    }
  }

  Future<dynamic> _getScheduleForEntity(University university) async {
    if (widget.entity is GroupSchedule) {
      return await UniversityCaching.cacheGroupSchedule(
        university,
        widget.entity as GroupSchedule,
      );
    } else if (widget.entity is TeacherSchedule) {
      return await UniversityCaching.cacheTeacherSchedule(
        university,
        widget.entity as TeacherSchedule,
      );
    } else if (widget.entity is AudienceSchedule) {
      return await UniversityCaching.cacheAudienceSchedule(
        university,
        widget.entity as AudienceSchedule,
      );
    } else {
      throw Exception('Unsupported entity type: ${widget.entity.runtimeType}');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: buildRefreshIndicator(
      context,
      onBackPressed: () => Get.back(),
      headerText: widget.entity.name,
    ),
  );
}
