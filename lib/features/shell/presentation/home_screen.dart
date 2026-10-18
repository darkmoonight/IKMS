import 'package:material_ui/material_ui.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:ikms/features/schedule/presentation/view/schedules_pages.dart';
import 'package:ikms/features/selection/presentation/view/selection_pages.dart';
import 'package:ikms/features/settings/presentation/view/settings.dart';
import 'package:ikms/features/todos/presentation/view/todos.dart';
import 'package:ikms/features/todos/presentation/widgets/todos_action.dart';
import 'package:ikms/core/utils/responsive_utils.dart';
import 'package:ikms/i18n/tr.dart';

/// Main tab shell hosting schedule, selection, tasks, and settings.
class HomeScreen extends StatefulWidget {
  /// Creates the home tab shell.
  ///
  /// [pageBuilder] overrides default tab pages (used by tests).
  const HomeScreen({super.key, this.pageBuilder});

  /// Optional factory for tab bodies; defaults to production pages.
  final Widget Function(int index)? pageBuilder;

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

/// Public state for tests that need to inspect lazy-tab visitation.
class HomeScreenState extends State<HomeScreen> {
  static const tabCount = 6;

  int tabIndex = 0;

  /// Tabs opened at least once stay mounted (keep-alive after first visit).
  final Set<int> visited = {0};
  final List<Widget?> _pages = List<Widget?>.filled(tabCount, null);

  void changeTabIndex(int index) => setState(() {
    tabIndex = index;
    visited.add(index);
  });

  Widget _pageFor(int index) {
    return _pages[index] ??=
        widget.pageBuilder?.call(index) ?? _defaultPage(index);
  }

  Widget _defaultPage(int index) => switch (index) {
    0 => const MySchedulePage(),
    1 => const ProfessorsPage(),
    2 => const GroupsPage(isSettings: false),
    3 => const AudiencesPage(),
    4 => const TaskPage(),
    5 => const SettingsPage(),
    _ => const SizedBox.shrink(),
  };

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return Scaffold(
      body: IndexedStack(
        index: tabIndex,
        children: [
          for (var i = 0; i < tabCount; i++)
            visited.contains(i) ? _pageFor(i) : const SizedBox.shrink(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context),
      bottomNavigationBar: _buildBottomNavigationBar(isMobile),
    );
  }

  Widget _buildBottomNavigationBar(bool isMobile) {
    return NavigationBar(
      labelBehavior: isMobile
          ? NavigationDestinationLabelBehavior.alwaysHide
          : NavigationDestinationLabelBehavior.onlyShowSelected,
      onDestinationSelected: changeTabIndex,
      selectedIndex: tabIndex,
      destinations: _buildNavigationDestinations(),
    );
  }

  List<NavigationDestination> _buildNavigationDestinations() => [
    _buildNavigationDestination(
      icon: IconsaxPlusLinear.calendar,
      selectedIcon: IconsaxPlusBold.calendar,
      label: 'schedule'.tr,
    ),
    _buildNavigationDestination(
      icon: IconsaxPlusLinear.user_search,
      selectedIcon: IconsaxPlusBold.user_search,
      label: 'professors'.tr,
    ),
    _buildNavigationDestination(
      icon: IconsaxPlusLinear.people,
      selectedIcon: IconsaxPlusBold.people,
      label: 'groups'.tr,
    ),
    _buildNavigationDestination(
      icon: IconsaxPlusLinear.buildings_2,
      selectedIcon: IconsaxPlusBold.buildings_2,
      label: 'audiences'.tr,
    ),
    _buildNavigationDestination(
      icon: IconsaxPlusLinear.task_square,
      selectedIcon: IconsaxPlusBold.task_square,
      label: 'todos'.tr,
    ),
    _buildNavigationDestination(
      icon: IconsaxPlusLinear.category,
      selectedIcon: IconsaxPlusBold.category,
      label: 'settings'.tr,
    ),
  ];

  NavigationDestination _buildNavigationDestination({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) => NavigationDestination(
    icon: Icon(icon, size: 24),
    selectedIcon: Icon(selectedIcon, size: 24),
    label: label,
    tooltip: label,
  );

  Widget? _buildFloatingActionButton(BuildContext context) {
    if (tabIndex == 4) {
      return FloatingActionButton(
        onPressed: () => _showTodoBottomSheet(context),
        tooltip: 'create'.tr,
        child: const Icon(IconsaxPlusLinear.add, size: 24),
      );
    }
    return null;
  }

  void _showTodoBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      builder: (BuildContext context) =>
          TodosAction(text: 'create'.tr, edit: false),
    );
  }
}
