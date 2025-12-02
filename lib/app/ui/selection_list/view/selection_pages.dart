import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ikms/app/api/caching.dart';
import 'package:ikms/app/data/db.dart';
import 'package:ikms/app/ui/rasps/view/schedules_pages.dart';
import 'package:ikms/app/ui/selection_list/widgets/selection_list.dart';
import 'package:ikms/main.dart';
import 'package:isar_community/isar.dart';

abstract class BaseSelectionPage<T extends SelectionData>
    extends StatefulWidget {
  final String headerText;
  final String labelText;
  final bool hasRefresh;
  final bool isSettings;

  const BaseSelectionPage({
    super.key,
    required this.headerText,
    required this.labelText,
    this.hasRefresh = true,
    this.isSettings = false,
  });
}

abstract class BaseSelectionPageState<
  T extends SelectionData,
  W extends BaseSelectionPage<T>
>
    extends State<W> {
  List<T> items = [];
  String filter = '';
  bool isLoaded = false;
  bool isError = false;
  University? _selectedUniversity;

  University? get selectedUniversity {
    _selectedUniversity ??= settings.university.value;
    return _selectedUniversity;
  }

  @override
  void initState() {
    super.initState();
    isOnline.addListener(_onOnlineStatusChanged);
    _loadData();
  }

  @override
  void dispose() {
    isOnline.removeListener(_onOnlineStatusChanged);
    super.dispose();
  }

  Future<List<T>> fetchData(University? university);
  Future<bool> cacheData(University university);
  void onEntrySelected(T selectionData);

  Future<void> _loadData() async {
    try {
      await applyFilter('');
    } catch (e) {
      setState(() => isError = true);
      debugPrint('Error loading data: $e');
    }
  }

  Future<void> _onOnlineStatusChanged() async {
    if (await isOnline.value) {
      await _loadData();
    }
  }

  Future<List<T>> _getFilteredData(University? university) async {
    if (university == null) return [];

    if (await isOnline.value) {
      try {
        await cacheData(university);
      } catch (e) {
        debugPrint('Error caching data: $e');
      }
    }

    final data = await fetchData(university);
    return data
        .where(
          (element) =>
              element.name.toLowerCase().contains(filter.toLowerCase()),
        )
        .toList();
  }

  Future<void> applyFilter(String value) async {
    try {
      setState(() {
        filter = value;
        isLoaded = false;
      });

      final data = await _getFilteredData(selectedUniversity);

      if (mounted) {
        setState(() {
          items = data;
          isLoaded = true;
          isError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isError = true;
          isLoaded = true;
        });
      }
      debugPrint('Error applying filter: $e');
    }
  }

  Widget buildContent() {
    final content = SelectionList<T>(
      headerText: widget.headerText.tr,
      labelText: widget.labelText.tr,
      onTextChanged: applyFilter,
      isLoaded: isLoaded,
      isError: isError,
      data: items,
      onEntrySelected: onEntrySelected,
      onBackPressed: widget.isSettings ? Get.back : null,
    );

    return widget.hasRefresh
        ? RefreshIndicator(onRefresh: _loadData, child: content)
        : content;
  }
}

class AudiencesPage extends BaseSelectionPage<AudienceSchedule> {
  const AudiencesPage({super.key})
    : super(headerText: 'audiences', labelText: 'number');

  @override
  State<AudiencesPage> createState() => _AudiencesPageState();
}

