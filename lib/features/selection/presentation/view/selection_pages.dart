import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ikms/core/di/context_extensions.dart';
import 'package:ikms/core/di/provider_refs.dart';
import 'package:ikms/core/di/settings_revision.dart';
import 'package:ikms/core/utils/navigation_helper.dart';
import 'package:ikms/domain/entities/catalog_refs.dart';
import 'package:ikms/features/schedule/presentation/view/schedules_pages.dart';
import 'package:ikms/features/selection/presentation/widgets/selection_list.dart';
import 'package:ikms/i18n/tr.dart';

/// Base selection screen for university catalog entities.
abstract class BaseSelectionPage<T extends NamedRef> extends StatefulWidget {
  /// i18n key for the page header.
  final String headerText;

  /// i18n key for the search field label.
  final String labelText;

  /// Whether pull-to-refresh is enabled.
  final bool hasRefresh;

  /// Whether this page is opened from settings (returns selection on tap).
  final bool isSettings;

  /// Creates a catalog selection page.
  const BaseSelectionPage({
    super.key,
    required this.headerText,
    required this.labelText,
    this.hasRefresh = true,
    this.isSettings = false,
  });
}

/// Shared filter/cache/list behavior for selection pages.
abstract class BaseSelectionPageState<
  T extends NamedRef,
  W extends BaseSelectionPage<T>
