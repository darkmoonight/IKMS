import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:ikms/core/widgets/confirmation_dialog.dart';
import 'package:ikms/core/widgets/text_form.dart';
import 'package:ikms/core/utils/responsive_utils.dart';
import 'package:ikms/features/todos/application/todo_notifier.dart';
import 'package:ikms/features/todos/presentation/widgets/todos_list.dart';
import 'package:ikms/i18n/tr.dart';
import 'package:material_ui/material_ui.dart';

/// Todos tab with search, doing/done tabs, and multi-select actions.
class TaskPage extends ConsumerStatefulWidget {
  /// Creates the todos page.
  const TaskPage({super.key});

  @override
  ConsumerState<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends ConsumerState<TaskPage>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  String _searchFilter = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _initializeSearch() => _applyFilter('');

  void _applyFilter(String value) =>
      setState(() => _searchFilter = value.toLowerCase());

  void _clearSearch() {
    _searchController.clear();
    _applyFilter('');
  }

  Future<void> _showDeleteConfirmationDialog() async {
    final todoNotifier = ref.read(todoNotifierProvider.notifier);
    final selected = ref.read(todoNotifierProvider).selectedTodo;

    await showDeleteConfirmation(
      context: context,
      title: 'deletedTodo',
      message: 'deletedTodoQuery',
      onConfirm: () async {
        await todoNotifier.deleteTodo(selected);
        todoNotifier.doMultiSelectionTodoClear();
      },
    );
  }

  void _toggleSelectAll() {
    final todoNotifier = ref.read(todoNotifierProvider.notifier);
    final statusFilter = _tabController.index != 0;
    final allSelected = todoNotifier.areAllSelectedInTab(statusFilter);

    if (allSelected) {
      todoNotifier.selectAllInTab(select: false, done: statusFilter);
    } else {
      todoNotifier.selectAllInTab(select: true, done: statusFilter);
    }
  }

  String _getTaskWord(int count) {
    final remainder = count % 10;
    if (count >= 11 && count <= 19) return 'task_many'.tr;
    if (remainder == 1) return 'task_one'.tr;
    if (remainder >= 2 && remainder <= 4) return 'task_few'.tr;
    return 'task_many'.tr;
  }

  PreferredSizeWidget _buildAppBar(TodoState todoState) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMultiSelection = todoState.isMultiSelectionTodo;
    final selectedCount = todoState.selectedTodo.length;
    final todoNotifier = ref.read(todoNotifierProvider.notifier);

    return AppBar(
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: !isMultiSelection,
      title: isMultiSelection
          ? Row(
              children: [
                Expanded(
                  child: Text(
                    '$selectedCount ${_getTaskWord(selectedCount)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            )
          : Text(
              'todos'.tr,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
      leading: isMultiSelection
          ? IconButton(
              onPressed: todoNotifier.doMultiSelectionTodoClear,
              icon: Icon(
                IconsaxPlusLinear.arrow_left_3,
                color: colorScheme.onSecondaryContainer,
              ),
            )
          : null,
      actions: isMultiSelection
          ? [
              IconButton(
                onPressed: _toggleSelectAll,
                icon: Icon(
                  todoNotifier.areAllSelectedInTab(_tabController.index != 0)
                      ? IconsaxPlusLinear.close_square
                      : IconsaxPlusLinear.tick_circle,
                  color: colorScheme.primary,
                ),
              ),
              IconButton(
                onPressed: _showDeleteConfirmationDialog,
                icon: Icon(IconsaxPlusLinear.trash, color: colorScheme.error),
              ),
              const SizedBox(width: 8),
            ]
          : null,
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveUtils.isMobile(context);

    return MyTextForm(
      labelText: 'searchTodo'.tr,
      variant: TextFieldVariant.card,
      type: TextInputType.text,
      icon: Icon(
        IconsaxPlusLinear.search_normal_1,
        size: 20,
        color: colorScheme.onSurfaceVariant,
      ),
      controller: _searchController,
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 5 : 8,
      ),
      onChanged: _applyFilter,
      iconButton: _searchController.text.isNotEmpty
          ? IconButton(
              onPressed: _clearSearch,
              icon: Icon(
                IconsaxPlusLinear.close_circle,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
            )
          : null,
    );
  }

  Widget _buildTabBar() => TabBar(
    controller: _tabController,
    tabAlignment: TabAlignment.start,
    isScrollable: true,
    dividerColor: Colors.transparent,
    splashFactory: NoSplash.splashFactory,
    overlayColor: WidgetStateProperty.all(Colors.transparent),
    tabs: [
      Tab(text: 'doing'.tr),
      Tab(text: 'done'.tr),
    ],
  );

  Widget _buildTabContent() => Expanded(
    child: Padding(
      padding: const EdgeInsets.only(top: 5),
      child: TabBarView(
        controller: _tabController,
        children: [
          TodosList(done: false, searchTodo: _searchFilter),
          TodosList(done: true, searchTodo: _searchFilter),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final todoState = ref.watch(todoNotifierProvider);
    final todoNotifier = ref.read(todoNotifierProvider.notifier);

    return PopScope(
      canPop: todoState.isPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (todoState.isMultiSelectionTodo) {
          todoNotifier.doMultiSelectionTodoClear();
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(todoState),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchField(context),
            _buildTabBar(),
            _buildTabContent(),
          ],
        ),
      ),
    );
  }
}