class _AudiencesPageState
    extends BaseSelectionPageState<AudienceSchedule, AudiencesPage> {
  @override
  Future<List<AudienceSchedule>> fetchData(University? university) async =>
      await isar.audienceSchedules
          .filter()
          .university((q) => q.idEqualTo(university!.id))
          .optional(
            !(await isOnline.value),
            (q) => q.schedulesLengthGreaterThan(0),
          )
          .sortByLastUpdateDesc()
          .findAll();

  @override
  Future<bool> cacheData(University university) =>
      UniversityCaching.cacheAudiences(university);

  @override
  void onEntrySelected(AudienceSchedule selectionData) async {
    await Get.to(
      () => RaspDetailPage(entity: selectionData),
      transition: Transition.downToUp,
    );
    if (mounted) {
      applyFilter(filter);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(body: buildContent());
}

class GroupsPage extends BaseSelectionPage<GroupSchedule> {
  const GroupsPage({super.key, required super.isSettings})
    : super(headerText: 'groups', labelText: 'groupsName');

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState
    extends BaseSelectionPageState<GroupSchedule, GroupsPage> {
  @override
  Future<List<GroupSchedule>> fetchData(University? university) async =>
      await isar.groupSchedules
          .filter()
          .university((q) => q.idEqualTo(university!.id))
          .optional(
            !(await isOnline.value),
            (q) => q.schedulesLengthGreaterThan(0),
          )
          .sortByLastUpdateDesc()
          .findAll();

  @override
  Future<bool> cacheData(University university) =>
      UniversityCaching.cacheGroups(university);

  @override
  void onEntrySelected(GroupSchedule selectionData) async {
    final isDialog = Get.isDialogOpen ?? false;
    if (widget.isSettings || isDialog) {
      Get.back(result: selectionData);
    } else {
      await Get.to(
        () => RaspDetailPage(entity: selectionData),
        transition: Transition.downToUp,
      );
      if (mounted) {
        applyFilter(filter);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(body: buildContent());
}

class ProfessorsPage extends BaseSelectionPage<TeacherSchedule> {
  const ProfessorsPage({super.key})
    : super(headerText: 'professors', labelText: 'fio');

  @override
  State<ProfessorsPage> createState() => _ProfessorsPageState();
}

class _ProfessorsPageState
    extends BaseSelectionPageState<TeacherSchedule, ProfessorsPage> {
  @override
  Future<List<TeacherSchedule>> fetchData(University? university) async =>
      await isar.teacherSchedules
          .filter()
          .university((q) => q.idEqualTo(university!.id))
          .optional(
            !(await isOnline.value),
            (q) => q.schedulesLengthGreaterThan(0),
          )
          .sortByLastUpdateDesc()
          .findAll();

  @override
  Future<bool> cacheData(University university) =>
      UniversityCaching.cacheTeachers(university);

  @override
  void onEntrySelected(TeacherSchedule selectionData) async {
    await Get.to(
      () => RaspDetailPage(entity: selectionData),
      transition: Transition.downToUp,
    );
    if (mounted) {
      applyFilter(filter);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(body: buildContent());
}

class UniversityPage extends StatefulWidget {
  const UniversityPage({super.key});

  @override
  State<UniversityPage> createState() => _UniversityPageState();
}

class _UniversityPageState extends State<UniversityPage> {
  List<University> items = [];
  String filter = '';
  bool isLoaded = false;
  bool isError = false;
  final bool isDialog = Get.isDialogOpen ?? false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await applyFilter('');
    } catch (e) {
      setState(() => isError = true);
      debugPrint('Error loading universities: $e');
    }
  }

  Future<void> applyFilter(String value) async {
    try {
      setState(() {
        filter = value;
        isLoaded = false;
      });

      final data = await _getFilteredData();

      if (mounted) {
        setState(() {
          items = data;
          isLoaded = true;
          isError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isError = true;
          isLoaded = true;
        });
      }
      debugPrint('Error applying filter: $e');
    }
  }

  Future<List<University>> _getFilteredData() async {
    final allUniversities = await isar.universitys.where().findAll();
    return allUniversities
        .where(
          (element) =>
              element.name.toLowerCase().contains(filter.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SelectionList<University>(
      headerText: 'universities'.tr,
      labelText: 'universitiesName'.tr,
      isLoaded: isLoaded,
      isError: isError,
      onTextChanged: applyFilter,
      onEntrySelected: (University selectionData) =>
          Get.back(result: selectionData),
      onBackPressed: isDialog ? null : Get.back,
      data: items,
    ),
  );
}