>
    extends State<W> {
  List<T> items = [];
  String filter = '';
  bool isLoaded = false;
  bool isError = false;
  int? _universityId;
  ValueNotifier<Future<bool>>? _isOnline;
  ProviderSubscription<int>? _settingsRevisionSub;

  /// University id used to scope catalog queries.
  int? get selectedUniversityId => context.preferences.university?.id;

  IconData get listIcon;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _isOnline = context.isOnline;
      _isOnline!.addListener(_onOnlineStatusChanged);
      _universityId = selectedUniversityId;
      final container = ProviderScope.containerOf(context);
      _settingsRevisionSub = container.listen<int>(settingsRevisionProvider, (
        _,
        _,
      ) {
        if (!mounted) return;
        final nextId = selectedUniversityId;
        if (_universityId != nextId) {
          _universityId = nextId;
          _loadData();
        }
      });
      _loadData();
    });
  }

  @override
  void dispose() {
    _settingsRevisionSub?.close();
    _isOnline?.removeListener(_onOnlineStatusChanged);
    super.dispose();
  }

  /// Loads catalog rows for [universityId] from the port.
  Future<List<T>> fetchData(int universityId);

  /// Handles a row tap (open detail or return selection).
  void onEntrySelected(T selectionData);

  Future<void> _loadData() async {
    try {
      await applyFilter('');
    } catch (e) {
      if (!mounted) return;
      setState(() => isError = true);
      debugPrint('Error loading data: $e');
    }
  }

  Future<void> _onOnlineStatusChanged() async {
    if (!mounted) return;
    if (await context.isOnline.value) {
      if (!mounted) return;
      await _loadData();
    }
  }

  Future<List<T>> _getFilteredData(int? universityId, String query) async {
    if (universityId == null) return [];
    final data = await fetchData(universityId);
    final needle = query.toLowerCase();
    return data
        .where((element) => element.name.toLowerCase().contains(needle))
        .toList();
  }

  /// Applies a name filter and reloads catalog items.
  Future<void> applyFilter(String value) async {
    try {
      final data = await _getFilteredData(selectedUniversityId, value);

      if (mounted) {
        setState(() {
          filter = value;
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

  /// Builds the searchable selection list content.
  Widget buildContent() {
    final content = SelectionList<T>(
      headerText: widget.headerText.tr,
      labelText: widget.labelText.tr,
      onTextChanged: applyFilter,
      isLoaded: isLoaded,
      isError: isError,
      data: items,
      onEntrySelected: onEntrySelected,
      itemIcon: (_) => listIcon,
      onBackPressed: widget.isSettings
          ? () => NavigationHelper.back(context)
          : null,
      onRetry: _loadData,
    );

    return widget.hasRefresh
        ? RefreshIndicator(onRefresh: _loadData, child: content)
        : content;
  }
}

/// Audience catalog tab.
class AudiencesPage extends BaseSelectionPage<AudienceRef> {
  /// Creates the audiences catalog page.
  const AudiencesPage({super.key})
    : super(headerText: 'audiences', labelText: 'number');

  @override
  State<AudiencesPage> createState() => _AudiencesPageState();
}

class _AudiencesPageState
    extends BaseSelectionPageState<AudienceRef, AudiencesPage> {
  @override
  IconData get listIcon => IconsaxPlusLinear.buildings_2;

  @override
  Future<List<AudienceRef>> fetchData(int universityId) =>
      context.scheduleCache.cacheAudiences(universityId);

  @override
  void onEntrySelected(AudienceRef selectionData) async {
    await NavigationHelper.slideUp(
      context,
      RaspDetailPage(
        target: ScheduleTarget(
          kind: ScheduleTargetKind.audience,
          id: selectionData.id,
          name: selectionData.name,
          universityId: selectionData.universityId,
        ),
      ),
    );
    if (mounted) {
      applyFilter(filter);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(body: buildContent());
}

/// Group catalog tab or settings picker.
class GroupsPage extends BaseSelectionPage<GroupRef> {
  /// Creates the groups catalog page.
  const GroupsPage({super.key, required super.isSettings})
    : super(headerText: 'groups', labelText: 'groupsName');

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends BaseSelectionPageState<GroupRef, GroupsPage> {
  @override
  IconData get listIcon => IconsaxPlusLinear.people;

  @override
  Future<List<GroupRef>> fetchData(int universityId) =>
      context.scheduleCache.cacheGroups(universityId);

  @override
  void onEntrySelected(GroupRef selectionData) async {
    final route = ModalRoute.of(context);
    final isInDialog = route is PopupRoute;
    if (widget.isSettings || isInDialog) {
      NavigationHelper.back(context, result: selectionData);
    } else {
      await NavigationHelper.slideUp(
        context,
        RaspDetailPage(
          target: ScheduleTarget(
            kind: ScheduleTargetKind.group,
            id: selectionData.id,
            name: selectionData.name,
            universityId: selectionData.universityId,
          ),
        ),
      );
      if (mounted) {
        applyFilter(filter);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(body: buildContent());
}

/// Professor catalog tab.
class ProfessorsPage extends BaseSelectionPage<TeacherRef> {
  /// Creates the professors catalog page.
  const ProfessorsPage({super.key})
    : super(headerText: 'professors', labelText: 'fio');

  @override
  State<ProfessorsPage> createState() => _ProfessorsPageState();
}

class _ProfessorsPageState
    extends BaseSelectionPageState<TeacherRef, ProfessorsPage> {
  @override
  IconData get listIcon => IconsaxPlusLinear.user;

  @override
  Future<List<TeacherRef>> fetchData(int universityId) =>
      context.scheduleCache.cacheTeachers(universityId);

  @override
  void onEntrySelected(TeacherRef selectionData) async {
    await NavigationHelper.slideUp(
      context,
      RaspDetailPage(
        target: ScheduleTarget(
          kind: ScheduleTargetKind.teacher,
          id: selectionData.id,
          name: selectionData.name,
          universityId: selectionData.universityId,
        ),
      ),
    );
    if (mounted) {
      applyFilter(filter);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(body: buildContent());
}

/// University catalog used during onboarding and settings.
class UniversityPage extends ConsumerStatefulWidget {
  /// Creates the universities catalog page.
  const UniversityPage({super.key});

  @override
  ConsumerState<UniversityPage> createState() => _UniversityPageState();
}

class _UniversityPageState extends ConsumerState<UniversityPage> {
  List<UniversityRef> items = [];
  String filter = '';
  bool isLoaded = false;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      await applyFilter('');
    } catch (e) {
      if (mounted) {
        setState(() {
          isError = true;
          isLoaded = true;
        });
      }
      debugPrint('Error loading universities: $e');
    }
  }

  /// Filters the local university catalog by name.
  Future<void> applyFilter(String value) async {
    try {
      final data = await _getFilteredData(value);

      if (mounted) {
        setState(() {
          filter = value;
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

  Future<List<UniversityRef>> _getFilteredData(String value) async {
    final allUniversities = await ref
        .read(scheduleCachePortProvider)
        .ensureUniversities();
    return allUniversities
        .where(
          (element) => element.name.toLowerCase().contains(value.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDialog = ModalRoute.of(context) is PopupRoute;
    return Scaffold(
      body: SelectionList<UniversityRef>(
        headerText: 'universities'.tr,
        labelText: 'universitiesName'.tr,
        isLoaded: isLoaded,
        isError: isError,
        onTextChanged: applyFilter,
        onEntrySelected: (UniversityRef selectionData) =>
            NavigationHelper.back(context, result: selectionData),
        onBackPressed: isDialog ? null : () => NavigationHelper.back(context),
        onRetry: _loadData,
        data: items,
        itemIcon: (_) => IconsaxPlusLinear.buildings,
      ),
    );
  }
}
